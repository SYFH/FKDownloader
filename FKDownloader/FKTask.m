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

@end

@implementation FKTask
@synthesize resumeData = _resumeData;

- (void)restore:(NSURLSessionDownloadTask *)task {
    [self clear];
    self.downloadTask = task;
    [self addProgressObserver];
    
    // TODO: 暂停后重启 app, task.status 会标识为 Completed, 需要矫正
    switch (task.state) {
        case NSURLSessionTaskStateRunning:
            self.status = TaskStatusExecuting;
            break;
            
        case NSURLSessionTaskStateSuspended:
            // TODO: 根据配置判断是否需要自动开始任务
            self.status = TaskStatusSuspend;
            break;
            
        case NSURLSessionTaskStateCanceling:
            // TODO: iOS 12/12.1 BUG: 后台下载异常停止, 状态码为 Cancelld, 需要识别是否有恢复数据, 继续下载
            // TODO: 根据本地是否有恢复数据来判断是否继续下载
            self.status = TaskStatusCancelld;
            break;
            
        case NSURLSessionTaskStateCompleted:
            self.status = TaskStatusFinish;
            break;
    }
}

- (void)reday {
    self.status = TaskStatusPrepare;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    if ([self.manager.fileManager fileExistsAtPath:[self resumeFilePath]]) {
        [self removeProgressObserver];
        // TODO: 使用过 resumeData 后, 需删除
        self.downloadTask = [self.manager.session downloadTaskWithResumeData:[self resumeData]];
    } else {
        self.downloadTask = [self.manager.session downloadTaskWithRequest:request];
    }
    
    [self addProgressObserver];
    
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
    if ([self.manager.fileManager fileExistsAtPath:[self resumeFilePath]]) {
        [self removeProgressObserver];
        // TODO: 使用过 resumeData 后, 需删除
        self.downloadTask = [self.manager.session downloadTaskWithResumeData:[self resumeData]];
        [self addProgressObserver];
    }
    [self.downloadTask resume];
    self.status = TaskStatusExecuting;
    
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
    
    __weak typeof(self) weak = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        __strong typeof(weak) strong = weak;
        strong.resumeData = resumeData;
    }];
}

// TODO: 使用过 resumeData 后, 需删除
- (void)resume {
    self.status = TaskStatusResuming;
    [self removeProgressObserver];
    self.downloadTask = [self.manager.session downloadTaskWithResumeData:self.resumeData];
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

- (void)clear {
    [self removeProgressObserver];
}

- (NSString *)statusDescription:(TaskStatus)status {
    NSString *description = @"";
    switch (status) {
        case TaskStatusNone:
            description = @"已加入下载列表";
            break;
            
        case TaskStatusPrepare:
            description = @"预处理";
            break;
            
        case TaskStatusIdle:
            description = @"等待下载";
            break;
            
        case TaskStatusExecuting:
            description = @"下载中";
            break;
            
        case TaskStatusFinish:
            description = @"下载完成";
            break;
            
        case TaskStatusSuspend:
            description = @"已暂停";
            break;
            
        case TaskStatusResuming:
            description = @"恢复中";
            break;
            
        case TaskStatusChecking:
            description = @"校验中";
            break;
            
        case TaskStatusCancelld:
            description = @"已取消";
            break;
            
        case TaskStatusUnknowError:
            description = @"未知错误";
            break;
    }
    return description;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([object isKindOfClass:[self.downloadTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            self.progress.completedUnitCount = self.downloadTask.countOfBytesReceived;
        }
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
            self.progress.totalUnitCount = self.downloadTask.countOfBytesExpectedToReceive;
        }
        [self sendProgressInfo];
    }
}


#pragma mark - Private Method



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
