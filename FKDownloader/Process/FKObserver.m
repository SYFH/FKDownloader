//
//  FKObserver.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKObserver.h"

#import "NSString+FKCategory.h"

#import "FKCache.h"
#import "FKCacheModel.h"
#import "FKObserverModel.h"
#import "FKLogger.h"
#import "FKEngine.h"
#import "FKMiddleware.h"

@interface FKObserver ()

@end

@implementation FKObserver

+ (instancetype)observer {
    static FKObserver *instance = nil;
    static dispatch_once_t FKObserverOnceToken;
    dispatch_once(&FKObserverOnceToken, ^{
        instance = [[FKObserver alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSURLSessionDownloadTask *downloadTask = object;
    NSString *requestID = downloadTask.taskDescription;
    FKObserverModel *info = [[FKCache cache] observerInfoWithRequestID:requestID];
    
    // 更新下载文件后缀
    BOOL hasUpdate = NO;
    FKCacheRequestModel *model = [[FKCache cache] requestWithRequestID:requestID];
    if (model.extension.length == 0) {
        NSString *fileExtension = downloadTask.response.MIMEType.toExtension;
        if (fileExtension.length) {
            model.extension = [NSString stringWithFormat:@".%@", fileExtension];
        } else {
            model.extension = @"";
        }
        hasUpdate = YES;
    }

    if ([keyPath isEqualToString:@"countOfBytesReceived"]) {
        info.countOfBytesPreviousReceived = info.countOfBytesReceived;
        info.countOfBytesAccumulateReceived += downloadTask.countOfBytesReceived - info.countOfBytesReceived;
        info.countOfBytesReceived = downloadTask.countOfBytesReceived;
    }
    
    if ([keyPath isEqualToString:@"countOfBytesExpectedToReceive"]) {
        info.countOfBytesExpectedToReceive = downloadTask.countOfBytesExpectedToReceive;
        
        // 更新下载文件总大小
        if (model.dataLength == 0) {
            model.dataLength = info.countOfBytesExpectedToReceive;
            hasUpdate = YES;
        } else {
            info.countOfBytesExpectedToReceive = model.dataLength;
        }
    }
    
    // 下载中间件返回任务进度
    for (id<FKDownloadMiddlewareProtocol> middleware in [[FKMiddleware shared] downloadMiddlewareArray]) {
        if ([middleware respondsToSelector:@selector(downloadURL:countOfBytesReceived:countOfBytesPreviousReceived:countOfBytesExpectedToReceive:)]) {
            
            [middleware downloadURL:model.url countOfBytesReceived:info.countOfBytesReceived countOfBytesPreviousReceived:info.countOfBytesPreviousReceived countOfBytesExpectedToReceive:info.countOfBytesExpectedToReceive];
        }
    }

    if (hasUpdate) {
        [[FKCache cache] updateRequestWithModel:model];
        [[FKCache cache] updateLocalRequestWithModel:model];
    }
}

@end


@implementation FKObserver (Observer)

- (void)observerDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [downloadTask addObserver:self
                   forKeyPath:@"countOfBytesReceived"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 已接收字节
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"监听属性: countOfBytesReceived"];
    
    [downloadTask addObserver:self
                   forKeyPath:@"countOfBytesExpectedToReceive"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 总大小
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"监听属性: countOfBytesExpectedToReceive"];
}

- (void)observerCacheWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    FKObserverModel *info = [[FKObserverModel alloc] init];
    info.requestID = downloadTask.taskDescription;
    info.countOfBytesReceived = 0;
    info.countOfBytesExpectedToReceive = 0;
    [[FKCache cache] addObserverInfo:info forRequestID:downloadTask.taskDescription];
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"添加监听缓存"];
    
    // 将预约回调添加到正式回调队列中
    if ([[FKCache cache] reserveObserverBlockWithRequestID:info.requestID]) {
        [[FKEngine engine].ioQueue addOperationWithBlock:^{
            [[FKCache cache] addObserverBlock:[[FKCache cache] reserveObserverBlockWithRequestID:info.requestID] forRequestID:info.requestID];
            [[FKCache cache] removeReserveObserverBlockWithRequestID:info.requestID];
        }];
    }
    [FKLogger debug:@"%@\n%@", info.requestID, @"将预约回调移动到正式回调队列中"];
}

- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    @try {
        [downloadTask removeObserver:self
                          forKeyPath:@"countOfBytesReceived"
                             context:nil];
        [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"移除监听属性: countOfBytesReceived"];
        
        [downloadTask removeObserver:self
                          forKeyPath:@"countOfBytesExpectedToReceive"
                             context:nil];
    } @catch (NSException *exception) {
        
    } @finally {
        [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"移除监听属性: countOfBytesExpectedToReceive"];
    }
}

- (void)removeCacheWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [[FKCache cache] removeObserverInfoWithRequestID:downloadTask.taskDescription];
        [[FKCache cache] removeObserverBlockWithRequestID:downloadTask.taskDescription];
        
        NSString *barrel = [[FKCache cache] observerBarrelIndexWithRequestID:downloadTask.taskDescription];
        if (barrel.length) {// 有所属集合
            NSMutableArray<NSString *> *urls = [NSMutableArray arrayWithArray:[[FKCache cache] observerBarrelWithBarrel:barrel]];
            [urls removeObject:downloadTask.taskDescription];
            if (urls.count == 0) {
                [[FKCache cache] removeObserverBarrelWithBarrel:barrel];
                [[FKCache cache] removeObserverBarrelBlockWithBarrel:barrel];
                [[FKCache cache] removeObserverBarrelIndexWithRequestID:downloadTask.taskDescription];
            } else {
                [[FKCache cache] addObserverBarrelWithURLs:[NSArray arrayWithArray:urls] forBarrel:barrel];
                [[FKCache cache] removeObserverBarrelIndexWithRequestID:downloadTask.taskDescription];
            }
        }
    }];
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"删除监听缓存"];
}

- (void)removeCacheProgressWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        FKObserverModel *info = [[FKCache cache] observerInfoWithRequestID:downloadTask.taskDescription];
        info.countOfBytesReceived = 0;
        [[FKCache cache] removeObserverInfoWithRequestID:downloadTask.taskDescription];
    }];
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"删除任务缓存的进度数据"];
}

- (void)removeObserverWithRequestID:(NSString *)requestID {
    NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
    if (downloadTask) {
        [[FKObserver observer] removeDownloadTask:downloadTask];
        [[FKObserver observer] removeCacheWithDownloadTask:downloadTask];
    }
}

@end


@implementation FKObserver (Block)

- (void)addBlock:(MessagerInfoBlock)block requestID:(NSString *)requestID {
    if (![[FKCache cache] existRequestWithRequestID:requestID]) {
        [FKLogger debug:@"%@\n%@", requestID, @"任务不存在, 不添加监听缓存"];
        return;
    }
    
    // 防止任务未完成预处理就立即添加信息回调, 导致回调不能保存的问题
    // 预约回调会在添加进度监听后转移到正式队列中, 所以以监听缓存是否存在为判断标准
    if ([[FKCache cache] observerInfoWithRequestID:requestID]
        || [[FKCache cache] requestWithRequestID:requestID].state != FKStateAction) {
        
        [[FKEngine engine].ioQueue addOperationWithBlock:^{
            [[FKCache cache] addObserverBlock:block forRequestID:requestID];
        }];
    } else {
        [[FKEngine engine].ioQueue addOperationWithBlock:^{
            [[FKCache cache] addReserveObserverBlock:block forRequestID:requestID];
        }];
    }
    [FKLogger debug:@"%@\n%@", requestID, @"添加信息回调到监听缓存"];
    
    [[FKObserver observer] execFastInfoBlockWithRequestID:requestID];
    [FKLogger debug:@"%@\n%@", requestID, @"添加信息回调时进行快速响应"];
}

- (void)removeBlockWithRequestID:(NSString *)requestID {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [[FKCache cache] removeObserverBlockWithRequestID:requestID];
        [[FKCache cache] removeReserveObserverBlockWithRequestID:requestID];
    }];
    [FKLogger debug:@"%@\n%@", requestID, @"从监听缓存移除信息回调"];
}

- (void)addBarrel:(NSString *)barrel urls:(NSArray<NSString *> *)urls {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [[FKCache cache] addObserverBarrelWithURLs:urls forBarrel:barrel];
        for (NSString *url in urls) {
            [[FKCache cache] addObserverBarrelIndex:barrel forURL:url];
        }
    }];
    [FKLogger debug:@"添加任务集合: %@ 到监听缓存", barrel];
}

- (void)addURL:(NSString *)url fromBarrel:(NSString *)barrel {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [[FKCache cache] addURL:url fromObserverBarrel:barrel];
        [[FKCache cache] addObserverBarrelIndex:barrel forURL:url];
    }];
    [FKLogger debug:@"添加链接: %@ 到任务集合: %@", url, barrel];
}

- (void)removeURL:(NSString *)url fromBarrel:(NSString *)barrel {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [[FKCache cache] removeURL:url fromObserverBarrel:barrel];
        [[FKCache cache] removeObserverBarrelIndexWithRequestID:url];
    }];
    [FKLogger debug:@"从任务集合: %@ 移除链接: %@", barrel, url];
}

- (void)removeBarrel:(NSString *)barrel {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSArray<NSString *> *urls = [[FKCache cache] observerBarrelWithBarrel:barrel];
        for (NSString *requestID in urls) {
            [[FKCache cache] removeObserverBarrelIndexWithRequestID:requestID];
        }
        [[FKCache cache] removeObserverBarrelBlockWithBarrel:barrel];
        [[FKCache cache] removeObserverBarrelWithBarrel:barrel];
    }];
    [FKLogger debug:@"从监听缓存移除任务集合: %@", barrel];
}

- (void)addBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [[FKCache cache] addObserverBarrelBlock:info forBarrel:barrel];
    }];
    [FKLogger debug:@"添加任务集合: %@ 信息回调到监听缓存", barrel];
}

- (NSArray<NSString *> *)acquireURLsWithBarrel:(NSString *)barrel {
    __block NSArray<NSString *> *urls = [NSArray array];
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        urls = [[FKCache cache] observerBarrelWithBarrel:barrel];
    }]] waitUntilFinished:YES];
    return urls;
}

@end


@implementation FKObserver (Exec)

- (void)execFastInfoBlockWithRequestID:(NSString *)requestID {
    [[FKEngine engine].messagerQueue addOperationWithBlock:^{
        MessagerInfoBlock block = [[FKCache cache] observerBlockWithRequestID:requestID];
        if (block) {
            FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
            FKObserverModel *model = [[FKCache cache] observerInfoWithRequestID:requestID];
            NSError *error = [[FKCache cache] errorRequestWithRequestID:requestID];
            FKState state = [[FKCache cache] stateRequestWithRequestID:requestID];
            if (block) {
                block(MAX(model.countOfBytesReceived, info.receivedLength),
                      model.countOfBytesReceived - model.countOfBytesAccumulateReceived,
                      MAX(model.countOfBytesExpectedToReceive, info.dataLength),
                      state,
                      error);
                model.countOfBytesAccumulateReceived = 0;
            }
        }
    }];
}

- (void)execRequestInfoBlock {
    // 处理单一请求的信息回调
    for (NSString *requestID in [[FKCache cache] observerBlockTable]) {
        MessagerInfoBlock block = [[FKCache cache] observerBlockWithRequestID:requestID];
        if (block) {
            FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
            FKObserverModel *model = [[FKCache cache] observerInfoWithRequestID:requestID];
            NSError *error = [[FKCache cache] errorRequestWithRequestID:requestID];
            FKState state = [[FKCache cache] stateRequestWithRequestID:requestID];
            
            block(MAX(model.countOfBytesReceived, info.receivedLength),
                  model.countOfBytesReceived - model.countOfBytesAccumulateReceived,
                  MAX(model.countOfBytesExpectedToReceive, info.dataLength),
                  state,
                  error);
            model.countOfBytesAccumulateReceived = 0;
        }
    }
    
    // 处理请求集合的信息回调
    for (NSString *barrel in [[FKCache cache] observerBarrelTable]) {
        MessagerBarrelBlock block = [[FKCache cache] observerBarrelBlockWithBarrel:barrel];
        if (block) {
            NSArray<NSString *> *urls = [[FKCache cache] observerBarrelWithBarrel:barrel];
            int64_t countOfBytesReceived = 0;
            int64_t countOfBytesPreviousReceived = 0;
            int64_t countOfBytesExpectedToReceive = 0;
            
            for (NSString *requestID in urls) {
                FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
                FKObserverModel *model = [[FKCache cache] observerInfoWithRequestID:requestID];
                countOfBytesReceived += MAX(model.countOfBytesReceived, info.receivedLength);
                countOfBytesPreviousReceived += model.countOfBytesReceived -model.countOfBytesAccumulateReceived;
                countOfBytesExpectedToReceive += MAX(model.countOfBytesExpectedToReceive, info.dataLength);
                model.countOfBytesAccumulateReceived = 0;
            }
            block(countOfBytesReceived, countOfBytesPreviousReceived, countOfBytesExpectedToReceive);
        }
    }
}

- (void)execAcquireInfo:(MessagerInfoBlock)info requestID:(NSString *)requestID {
    FKCacheRequestModel *cacheModel = [[FKCache cache] requestWithRequestID:requestID];
    if (info && cacheModel) {
        FKObserverModel *model = [[FKCache cache] observerInfoWithRequestID:requestID];
        NSError *error = [[FKCache cache] errorRequestWithRequestID:requestID];
        FKState state = [[FKCache cache] stateRequestWithRequestID:requestID];
        info(MAX(model.countOfBytesReceived, cacheModel.receivedLength),
             model.countOfBytesAccumulateReceived,
             MAX(model.countOfBytesExpectedToReceive, cacheModel.dataLength),
             state,
             error);
    }
}

@end
