//
//  FKEngine.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FKEngine.h"

#import "FKCache.h"
#import "FKCacheModel.h"
#import "FKConfigure.h"
#import "FKScheduler.h"
#import "FKMiddleware.h"
#import "FKObserver.h"
#import "FKLogger.h"
#import "FKSessionDelegater.h"

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
        
        // 配置计时器
        [self configtureTimer];
    }
    return self;
}

- (void)configtureQueue {
    self.ioQueue.maxConcurrentOperationCount = 1;
    self.messagerQueue.maxConcurrentOperationCount = 6;
    
    self.timerQueue = dispatch_queue_create("com.fk.queue.cache.timer", DISPATCH_QUEUE_SERIAL);
}

- (void)configtureSession {
    NSURLSessionConfiguration *backgroundConfiguration = [[FKConfigure configure].templateBackgroundConfiguration copy];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration delegate:[FKSessionDelegater delegater] delegateQueue:nil];
    [FKLogger info:@"根据配置生成后台下载 Session"];
}

- (void)configtureTimer {
    __weak typeof(self) weak = self;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.timerQueue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        __strong typeof(weak) self = weak;
        [self timerAction];
    });
    dispatch_resume(self.timer);
}

- (void)loadSessionRequest {
    // 加载 Session 中的任务
    [self.backgroundSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *dataTasks, NSArray<NSURLSessionUploadTask *> *uploadTasks, NSArray<NSURLSessionDownloadTask *> *downloadTasks) {
        
        // 重新监听下载进度
        for (NSURLSessionDownloadTask *task in downloadTasks) {
            NSLog(@"%@", task.taskDescription);
        }
    }];
}

- (void)timerAction {
    [FKLogger info:@"定时器触发"];
    // 任务: 执行下一个请求
    [self actionNextRequest];
    
    // 信息: 执行信息分发回调
    [self distributeRequestInfo];
}

- (void)actionNextRequest {
    [self.ioQueue addOperationWithBlock:^{
        if (self.isProcessingNextRequest) { return; }
        
        // 判断已执行任务数量是否到达上限
        if ([[FKCache cache] actionRequestCount] < [FKConfigure configure].maxAction) {
            self.processingNextRequest = YES;
            
            // 拿到第一个待执行任务
            FKCacheRequestModel *requestModel = [[FKCache cache] firstIdelRequest];
            if (!requestModel) {
                self.processingNextRequest = NO;
                [FKLogger info:@"没有待执行任务"];
                return;
            }
            
            // 检查请求是否已存在下载任务
            if ([[FKCache cache] existDownloadTaskWithRequestID:requestModel.requestID]) {
                self.processingNextRequest = NO;
                [FKLogger info:@"此请求已存在下载任务: %@", requestModel.url];
                return;
            }
            
            // 处理请求
            NSMutableURLRequest *request = requestModel.request;
            for (id<FKRequestMiddlewareProtocol> middleware in [FKMiddleware shared].requestMiddlewareArray) {
                if ([middleware respondsToSelector:@selector(processRequest:)]) {
                    request = [middleware processRequest:request];
                }
            }
            [FKLogger info:@"请求中间件处理"];
            
            // 执行请求, 添加释放时调用方法以删除 KVO
            NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
            downloadTask.taskDescription = [NSString stringWithFormat:@"%@", requestModel.requestID];
            [downloadTask resume];
            [FKLogger info:@"根据请求创建下载任务"];
            
            // 更新请求缓存
            requestModel.state = FKStateAction;
            [[FKCache cache] updateRequestWithModel:requestModel];
            [FKLogger info:@"idel -> action, 更新请求缓存"];
            
            // 缓存请求任务
            [[FKCache cache] addDownloadTask:downloadTask];
            [FKLogger info:@"保存下载任务"];
            
            // 添加 KVO
            [[FKObserver observer] observerDownloadTask:downloadTask];
            [FKLogger info:@"监听下载任务信息"];
            
            self.processingNextRequest = NO;
        } else {
            [FKLogger info:@"执行任务数量已到达上限"];
            self.processingNextRequest = NO;
        }
    }];
}

- (void)distributeRequestInfo {
    [self.messagerQueue addOperationWithBlock:^{
        [[FKObserver observer] execRequestInfoBlock];
    }];
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
