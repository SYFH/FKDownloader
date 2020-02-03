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

@interface FKEngine ()

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, assign, getter=isProcessingNextRequest) BOOL processingNextRequest;

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
        // 配置线程
        [self configtureQueue];
        
        // 配置通知监听
        [self configtureNotification];
    }
    return self;
}

- (void)configtureQueue {
    self.ioQueue.maxConcurrentOperationCount = 1;
    self.messagerQueue.maxConcurrentOperationCount = 6;
    
    self.timerQueue = dispatch_queue_create("com.fk.downloader.queue.timer", DISPATCH_QUEUE_SERIAL);
}

- (void)configtureSession {
    NSURLSessionConfiguration *backgroundConfiguration = [[FKConfigure configure].templateBackgroundConfiguration copy];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:[FKSessionDelegater delegater] delegateQueue:nil];
    [FKLogger debug:@"根据配置生成后台下载 Session"];
}

- (void)configtureTimer {
    if (self.timer) {
        return;
    } else {
        __weak typeof(self) weak = self;
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer, ^{
            __strong typeof(weak) self = weak;
            [self timerAction];
        });
        dispatch_resume(self.timer);
    }
}

- (void)configtureNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationdidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)applicationdidFinishLaunching:(NSNotification *)notify {
    [self configtureSession];
    [self loadSessionRequest];
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

- (void)timerAction {
    // 任务: 执行下一个请求
    [self actionNextRequest];
    
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


#pragma mark - Getter/Setter
- (NSOperationQueue *)ioQueue {
    if (!_ioQueue) {
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.name = @"com.fk.queue.cache.io";
    }
    return _ioQueue;
}

- (NSOperationQueue *)messagerQueue {
    if (!_ioQueue) {
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.name = @"com.fk.queue.cache.messager";
    }
    return _ioQueue;
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
            [downloadTask cancel];
        }
    }];
}

@end
