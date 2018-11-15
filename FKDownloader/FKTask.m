//
//  FKTask.m
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKTask.h"
#import "FKDownloadManager.h"
#import "FKConfigure.h"
#import "NSString+FKDownload.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

FKNotificationName const FKTaskDidPrepareNotification   = @"FKTaskDidPrepareNotification";
FKNotificationName const FKTaskDidIdleNotification      = @"FKTaskDidIdleNotification";
FKNotificationName const FKTaskWillExecuteNotification  = @"FKTaskWillExecuteNotification";
FKNotificationName const FKTaskDidExecuteNotication     = @"FKTaskDidExecuteNotication";
FKNotificationName const FKTaskProgressNotication       = @"FKTaskProgressNotication";
FKNotificationName const FKTaskDidResumingNotification  = @"FKTaskDidResumingNotification";
FKNotificationName const FKTaskDidFinishNotication      = @"FKTaskDidFinishNotication";
FKNotificationName const FKTaskErrorNotication          = @"FKTaskErrorNotication";
FKNotificationName const FKTaskWillSuspendNotication    = @"FKTaskWillSuspendNotication";
FKNotificationName const FKTaskDidSuspendNotication     = @"FKTaskDidSuspendNotication";
FKNotificationName const FKTaskWillCancelldNotication   = @"FKTaskWillCancelldNotication";
FKNotificationName const FKTaskDidCancelldNotication    = @"FKTaskDidCancelldNotication";
FKNotificationName const FKTaskSpeedInfoNotication      = @"FKTaskSpeedInfoNotication";

@interface FKTask ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString    *identifier;
@property (nonatomic, strong) NSProgress  *progress;
@property (nonatomic, strong) NSData      *resumeData;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval    prevTime;
@property (nonatomic, assign) int64_t           prevReceivedBytes;
@property (nonatomic, strong) NSNumber          *estimatedTimeRemaining;
@property (nonatomic, strong) NSNumber          *bytesPerSecondSpeed;

@end

@implementation FKTask
@synthesize resumeData = _resumeData;


#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(refreshProgerss) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    return self;
}


#pragma mark - Operation
- (void)restore:(NSURLSessionDownloadTask *)task {
    [self clear];
    self.downloadTask = task;
    [self addProgressObserver];
    
    switch (task.state) {
        case NSURLSessionTaskStateRunning:
            self.status = TaskStatusExecuting;
            break;
            
        case NSURLSessionTaskStateSuspended:
            // tips: 后台任务没有暂停状态
            self.status = TaskStatusSuspend;
            break;
            
        case NSURLSessionTaskStateCanceling:
            // !!!: iOS 12/12.1, 机型 8 以下.  BUG: 完全退出 app, 后台下载异常停止, 状态码为 Cancelld, 需要识别是否有恢复数据, 继续下载
            self.status = TaskStatusCancelld;
            break;
            
        case NSURLSessionTaskStateCompleted:
            if (self.isHasResumeData) {
                self.status = TaskStatusSuspend;
            } else {
                self.status = TaskStatusFinish;
            }
            break;
    }
}

- (void)reday {
    FKLog(@"开始准备: %@", self)
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    if ([self.manager.fileManager fileExistsAtPath:[self resumeFilePath]]) {
        [self removeProgressObserver];
        self.downloadTask = [self.manager.session downloadTaskWithResumeData:[self resumeData]];
        [self clearResumeData];
    } else {
        self.downloadTask = [self.manager.session downloadTaskWithRequest:request];
    }
    
    [self addProgressObserver];
    self.prevTime = 1;
    self.bytesPerSecondSpeed = [NSNumber numberWithLongLong:0];
    self.estimatedTimeRemaining = [NSNumber numberWithLongLong:0];
    
    [self sendPrepareInfo];
    [self sendWillExecutingInfo];
}

- (void)addProgressObserver {
    [self.downloadTask addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
                           options:NSKeyValueObservingOptionNew
                           context:nil];
    [self.downloadTask addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive)) options:NSKeyValueObservingOptionNew
                           context:nil];
}

- (void)removeProgressObserver {
    [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
    [self.downloadTask removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))];
}

- (void)execute {
    FKLog(@"执行: %@", self)
    if (self.isFinish) {
        FKLog(@"文件早已下载完成: %@", self)
        self.progress.totalUnitCount = 1;
        self.progress.completedUnitCount = 1;
        [self sendFinishInfo];
    } else if (self.isHasResumeData) {
        FKLog(@"检测到恢复数据: %@", self)
        [self resume];
    } else {
        FKLog(@"没有恢复数据: %@", self)
        [self.downloadTask resume];
        [self sendExecutingInfo];
    }
}

- (void)suspend {
    [self suspendWithComplete:nil];
}

- (void)suspendWithComplete:(void (^)(void))complete {
    [self sendWillSuspendInfo];
    
    // !!!: https://stackoverflow.com/questions/39346231/resume-nsurlsession-on-ios10/39347461#39347461
    // tips: iOS 12/12.1 resumeData 与之前格式不一致, 之前保存的文件为 xml 格式, 新的格式需要 NSKeyedUnarchiver 解码后才可得到与之前一致的 NSDictionary, 但是不影响正常使用.
    __weak typeof(self) weak = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        __strong typeof(weak) strong = weak;
        strong.resumeData = [self correctRequestData:resumeData];
        strong.bytesPerSecondSpeed = [NSNumber numberWithLongLong:0];
        strong.estimatedTimeRemaining = [NSNumber numberWithLongLong:0];
        if (complete) {
            // !!!: 此处使用 dispatch_after 是为了唤醒下载线程和防止写入恢复数据/读取回复数据冲突导致 fix 后台下载进度失败
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                complete();
            });
        }
    }];
}

- (void)resume {
    [self sendResumingInfo];
    
    [self removeProgressObserver];
    self.downloadTask = [self.manager.session downloadTaskWithResumeData:self.resumeData];
    [self clearResumeData];
    [self addProgressObserver];
    [self.downloadTask resume];
    
    [self sendExecutingInfo];
}

- (void)cancel {
    [self sendWillCancelldInfo];
    
    if (self.downloadTask.state == NSURLSessionTaskStateCanceling) {
        [self sendCancelldInfo];
        return;
    }
    
    [self.downloadTask cancel];
    self.bytesPerSecondSpeed = [NSNumber numberWithLongLong:0];
    self.estimatedTimeRemaining = [NSNumber numberWithLongLong:0];
}


#pragma mark - Send Info
- (void)sendIdleInfo {
    self.status = TaskStatusIdle;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didIdleTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didIdleTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidIdleNotification object:nil];
    });
}

- (void)sendPrepareInfo {
    self.status = TaskStatusPrepare;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didPrepareTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didPrepareTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidPrepareNotification object:nil];
}

- (void)sendResumingInfo {
    self.status = TaskStatusResuming;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didResumingTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didResumingTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidResumingNotification object:nil];
}

- (void)sendWillExecutingInfo {
    if ([self.delegate respondsToSelector:@selector(downloader:willExecuteTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager willExecuteTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskWillExecuteNotification object:nil];
}

- (void)sendExecutingInfo {
    self.status = TaskStatusExecuting;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didExecuteTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didExecuteTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidExecuteNotication object:nil];
    });
}

- (void)sendWillSuspendInfo {
    if ([self.delegate respondsToSelector:@selector(downloader:willSuspendTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager willSuspendTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskWillSuspendNotication object:nil];
    });
}

- (void)sendSuspendInfo {
    self.status = TaskStatusSuspend;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didSuspendTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didSuspendTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidSuspendNotication object:nil];
    });
}

- (void)sendWillCancelldInfo {
    if ([self.delegate respondsToSelector:@selector(downloader:willCanceldTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager willCanceldTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskWillCancelldNotication object:nil];
    });
}

- (void)sendCancelldInfo {
    self.status = TaskStatusCancelld;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didCancelldTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didCancelldTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidCancelldNotication object:nil];
    });
    
    if (self.manager.configure.isAutoClearTask) {
        [self.manager remove:self.url];
    }
}

- (void)sendFinishInfo {
    self.status = TaskStatusFinish;
    
    if ([self.delegate respondsToSelector:@selector(downloader:didFinishTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager didFinishTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidFinishNotication object:nil];
    });
    
    if (self.manager.configure.isAutoClearTask) {
        [self.manager remove:self.url];
    }
}

- (void)sendErrorInfo:(NSError *)error {
    self.error = error;
    self.status = TaskStatusUnknowError;
    
    if ([self.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager errorTask:self];
        });
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.statusBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
    });
}

- (void)sendProgressInfo {
    if ([self.delegate respondsToSelector:@selector(downloader:progressingTask:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager progressingTask:self];
        });
    }
    if (self.progressBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.progressBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskProgressNotication object:nil];
    });
}

- (void)sendSpeedInfo {
    if ([self.delegate respondsToSelector:@selector(downloader:speedInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloader:self.manager speedInfo:self];
        });
    }
    if (self.speedBlock) {
        __weak typeof(self) weak = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weak.speedBlock(weak);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskSpeedInfoNotication object:nil];
    });
}


#pragma mark - Description
- (NSString *)statusDescription:(TaskStatus)status {
    NSString *description = @"";
    switch (status) {
        case TaskStatusNone:
            description = @"TaskStatusNone";
            break;
            
        case TaskStatusPrepare:
            description = @"TaskStatusPrepare";
            break;
            
        case TaskStatusIdle:
            description = @"TaskStatusIdle";
            break;
            
        case TaskStatusExecuting:
            description = @"TaskStatusExecuting";
            break;
            
        case TaskStatusFinish:
            description = @"TaskStatusFinish";
            break;
            
        case TaskStatusSuspend:
            description = @"TaskStatusSuspend";
            break;
            
        case TaskStatusResuming:
            description = @"TaskStatusResuming";
            break;
            
        case TaskStatusChecking:
            description = @"TaskStatusChecking";
            break;
            
        case TaskStatusCancelld:
            description = @"TaskStatusCancelld";
            break;
            
        case TaskStatusUnknowError:
            description = @"TaskStatusUnknowError";
            break;
    }
    return description;
}


#pragma mark - Basic
- (NSString *)filePath {
    NSString *fileName = [NSString stringWithFormat:@"%@", [NSURL URLWithString:self.url].lastPathComponent];
    return [self.manager.configure.savePath stringByAppendingPathComponent:fileName];
}

- (NSString *)resumeFilePath {
    NSString *fileName = [NSString stringWithFormat:@"%@.resume", self.identifier];
    return [self.manager.configure.resumePath stringByAppendingPathComponent:fileName];
}

- (BOOL)isHasResumeData {
    return [self.manager.fileManager fileExistsAtPath:[self resumeFilePath]];
}

- (BOOL)isFinish {
    return [self.manager.fileManager fileExistsAtPath:[self filePath]];
}

- (void)clear {
    [self removeProgressObserver];
    [self clearResumeData];
    [self clearSpeedTimer];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
        self.progress.completedUnitCount = self.downloadTask.countOfBytesReceived;
    }
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
        self.progress.totalUnitCount = self.downloadTask.countOfBytesExpectedToReceive;
    }
    [self sendProgressInfo];
}


#pragma mark - Private Method
- (void)clearResumeData {
    self.resumeData = nil;
    if (self.isHasResumeData) {
        [self.manager.fileManager removeItemAtPath:[self resumeFilePath] error:nil];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> <URL: %@, status: %@>", NSStringFromClass([self class]), &self, self.url, [self statusDescription:self.status]];
}

- (NSData *)correctRequestData:(NSData *)data {
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",(long)k]] != nil) {
        k += 1;
    }
    NSInteger i = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%d", (int)(i + k)]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
        i++;
    }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%d", (int)(i + k)]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

- (NSMutableDictionary *)getResumeDictionary:(NSData *)data {
    NSMutableDictionary *iresumeDictionary = nil;
    id root = nil;
    id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    @try {
        if (@available(iOS 9.0, *)) {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
        }
        if (root == nil) {
            if (@available(iOS 9.0, *)) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        }
    } @catch(NSException *exception) { }
    [keyedUnarchiver finishDecoding];
    iresumeDictionary = [root mutableCopy];
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    return iresumeDictionary;
}

- (NSData *)correctResumeData:(NSData *)data {
    if ([[UIDevice currentDevice] systemVersion].floatValue == 10.0
        || [[UIDevice currentDevice] systemVersion].floatValue == 10.1) {
        
        NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
        NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
        if (data == nil) {
            return  nil;
        }
        NSMutableDictionary *resumeDictionary = [self getResumeDictionary:data];
        if (resumeDictionary == nil) {
            return nil;
        }
        resumeDictionary[kResumeCurrentRequest] = [self correctRequestData:resumeDictionary[kResumeCurrentRequest]];
        resumeDictionary[kResumeOriginalRequest] = [self correctRequestData:resumeDictionary[kResumeOriginalRequest]];
        NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
        return result;
    } else {
        return data;
    }
}

- (void)refreshProgerss {
    if (self.status != TaskStatusExecuting || self.downloadTask.state != NSURLSessionTaskStateRunning) {
        return;
    }
    
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    int64_t receivedCount = self.downloadTask.countOfBytesReceived - self.prevReceivedBytes;
    self.bytesPerSecondSpeed = [NSNumber numberWithDouble:(receivedCount / (now - self.prevTime))];
    self.prevTime = now;
    self.prevReceivedBytes = self.downloadTask.countOfBytesReceived;
    
    double remaining = (self.progress.totalUnitCount - self.progress.completedUnitCount) / (receivedCount?:1);
    self.estimatedTimeRemaining = [NSNumber numberWithDouble:remaining];
    
    [self sendSpeedInfo];
}

- (void)clearSpeedTimer {
    if (self.timer || !self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


#pragma mark - Getter/Setter
- (void)setUrl:(NSString *)url {
    _url = url;
    self.identifier = [url SHA256];
}

- (void)setDelegate:(id<FKTaskDelegate>)delegate {
    _delegate = delegate;
    
    switch (self.status) {
        case TaskStatusPrepare: {
            [self sendPrepareInfo];
        } break;
            
        case TaskStatusIdle: {
            [self sendIdleInfo];
        } break;
            
        case TaskStatusExecuting: {
            [self sendExecutingInfo];
        } break;
            
        case TaskStatusFinish: {
            [self sendFinishInfo];
        } break;
            
        case TaskStatusSuspend: {
            [self sendSuspendInfo];
        } break;
            
        case TaskStatusResuming: {
            [self sendResumingInfo];
        } break;
            
        case TaskStatusChecking: {
            
        } break;
            
        case TaskStatusCancelld: {
            [self sendCancelldInfo];
        } break;
            
        case TaskStatusUnknowError: {
            [self sendErrorInfo:self.error];
        } break;
            
        default:
            break;
    }
}

- (NSData *)resumeData {
    NSError *error;
    NSData *resumeData = [NSData dataWithContentsOfFile:[self resumeFilePath] options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    } else {
        return resumeData;
    }
}

- (void)setResumeData:(NSData *)resumeData {
    _resumeData = resumeData;
    [resumeData writeToFile:[self resumeFilePath] atomically:YES];
}

- (NSProgress *)progress {
    if (!_progress) {
        _progress = [[NSProgress alloc] init];
    }
    return _progress;
}

- (void)setStatus:(TaskStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}

- (NSString *)estimatedTimeRemainingDescription {
    NSString *remaining = @"";
    NSInteger seconds = self.estimatedTimeRemaining.longLongValue % 60;
    remaining = [[NSString stringWithFormat:@"%lds", (long)seconds] stringByAppendingString:remaining];
    
    NSInteger minutes = self.estimatedTimeRemaining.longLongValue / 60 % 60;
    if (minutes) {
        remaining = [[NSString stringWithFormat:@"%ldm:", (long)minutes] stringByAppendingString:remaining];
    }
    
    NSInteger hours = self.estimatedTimeRemaining.doubleValue / (60 * 60);
    if (hours) {
        remaining = [[NSString stringWithFormat:@"%ldh:", (long)hours] stringByAppendingString:remaining];
    }
    
    return [NSString stringWithFormat:@"%@", remaining];
}

- (NSString *)bytesPerSecondSpeedDescription {
    return [NSString stringWithFormat:@"%@/s", [NSByteCountFormatter stringFromByteCount:self.bytesPerSecondSpeed.longLongValue countStyle:NSByteCountFormatterCountStyleBinary]];
}

@end
