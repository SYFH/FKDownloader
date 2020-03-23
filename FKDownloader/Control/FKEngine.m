//
//  FKEngine.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKEngine.h"

#import "NSString+FKCategory.h"

#import "FKCache.h"
#import "FKCacheModel.h"
#import "FKConfigure.h"
#import "FKScheduler.h"
#import "FKMiddleware.h"
#import "FKObserver.h"
#import "FKLogger.h"
#import "FKSessionDelegater.h"
#import "FKFileManager.h"
#import "FKSingleNumber.h"

@interface FKEngine ()

@property (nonatomic, strong) dispatch_source_t execTimer;
@property (nonatomic, strong) dispatch_source_t distributeInfoTimer;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, assign, getter=isProcessingNextRequest) BOOL processingNextRequest;
@property (nonatomic, assign, getter=isEnterBackgrounded) BOOL enterBackgrounded;

@end

@implementation FKEngine

+ (void)load {
    [super load];
    
    [FKEngine engine];
}

+ (instancetype)engine {
    static FKEngine *instance = nil;
    static dispatch_once_t FKEngineOnceToken;
    dispatch_once(&FKEngineOnceToken, ^{
        instance = [[FKEngine alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 配置唯一编号
        [self configureSingleNumber];
        
        // 配置线程
        [self configureQueue];
        
        // 配置通知监听
        [self configureNotification];
    }
    return self;
}

- (void)configureSingleNumber {
    [[FKSingleNumber shared] initialNumberWithNumber:[[FKFileManager manager] loadSingleNumber]];
}

- (void)configureQueue {
    self.ioQueue.maxConcurrentOperationCount = 1;
    self.messagerQueue.maxConcurrentOperationCount = 6;
    
    self.timerQueue = dispatch_queue_create("com.fk.downloader.queue.timer", DISPATCH_QUEUE_SERIAL);
}

- (void)configureSession {
    [self configureBackgroundSession];
}

- (void)configureBackgroundSession {
    NSURLSessionConfiguration *backgroundConfiguration = [[FKConfigure configure].templateBackgroundConfiguration copy];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:[FKSessionDelegater delegater] delegateQueue:nil];
    [FKLogger debug:@"根据配置生成后台下载 Session"];
}

- (void)configureExecTimer {
    if (self.execTimer) {
        return;
    } else {
        __weak typeof(self) weak = self;
        self.execTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
        dispatch_source_set_timer(self.execTimer,
                                  DISPATCH_TIME_NOW,
                                  1 * NSEC_PER_SEC,
                                  0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.execTimer, ^{
            __strong typeof(weak) self = weak;
            [self execTimerAction];
        });
        dispatch_resume(self.execTimer);
    }
}

- (void)configureDistributeInfoTimer {
    if (self.distributeInfoTimer) {
        return;
    } else {
        __weak typeof(self) weak = self;
        self.distributeInfoTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
        dispatch_source_set_timer(self.distributeInfoTimer,
                                  DISPATCH_TIME_NOW,
                                  [FKConfigure configure].distributeSpeed * [FKConfigure configure].distributeTimeinterval * NSEC_PER_SEC,
                                  0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.distributeInfoTimer, ^{
            __strong typeof(weak) self = weak;
            [self distributeTimerAction];
        });
        dispatch_resume(self.distributeInfoTimer);
    }
}

- (void)configureNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationdidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationdidFinishLaunching:(NSNotification *)notify {
    [self configureSession];
    [self loadSessionRequest];
}

- (void)applicationDidEnterBackground:(NSNotification *)notify {
    self.enterBackgrounded = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notify {
    if (self.isEnterBackgrounded == NO) { return; }
    self.enterBackgrounded = NO;
    
    // iOS Version == 12.0 || 12.1
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion == 12
        && ([NSProcessInfo processInfo].operatingSystemVersion.minorVersion == 0
         || [NSProcessInfo processInfo].operatingSystemVersion.minorVersion == 1)) {
        
        [self fixProgress];
    }
}

- (void)fixProgress {
    // 暂停计时器
    if (self.execTimer) {
        dispatch_suspend(self.execTimer);
    }
    
    // 将正在执行的任务暂停再继续
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %ld", FKStateAction];
    NSArray<FKCacheRequestModel *> *requests = [[FKCache cache] requestArray];
    NSArray<FKCacheRequestModel *> *actionRequests = [requests filteredArrayUsingPredicate:predicate];
    for (FKCacheRequestModel *model in actionRequests) {
        [[FKScheduler shared] suspendRequestWithURL:model.url];
        
        // 防止恢复数据未生成而导致的恢复下载失败
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[FKScheduler shared] resumeRequestWithURL:model.url];
        });
    }
    
    // 恢复计时器
    if (self.execTimer) {
        dispatch_resume(self.execTimer);
    }
}

- (void)loadSessionRequest {
    // 加载 Session 中的任务
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *dataTasks, NSArray<NSURLSessionUploadTask *> *uploadTasks, NSArray<NSURLSessionDownloadTask *> *downloadTasks) {
        
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            // 获取本地请求缓存
            NSString *requestID = task.taskDescription;
            FKCacheRequestModel *info = [[FKCache cache] localRequestFileWithRequestID:requestID];;
            info.state = [self stateTransform:task.state];
            
            // 更新缓存
            [[FKCache cache] addRequestWithModel:info];
            [[FKCache cache] addDownloadTask:task];
            [[FKCache cache] updateLocalRequestWithModel:info];
            
            // 添加监听
            [[FKObserver observer] observerDownloadTask:task];
            [[FKObserver observer] observerCacheWithDownloadTask:task];
        }
    }];
}

- (FKState)stateTransform:(NSURLSessionTaskState)state {
    switch (state) {
        case NSURLSessionTaskStateRunning:
            return FKStateAction;
        case NSURLSessionTaskStateSuspended:
            return FKStateSuspend;
        case NSURLSessionTaskStateCanceling:
            return FKStateCancel;
        case NSURLSessionTaskStateCompleted:
            return FKStateComplete;
    }
    return FKStateIdel;
}

- (void)execTimerAction {
    // 任务: 执行下一个请求
    [self actionNextRequest];
}

- (void)distributeTimerAction {
    // 信息: 执行信息分发回调
    [self distributeRequestInfo];
}

- (void)actionNextRequest {
    if (self.isProcessingNextRequest) { return; }
    
    // 判断已执行任务数量是否到达上限
    if ([[FKCache cache] actionRequestCount] < [FKConfigure configure].maxAction) {
        self.processingNextRequest = YES;
        
        // 拿到第一个待执行任务
        FKCacheRequestModel *requestModel = [[FKCache cache] firstIdelRequest];
        if (!requestModel) {
            self.processingNextRequest = NO;
            return;
        }
        
        // 检查请求是否已存在下载任务
        if ([[FKCache cache] existDownloadTaskWithRequestID:requestModel.requestID]) {
            self.processingNextRequest = NO;
            [FKLogger debug:@"%@\n此请求已存在下载任务", requestModel.url];
            return;
        }
        
        // 检查下载是否有对应的文件
        NSString *downloadedFilePath = [[FKFileManager manager] filePathWithRequestID:requestModel.requestID];
        if ([[FKFileManager manager] fileExistsAtPath:downloadedFilePath]) {
            requestModel.state = FKStateComplete;
            [[FKCache cache] updateRequestWithModel:requestModel];
            [[FKCache cache] updateLocalRequestWithModel:requestModel];
            [FKLogger debug:@"%@\n需要下载的资源资源已存在", [FKLogger requestCacheModelDebugInfo:requestModel]];
            return;
        }
        
        // 处理请求
        NSMutableURLRequest *request = requestModel.request;
        for (id<FKRequestMiddlewareProtocol> middleware in [FKMiddleware shared].requestMiddlewareArray) {
            if ([middleware respondsToSelector:@selector(processRequest:)]) {
                request = [middleware processRequest:request];
            }
        }
        [FKLogger debug:@"%@\n%@\n对请求进行中间件处理", requestModel.request, request];
        
        // 执行请求, 添加释放时调用方法以删除 KVO
        NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
        downloadTask.taskDescription = [NSString stringWithFormat:@"%@", requestModel.requestID];
        [downloadTask resume];
        [FKLogger debug:@"%@\n根据请求创建下载任务", [FKLogger downloadTaskDebugInfo:downloadTask]];
        
        // 更新请求缓存
        requestModel.state = FKStateAction;
        [[FKCache cache] updateRequestWithModel:requestModel];
        [FKLogger debug:@"%@\nidel -> action, 更新本地请求缓存", [FKLogger requestCacheModelDebugInfo:requestModel]];
        
        // 缓存请求任务
        [[FKCache cache] addDownloadTask:downloadTask];
        [FKLogger debug:@"%@\n保存下载任务", [FKLogger requestCacheModelDebugInfo:requestModel]];
        
        // 添加 KVO
        [[FKObserver observer] observerDownloadTask:downloadTask];
        [[FKObserver observer] observerCacheWithDownloadTask:downloadTask];
        
        self.processingNextRequest = NO;
    } else {
        [FKLogger debug:@"执行任务数量已到达上限"];
        self.processingNextRequest = NO;
    }
}

- (void)distributeRequestInfo {
    [self.messagerQueue addOperationWithBlock:^{
        [[FKObserver observer] execRequestInfoBlock];
    }];
}

- (void)processCompleteDownload:(NSURLSessionDownloadTask *)downloadTask location:(NSURL *)location {
    // 获取请求缓存
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:downloadTask.taskDescription];
    
    // 移动文件到请求文件夹
    NSString *extension = info.extension;
    NSString *fileName = [NSString stringWithFormat:@"%@%@", downloadTask.taskDescription, extension];
    [[FKFileManager manager] moveFile:location toRequestFinder:downloadTask.taskDescription fileName:fileName];
    [FKLogger debug:@"%@\n移动缓存文件: %@ 到请求文件: %@", [FKLogger downloadTaskDebugInfo:downloadTask], location.absoluteURL, fileName];
    
    // 更新本地请求缓存
    info.state = FKStateComplete;
    info.extension = extension;
    [[FKCache cache] updateLocalRequestWithModel:info];
    [FKLogger debug:@"%@\naction -> complete, 更新本地任务信息", [FKLogger requestCacheModelDebugInfo:info]];
    
    // 移除监听
    [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
    [[FKObserver observer] removeDownloadTask:downloadTask];
    [[FKObserver observer] removeCacheWithDownloadTask:downloadTask];
    
    // 移除缓存任务进行释放
    [[FKCache cache] removeDownloadTask:downloadTask];
    [FKLogger debug:@"%@\n清除任务缓存", [FKLogger downloadTaskDebugInfo:downloadTask]];
}

- (void)processTask:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    NSString *requestID = task.taskDescription;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (!info) { return; }
    
    if (error) {
        // 区分错误状态
        NSInteger code = error.code;
        NSDictionary *errorUserInfo = error.userInfo;
        if (code == NSURLErrorCancelled) {
            if ([errorUserInfo.allKeys containsObject:@"NSURLSessionDownloadTaskResumeData"]) {
                // 下载任务进行带有恢复数据的暂停
                NSData *resumeData = [errorUserInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
                info.resumeData = resumeData;
                info.state = FKStateSuspend;
            } else {
                // 普通取消或不支持断点下载的链接
                info.state = FKStateCancel;
            }
        } else {
            // 其他错误, 如网路未连接, 超时, 返回数据错误等
            info.state = FKStateError;
            info.error = error;
            
            // 使用中间件处理响应
            [self processResponseMiddlewareWithTask:task error:error fromRequest:info];
        }
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:requestID];
    } else {
        // 使用中间件处理响应
        [self processResponseMiddlewareWithTask:task error:error fromRequest:info];
    }
}

- (void)processResponseMiddlewareWithTask:(NSURLSessionTask *)task error:(nullable NSError *)error fromRequest:(FKCacheRequestModel *)request {
    
    // 使用中间件处理响应
    for (id<FKResponseMiddlewareProtocol> middleware in [FKMiddleware shared].responseMiddlewareArray) {
        if ([middleware respondsToSelector:@selector(processResponse:)]) {
            FKResponse *response = [[FKResponse alloc] init];
            response.originalURL = request.url;
            response.response = task.response;
            response.filePath = [[FKCache cache] requestExpectedFilePathWithRequestID:task.taskDescription];
            response.error = error;
            [middleware processResponse:response];
        }
    }
    [FKLogger debug:@"对响应进行中间件处理"];
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)ioQueue {
    if (!_ioQueue) {
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.name = @"com.fk.queue.cache.io";
    }
    return _ioQueue;
}

- (NSOperationQueue *)messagerQueue {
    if (!_messagerQueue) {
        _messagerQueue = [[NSOperationQueue alloc] init];
        _messagerQueue.name = @"com.fk.queue.cache.messager";
    }
    return _messagerQueue;
}

@end


@implementation FKEngine (Control)

- (void)actionRequestWithURL:(NSString *)url {
    [[FKScheduler shared] actionRequestWithURL:url];
}

- (void)suspendRequestWithURL:(NSString *)url {
    [[FKScheduler shared] suspendRequestWithURL:url];
}

- (void)resumeRequestWithURL:(NSString *)url {
    [[FKScheduler shared] resumeRequestWithURL:url];
}

- (void)cancelRequestWithURL:(NSString *)url {
    [[FKScheduler shared] cancelRequestWithURL:url];
}

- (void)cancelAllRequest {
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        for (NSURLSessionDownloadTask *downloadTask in downloadTasks) {
            if (downloadTask.state == NSURLSessionTaskStateRunning) {
                [downloadTask cancel];
            }
        }
    }];
}

- (void)trashRequestWithURL:(NSString *)url {
    [[FKScheduler shared] trashRequestWithURL:url];
}

@end
