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

@interface FKObserver ()

/// 请求信息
/// 结构: {"SHA256(Request.URL)": Observer.Model}
@property (nonatomic, strong) NSMapTable<NSString *, FKObserverModel *> *infoMap;

/// 预约信息回调, 在正式添加到 blockMap 之前的保留队列, 防止任务未开始就添加信息回调, 而导致监听缓存未添加, 回调不能保存
/// 结构: {"SHA256(Request.URL)": MessagerInfoBlock}
@property (nonatomic, strong) NSMapTable<NSString *, MessagerInfoBlock> *reserveBlockMap;

/// 信息回调
/// 结构: {"SHA256(Request.URL)": MessagerInfoBlock}
@property (nonatomic, strong) NSMapTable<NSString *, MessagerInfoBlock> *blockMap;

/// 集合任务
/// 结构: {"Barrel": Array(SHA256(Request.URL))}
@property (nonatomic, strong) NSMapTable<NSString *, NSArray<NSString *> *> *barrelMap;

/// 集合任务信息回调
/// 结构: {"Barrel": MessagerBarrelBlock}
@property (nonatomic, strong) NSMapTable<NSString *, MessagerBarrelBlock> *barrelBlockMap;

/// 任务与集合对应表
/// 结构: {SHA256(Request.URL): Barrel}
@property (nonatomic, strong) NSMapTable<NSString *, NSString *> *barrelIndexMap;

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
        NSUInteger count = self.infoMap.count;
        count = self.reserveBlockMap.count;
        count = self.blockMap.count;
        count = self.barrelMap.count;
        count = self.barrelBlockMap.count;
        count = self.barrelIndexMap.count;
    }
    return self;
}


#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSURLSessionDownloadTask *downloadTask = object;
    NSString *requestID = downloadTask.taskDescription;
    FKObserverModel *info = [self.infoMap objectForKey:requestID];
    
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
        info.countOfBytesReceived = downloadTask.countOfBytesReceived;
    }
    
    if ([keyPath isEqualToString:@"countOfBytesExpectedToReceive"]) {
        info.countOfBytesExpectedToReceive = downloadTask.countOfBytesExpectedToReceive;
        
        // 更新下载文件大小
        if (model.dataLength == 0) {
            model.dataLength = info.countOfBytesExpectedToReceive;
            hasUpdate = YES;
        } else {
            info.countOfBytesExpectedToReceive = model.dataLength;
        }
    }

    if (hasUpdate) {
        [[FKCache cache] updateRequestWithModel:model];
        [[FKCache cache] updateLocalRequestWithModel:model];
    }
}


#pragma mark - Getter/Setter
- (NSMapTable<NSString *,FKObserverModel *> *)infoMap {
    if (!_infoMap) {
        _infoMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                         valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _infoMap;
}

- (NSMapTable<NSString *,MessagerInfoBlock> *)reserveBlockMap {
    if (!_reserveBlockMap) {
        _reserveBlockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                 valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _reserveBlockMap;
}

- (NSMapTable<NSString *,MessagerInfoBlock> *)blockMap {
    if (!_blockMap) {
        _blockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                          valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _blockMap;
}

- (NSMapTable<NSString *,NSArray<NSString *> *> *)barrelMap {
    if (!_barrelMap) {
        _barrelMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                           valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _barrelMap;
}

- (NSMapTable<NSString *, MessagerBarrelBlock> *)barrelBlockMap {
    if (!_barrelBlockMap) {
        _barrelBlockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _barrelBlockMap;
}

- (NSMapTable<NSString *,NSString *> *)barrelIndexMap {
    if (!_barrelIndexMap) {
        _barrelIndexMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _barrelIndexMap;
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
    [self.infoMap setObject:info forKey:downloadTask.taskDescription];
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"添加监听缓存"];
    
    // 将预约回调添加到正式回调队列中
    if ([self.reserveBlockMap objectForKey:info.requestID]) {
        [[FKEngine engine].ioQueue addOperationWithBlock:^{
            [self.blockMap setObject:[self.reserveBlockMap objectForKey:info.requestID] forKey:info.requestID];
            [self.reserveBlockMap removeObjectForKey:info.requestID];
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
        [self.infoMap removeObjectForKey:downloadTask.taskDescription];
        [self.blockMap removeObjectForKey:downloadTask.taskDescription];
        
        NSString *barrel = [self.barrelIndexMap objectForKey:downloadTask.taskDescription];
        if (barrel.length) {// 有所属集合
            NSMutableArray<NSString *> *urls = [NSMutableArray arrayWithArray:[self.barrelMap objectForKey:barrel]];
            [urls removeObject:downloadTask.taskDescription];
            if (urls.count == 0) {
                [self.barrelMap removeObjectForKey:barrel];
                [self.barrelBlockMap removeObjectForKey:barrel];
                [self.barrelIndexMap removeObjectForKey:downloadTask.taskDescription];
            } else {
                [self.barrelMap setObject:[NSArray arrayWithArray:urls] forKey:barrel];
                [self.barrelIndexMap removeObjectForKey:downloadTask.taskDescription];
            }
        }
    }];
    [FKLogger debug:@"%@\n%@", [FKLogger downloadTaskDebugInfo:downloadTask], @"删除监听缓存"];
}

- (void)removeCacheProgressWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        FKObserverModel *info = [self.infoMap objectForKey:downloadTask.taskDescription];
        info.countOfBytesReceived = 0;
        [self.infoMap setObject:info forKey:downloadTask.taskDescription];
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
    
    if ([[FKCache cache] stateRequestWithRequestID:requestID] == FKStateComplete) {
        [FKLogger debug:@"%@\n%@", requestID, @"任务已完成, 不添加监听缓存"];
        return;
    }
    
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.reserveBlockMap setObject:block forKey:requestID];
    }];
    [FKLogger debug:@"%@\n%@", requestID, @"添加信息回调到监听缓存"];
    
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        FKObserverModel *model = [self.infoMap objectForKey:requestID];
        NSError *error = [[FKCache cache] errorRequestWithRequestID:requestID];
        block(model.countOfBytesReceived,
              model.countOfBytesExpectedToReceive,
              [[FKCache cache] stateRequestWithRequestID:requestID],
              error);
    }];
    [FKLogger debug:@"%@\n%@", requestID, @"添加信息回调时进行快速响应"];
}

- (void)addBarrel:(NSString *)barrel urls:(NSArray<NSString *> *)urls {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.barrelMap setObject:urls forKey:barrel];
        for (NSString *url in urls) {
            [self.barrelIndexMap setObject:barrel forKey:url];
        }
    }];
    [FKLogger debug:@"添加任务集合: %@ 到监听缓存", barrel];
}

- (void)removeBarrel:(NSString *)barrel {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
        for (NSString *requestID in urls) {
            [self.barrelIndexMap removeObjectForKey:requestID];
        }
        [self.barrelBlockMap removeObjectForKey:barrel];
        [self.barrelMap removeObjectForKey:barrel];
    }];
    [FKLogger debug:@"从监听缓存移除任务集合: %@", barrel];
}

- (void)addBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.barrelBlockMap setObject:info forKey:barrel];
    }];
    [FKLogger debug:@"添加任务集合: %@ 信息回调到监听缓存", barrel];
}

@end


@implementation FKObserver (Exec)

- (void)execFastInfoBlockWithRequestID:(NSString *)requestID {
    MessagerInfoBlock block = [self.blockMap objectForKey:requestID];
    if (block) {
        FKObserverModel *model = [self.infoMap objectForKey:requestID];
        NSError *error = [[FKCache cache] errorRequestWithRequestID:requestID];
        FKState state = [[FKCache cache] stateRequestWithRequestID:requestID];
        block(model.countOfBytesReceived,
        model.countOfBytesExpectedToReceive,
        state,
        error);
    }
}

- (void)execRequestInfoBlock {
    // 处理单一请求的信息回调
    for (NSString *requestID in self.blockMap) {
        MessagerInfoBlock block = [self.blockMap objectForKey:requestID];
        if (block) {
            FKObserverModel *model = [self.infoMap objectForKey:requestID];
            NSError *error = [[FKCache cache] errorRequestWithRequestID:requestID];
            FKState state = [[FKCache cache] stateRequestWithRequestID:requestID];
            block(model.countOfBytesReceived,
                  model.countOfBytesExpectedToReceive,
                  state,
                  error);
        }
    }
    
    // 处理请求集合的信息回调
    for (NSString *barrel in self.barrelMap) {
        MessagerBarrelBlock block = [self.barrelBlockMap objectForKey:barrel];
        if (block) {
            NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
            int64_t countOfBytesReceived = 0;
            int64_t countOfBytesExpectedToReceive = 0;
            
            for (NSString *requestID in urls) {
                FKObserverModel *model = [self.infoMap objectForKey:requestID];
                countOfBytesReceived += model.countOfBytesReceived;
                countOfBytesExpectedToReceive += model.countOfBytesExpectedToReceive;
            }
            block(countOfBytesReceived, countOfBytesExpectedToReceive);
        }
    }
}

@end
