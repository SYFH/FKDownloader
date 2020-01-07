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

static void taskCleanup(__strong NSURLSessionDownloadTask **task) {
    [[FKObserver observer] removeDownloadTask:*task];
}

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
        self.ioQueue.maxConcurrentOperationCount = 1;
        self.timerQueue.maxConcurrentOperationCount = 1;
        
        // 配置计时器
        [self configtureTimer];
    }
    return self;
}

- (void)configtureSession {
    NSURLSessionConfiguration *backgroundConfiguration = [[FKConfigure configure].templateBackgroundConfiguration copy];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration];
}

- (void)configtureTimer {
    __weak typeof(self) weak = self;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
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
    // 任务: 执行下一个请求
    __weak typeof(self) weak = self;
    [[FKCache cache] actionRequestCountWithComplete:^(NSUInteger count) {
        __strong typeof(weak) self = weak;
        if (self.isProcessingNextRequest) { return; }
        
        if (count < [FKConfigure configure].maxAction) {
            self.processingNextRequest = YES;
            // 排序待执行请求
            NSSortDescriptor *requestSort = [NSSortDescriptor sortDescriptorWithKey:@"idx" ascending:YES];
            FKCacheRequestModel *requestModel = [[[[FKCache cache] requestArray] sortedArrayUsingDescriptors:@[requestSort]] firstObject];
            
            // 检查是否存在下载任务
            __block BOOL isExistDownloadTasl = NO;
            [[FKCache cache] existDownloadTaskWithRequestID:requestModel.requestID complete:^(BOOL exist) {
                isExistDownloadTasl = exist;
            }];
            if (isExistDownloadTasl) { return; }
            
            // 排序请求中间件
            NSSortDescriptor *requestMiddlewareSort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
            NSArray<id<FKRequestMiddlewareProtocol>> *middlewares = [[FKMiddleware shared].requestMiddlewareArray sortedArrayUsingDescriptors:@[requestMiddlewareSort]];
            
            // 处理请求
            NSMutableURLRequest *request = requestModel.request;
            for (id<FKRequestMiddlewareProtocol> middleware in middlewares) {
                if ([middleware respondsToSelector:@selector(processRequest:)]) {
                    request = [middleware processRequest:request];
                }
            }
            
            // 执行请求, 添加释放时调用方法以删除 KVO
            NSURLSessionDownloadTask *downloadTask __attribute__((cleanup(taskCleanup))) = [self.backgroundSession downloadTaskWithRequest:request];
            downloadTask.taskDescription = [NSString stringWithFormat:@"%@", requestModel.requestID];
            
            // 缓存请求任务
            [[FKCache cache] addDownloadTask:downloadTask];
            
            // 添加 KVO
            [[FKObserver observer] observerDownloadTask:downloadTask];
            
            self.processingNextRequest = NO;
        }
    }];
    
    // 信息: 执行信息分发回调
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)ioQueue {
    if (!_ioQueue) {
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.name = @"com.fk.queue.cache.io";
    }
    return _ioQueue;
}

- (NSOperationQueue *)timerQueue {
    if (!_timerQueue) {
        _timerQueue = [[NSOperationQueue alloc] init];
        _timerQueue.name = @"com.fk.queue.cache.timer";
    }
    return _timerQueue;
}

@end
