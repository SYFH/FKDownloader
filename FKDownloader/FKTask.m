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

FKNotificationName const FKTaskWillExecuteNotification  = @"FKTaskWillExecuteNotification";
FKNotificationName const FKTaskDidExecuteNotication     = @"FKTaskDidExecuteNotication";
FKNotificationName const FKTaskProgressNotication       = @"FKTaskProgressNotication";
FKNotificationName const FKTaskDidFinishNotication      = @"FKTaskDidFinishNotication";
FKNotificationName const FKTaskErrorNotication          = @"FKTaskErrorNotication";
FKNotificationName const FKTaskWillSuspendNotication    = @"FKTaskWillSuspendNotication";
FKNotificationName const FKTaskDidSuspendNotication     = @"FKTaskDidSuspendNotication";
FKNotificationName const FKTaskWillCancelldNotication   = @"FKTaskWillCancelldNotication";
FKNotificationName const FKTaskDidCancelldNotication    = @"FKTaskDidCancelldNotication";

@interface FKTask ()

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString    *identifier;
@property (nonatomic, strong) NSProgress  *progress;
@property (nonatomic, strong) NSData      *resumeData;

@property (nonatomic, assign) NSTimeInterval    prevReceiveDate;
@property (nonatomic, strong) NSString          *speed;

@end

@implementation FKTask
@synthesize resumeData = _resumeData;

- (void)restore:(NSURLSessionDownloadTask *)task {
    [self clear];
    self.downloadTask = task;
    [self addProgressObserver];
    
    switch (task.state) {
        case NSURLSessionTaskStateRunning:
            self.status = TaskStatusExecuting;
            break;
            
        case NSURLSessionTaskStateSuspended:
            // !!!: 根据配置判断是否需要自动开始任务, 目前看不需要, 后台任务没有暂停状态
            self.status = TaskStatusSuspend;
            break;
            
        case NSURLSessionTaskStateCanceling:
            // TODO: iOS 12/12.1 BUG: 后台下载异常停止, 状态码为 Cancelld, 需要识别是否有恢复数据, 继续下载
            // TODO: 根据本地是否有恢复数据来判断是否继续下载
            self.status = TaskStatusCancelld;
            break;
            
        case NSURLSessionTaskStateCompleted:
            // TODO: 暂停后重启 app, task.status 会标识为 Completed, 需要矫正
            self.status = TaskStatusFinish;
            break;
    }
}

- (void)reday {
    self.status = TaskStatusPrepare;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    if ([self.manager.fileManager fileExistsAtPath:[self resumeFilePath]]) {
        [self removeProgressObserver];
        self.downloadTask = [self.manager.session downloadTaskWithResumeData:[self resumeData]];
        [self clearResumeData];
    } else {
        self.downloadTask = [self.manager.session downloadTaskWithRequest:request];
    }
    
    [self addProgressObserver];
    self.speed = [NSString stringWithFormat:@"%@/s", [NSByteCountFormatter stringFromByteCount:0 countStyle:NSByteCountFormatterCountStyleBinary]];
    
    if ([self.delegate respondsToSelector:@selector(downloader:willExecuteTask:)]) {
        [self.delegate downloader:self.manager willExecuteTask:self];
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        self.statusBlock(weak);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskWillExecuteNotification object:nil];
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
    if (self.isHasResumeData) {
        [self resume];
    } else {
        [self.downloadTask resume];
        self.status = TaskStatusExecuting;
    }
    
    if ([self.delegate respondsToSelector:@selector(downloader:didExecuteTask:)]) {
        [self.delegate downloader:self.manager didExecuteTask:self];
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        self.statusBlock(weak);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidExecuteNotication object:nil];
}

- (void)suspend {
    if ([self.delegate respondsToSelector:@selector(downloader:willSuspendTask:)]) {
        [self.delegate downloader:self.manager willSuspendTask:self];
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        self.statusBlock(weak);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskWillSuspendNotication object:nil];
    
    // TODO: iOS 10.2 系统生成的 resumeData 数据异常, 需要修正
    __weak typeof(self) weak = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        __strong typeof(weak) strong = weak;
        strong.resumeData = resumeData;
    }];
}

- (void)resume {
    self.status = TaskStatusResuming;
    [self removeProgressObserver];
    self.downloadTask = [self.manager.session downloadTaskWithResumeData:self.resumeData];
    [self clearResumeData];
    [self addProgressObserver];
    [self.downloadTask resume];
    self.status = TaskStatusExecuting;
}

- (void)cancel {
    if ([self.delegate respondsToSelector:@selector(downloader:willCanceldTask:)]) {
        [self.delegate downloader:self.manager willCanceldTask:self];
    }
    if (self.statusBlock) {
        __weak typeof(self) weak = self;
        self.statusBlock(weak);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskWillCancelldNotication object:nil];
    
    [self.downloadTask cancel];
}

- (void)sendProgressInfo {
    if ([self.delegate respondsToSelector:@selector(downloader:progressingTask:)]) {
        [self.delegate downloader:self.manager progressingTask:self];
    }
    if (self.progressBlock) {
        __weak typeof(self) weakTask = self;
        self.progressBlock(weakTask);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskProgressNotication object:nil];
}

- (NSString *)filePath {
    NSString *fileName = [NSString stringWithFormat:@"%@", [NSURL URLWithString:self.url].lastPathComponent];
    return [self.manager.configure.resumePath stringByAppendingPathComponent:fileName];
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
}

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


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([object isKindOfClass:[self.downloadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            NSTimeInterval now = [NSDate date].timeIntervalSince1970;
            NSTimeInterval time = now - self.prevReceiveDate;
            int64_t receivCount = self.downloadTask.countOfBytesReceived - self.progress.completedUnitCount;
            double speed = receivCount / time;
            self.speed = [NSString stringWithFormat:@"%@/s", [NSByteCountFormatter stringFromByteCount:(long long)speed countStyle:NSByteCountFormatterCountStyleBinary]];
            self.prevReceiveDate = now;
            
            self.progress.completedUnitCount = self.downloadTask.countOfBytesReceived;
        }
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
            self.progress.totalUnitCount = self.downloadTask.countOfBytesExpectedToReceive;
        }
        [self sendProgressInfo];
    }
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


#pragma mark - Getter/Setter
- (void)setUrl:(NSString *)url {
    _url = url;
    self.identifier = [url SHA256];
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

@end
