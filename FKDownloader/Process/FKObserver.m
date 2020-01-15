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
#import "FKFileManager.h"
#import "FKEngine.h"

@interface FKObserver ()

/// 请求信息
/// 结构: {"SHA256(Request.URL)": Observer.Model}
@property (nonatomic, strong) NSMapTable<NSString *, FKObserverModel *> *infoMap;

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
        count = self.blockMap.count;
        count = self.barrelMap.count;
        count = self.barrelBlockMap.count;
        count = self.barrelIndexMap.count;
    }
    return self;
}

- (void)observerDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [downloadTask addObserver:self
                   forKeyPath:@"countOfBytesReceived"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 已接收字节
    [FKLogger info:@"监听下载任务属性: countOfBytesReceived"];
    
    [downloadTask addObserver:self
                   forKeyPath:@"countOfBytesExpectedToReceive"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 总大小
    [FKLogger info:@"监听下载任务属性: countOfBytesExpectedToReceive"];
}

- (void)observerCacheWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    FKObserverModel *info = [[FKObserverModel alloc] init];
    info.requestID = downloadTask.taskDescription;
    info.countOfBytesReceived = 0;
    info.countOfBytesExpectedToReceive = 0;
    [self.infoMap setObject:info forKey:downloadTask.taskDescription];
    [FKLogger info:@"添加监听缓存"];
}

- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    // 移除前给请求信息回调发送成功回调
    [self execRequestCompleteBlock];
    
    [downloadTask removeObserver:self
                      forKeyPath:@"countOfBytesReceived"
                         context:nil];
    [FKLogger info:@"移除监听下载任务属性: countOfBytesReceived"];
    
    [downloadTask removeObserver:self
                      forKeyPath:@"countOfBytesExpectedToReceive"
                         context:nil];
    [FKLogger info:@"移除监听下载任务属性: countOfBytesExpectedToReceive"];
}

- (void)removeCacheWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
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
    [FKLogger info:@"删除监听缓存"];
}

- (void)addBlock:(MessagerInfoBlock)block requestID:(NSString *)requestID {
    if (![[FKCache cache] existRequestWithRequestID:requestID]) {
        [FKLogger info:@"任务不存在, 不添加监听缓存"];
        return;
    }
    
    if ([[FKCache cache] stateRequestWithRequestID:requestID] == FKStateComplete) {
        [FKLogger info:@"任务已完成, 不添加监听缓存"];
        return;
    }
    
    [self.blockMap setObject:block forKey:requestID];
    [FKLogger info:@"添加信息回调到监听缓存"];
    
    FKObserverModel *model = [self.infoMap objectForKey:requestID];
    block(model.countOfBytesReceived,
          model.countOfBytesExpectedToReceive,
          [[FKCache cache] stateRequestWithRequestID:requestID]);
    [FKLogger info:@"添加信息回调时进行快速响应"];
}

- (void)addBarrel:(NSString *)barrel urls:(NSArray<NSString *> *)urls {
    [self.barrelMap setObject:urls forKey:barrel];
    for (NSString *url in urls) {
        [self.barrelIndexMap setObject:barrel forKey:url];
    }
    [FKLogger info:@"添加任务集合: %@ 到监听缓存", barrel];
}

- (void)removeBarrel:(NSString *)barrel {
    NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
    for (NSString *requestID in urls) {
        [self.barrelIndexMap removeObjectForKey:requestID];
    }
    [self.barrelBlockMap removeObjectForKey:barrel];
    [self.barrelMap removeObjectForKey:barrel];
    [FKLogger info:@"从监听缓存移除任务集合: %@", barrel];
}

- (void)addBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info {
    [self.barrelBlockMap setObject:info forKey:barrel];
    [FKLogger info:@"添加任务集合: %@ 信息回调到监听缓存", barrel];
}

- (void)execRequestInfoBlock {
    // 处理单一请求的信息回调
    for (NSString *requestID in self.blockMap) {
        MessagerInfoBlock block = [self.blockMap objectForKey:requestID];
        FKObserverModel *model = [self.infoMap objectForKey:requestID];
        FKState state = [[FKCache cache] stateRequestWithRequestID:requestID];
        block(model.countOfBytesReceived,
              model.countOfBytesExpectedToReceive,
              state);
    }
    
    // 处理请求集合的信息回调
    for (NSString *barrel in self.barrelMap) {
        NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
        int64_t countOfBytesReceived = 0;
        int64_t countOfBytesExpectedToReceive = 0;
        
        for (NSString *requestID in urls) {
            FKObserverModel *model = [self.infoMap objectForKey:requestID];
            countOfBytesReceived += model.countOfBytesReceived;
            countOfBytesExpectedToReceive += model.countOfBytesExpectedToReceive;
        }
        MessagerBarrelBlock block = [self.barrelBlockMap objectForKey:barrel];
        block(countOfBytesReceived, countOfBytesExpectedToReceive);
    }
}

- (void)execRequestCompleteBlock {
    // 处理单一请求的信息回调
    for (NSString *requestID in self.blockMap) {
        MessagerInfoBlock block = [self.blockMap objectForKey:requestID];
        FKObserverModel *model = [self.infoMap objectForKey:requestID];
        block(model.countOfBytesExpectedToReceive, model.countOfBytesExpectedToReceive, FKStateComplete);
    }
    
    // 处理请求集合的信息回调
    for (NSString *barrel in self.barrelMap) {
        NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
        int64_t countOfBytesReceived = 0;
        int64_t countOfBytesExpectedToReceive = 0;
        
        for (NSString *requestID in urls) {
            FKObserverModel *model = [self.infoMap objectForKey:requestID];
            countOfBytesReceived += model.countOfBytesExpectedToReceive;
            countOfBytesExpectedToReceive += model.countOfBytesExpectedToReceive;
        }
        MessagerBarrelBlock block = [self.barrelBlockMap objectForKey:barrel];
        block(countOfBytesReceived, countOfBytesExpectedToReceive);
    }
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
        if (model.dataLength) {
            model.dataLength = info.countOfBytesExpectedToReceive;
            hasUpdate = YES;
        }
    }

    if (hasUpdate) {
        [[FKFileManager manager] updateRequestFileWithRequest:model];
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
