//
//  FKCache.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKCache.h"

#import "NSString+FKCategory.h"

#import "FKFileManager.h"
#import "FKCacheModel.h"
#import "FKEngine.h"

@interface FKCache ()

#pragma mark - Request
/// 请求表, 包含所有请求信息, {SingleNumber_SHA256(Request.URL): Cache.Request.Model}
@property (nonatomic, strong) NSMapTable<NSString *, FKCacheRequestModel *> *requestMap;

/// 任务表, 包含所有下载任务, {SingleNumber_SHA256(Request.URL): Download.Task}
@property (nonatomic, strong) NSMapTable<NSString *, NSURLSessionDownloadTask *> *taskMap;

/// 请求索引表, {SHA256(Request.URL): SingleNumber_SHA256(Request.URL)}
@property (nonatomic, strong) NSMapTable<NSString *, NSString *> *requestIndexMap;


#pragma mark - Oberser
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

@implementation FKCache

+ (instancetype)cache {
    static FKCache *instance = nil;
    static dispatch_once_t FKCacheOnceToken;
    dispatch_once(&FKCacheOnceToken, ^{
        instance = [[FKCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 显式初始化
        NSUInteger count = self.requestMap.count;
        count = self.requestIndexMap.count;
        count = self.taskMap.count;
        count = self.infoMap.count;
        count = self.reserveBlockMap.count;
        count = self.blockMap.count;
        count = self.barrelMap.count;
        count = self.barrelBlockMap.count;
        count = self.barrelIndexMap.count;
    }
    return self;
}


#pragma mark - Getter/Setter
- (NSMapTable<NSString *,FKCacheRequestModel *> *)requestMap {
    if (!_requestMap) {
        _requestMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                            valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _requestMap;
}

- (NSMapTable<NSString *,NSURLSessionDownloadTask *> *)taskMap {
    if (!_taskMap) {
        _taskMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                         valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _taskMap;
}

- (NSMapTable<NSString *,NSString *> *)requestIndexMap {
    if (!_requestIndexMap) {
        _requestIndexMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                 valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _requestIndexMap;
}

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


@implementation FKCache (Request)

- (BOOL)existRequestWithURL:(NSString *)url {
    return [self existRequestWithRequestID:url.SHA256];
}

- (BOOL)existRequestWithRequestID:(NSString *)requestID {
    __block NSString *requestSingleID = @"";
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        requestSingleID = [self.requestIndexMap objectForKey:requestID];
    }]] waitUntilFinished:YES];
    return requestSingleID.length > 0;
}

- (BOOL)existLocalRequestFileWithRequest:(FKCacheRequestModel *)model {
    return [[FKFileManager manager] existLocalRequestWithRequest:model];
}

- (void)addRequestWithModel:(FKCacheRequestModel *)model {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.requestMap setObject:model forKey:model.requestSingleID];
        [self.requestIndexMap setObject:model.requestSingleID forKey:model.requestID];
    }];
}

- (void)removeRequestWithModel:(FKCacheRequestModel *)model {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.requestMap removeObjectForKey:model.requestSingleID];
        [self.requestIndexMap removeObjectForKey:model.requestID];
    }];
}

- (void)removeRequestWithRequestID:(NSString *)requestID {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        [self.requestMap removeObjectForKey:requestSingleID];
        [self.requestIndexMap removeObjectForKey:requestID];
    }];
}

- (void)updateRequestWithModel:(FKCacheRequestModel *)model {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSString *requestSingleID = [self.requestIndexMap objectForKey:model.requestID];
        [self.requestMap setObject:model forKey:requestSingleID];
    }];
}

- (void)updateLocalRequestWithModel:(FKCacheRequestModel *)model {
    [[FKFileManager manager] updateRequestFileWithRequest:model];
}

- (NSString *)localRequestFilePathWithRequestID:(NSString *)requestID {
    return [[FKFileManager manager] filePathWithRequestID:requestID];
}

- (NSUInteger)actionRequestCount {
    NSUInteger count = 0;
    for (FKCacheRequestModel *request in [self requestArray]) {
        if (request.state == FKStateAction) {
            count += 1;
        }
    }
    return count;
}

- (FKCacheRequestModel *)requestWithRequestID:(NSString *)requestID {
    __block FKCacheRequestModel *info = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        info = [self.requestMap objectForKey:requestSingleID];
    }]] waitUntilFinished:YES];
    return info;
}

- (FKCacheRequestModel *)localRequestFileWithRequestID:(NSString *)requestID {
    return [[FKFileManager manager] loadLocalRequestWithRequestID:requestID];
}

- (NSString *)requestExpectedFilePathWithRequestID:(NSString *)requestID {
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    NSString *fileName = [NSString stringWithFormat:@"%@%@", info.requestID, info.extension];
    NSString *requestFinder = [[FKFileManager manager].workFinder stringByAppendingPathComponent:requestID];
    NSString *requestFilePath = [requestFinder stringByAppendingPathComponent:fileName];
    return requestFilePath;
}

- (NSArray<FKCacheRequestModel *> *)requestArray {
    __block NSArray<FKCacheRequestModel *> *array = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        array = self.requestMap.objectEnumerator.allObjects;
    }]] waitUntilFinished:YES];
    return array;
}

- (FKCacheRequestModel *)firstIdelRequest {
    NSSortDescriptor *requestSort = [NSSortDescriptor sortDescriptorWithKey:@"idx" ascending:YES];
    NSArray<FKCacheRequestModel *> *allRequestArray = [[FKCache cache] requestArray];
    NSArray<FKCacheRequestModel *> *requestArray = [allRequestArray sortedArrayUsingDescriptors:@[requestSort]];
    FKCacheRequestModel *requestModel = nil;
    for (FKCacheRequestModel *model in requestArray) {
        if (model.state == FKStateIdel) {
            requestModel = model;
            break;
        }
    }
    return requestModel;
}

@end


@implementation FKCache (DownloadTask)

- (void)addDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSString *requestID = downloadTask.taskDescription;
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        [self.taskMap setObject:downloadTask forKey:requestSingleID];
    }];
}

- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSString *requestID = downloadTask.taskDescription;
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        [self.taskMap removeObjectForKey:requestSingleID];
    }];
}

- (void)repleaceDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        NSString *requestID = downloadTask.taskDescription;
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        [self.taskMap setObject:downloadTask forKey:requestSingleID];
    }];
}

- (BOOL)existDownloadTaskWithRequestID:(NSString *)requestID {
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequestID:requestID];
    BOOL isExist = NO;
    if (downloadTask) { isExist = YES; }
    return isExist;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequestID:(NSString *)requestID {
    __block NSURLSessionDownloadTask *downloadTask = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        downloadTask = [self.taskMap objectForKey:requestSingleID];
    }]] waitUntilFinished:YES];
    return downloadTask;
}

- (FKState)stateRequestWithRequestID:(NSString *)requestID {
    FKCacheRequestModel *info = [self requestWithRequestID:requestID];
    return info ? info.state : FKStateUnknown;
}

- (NSError *)errorRequestWithRequestID:(NSString *)requestID {
    FKCacheRequestModel *info = [self requestWithRequestID:requestID];
    return info.error;
}

@end

@implementation FKCache (Observer)

- (void)addObserverInfo:(FKObserverModel *)info forRequestID:(NSString *)requestID {
    [self.infoMap setObject:info forKey:requestID];
}

- (void)removeObserverInfoWithRequestID:(NSString *)requestID {
    [self.infoMap removeObjectForKey:requestID];
}

- (FKObserverModel *)observerInfoWithRequestID:(NSString *)requestID {
    __block FKObserverModel *model = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        model = [self.infoMap objectForKey:requestID];
    }]] waitUntilFinished:YES];
    return model;
}


- (void)addReserveObserverBlock:(MessagerInfoBlock)block forRequestID:(NSString *)requestID {
    [self.reserveBlockMap setObject:block forKey:requestID];
}

- (void)removeReserveObserverBlockWithRequestID:(NSString *)requestID {
    [self.reserveBlockMap removeObjectForKey:requestID];
}

- (MessagerInfoBlock)reserveObserverBlockWithRequestID:(NSString *)requestID {
    return [self.reserveBlockMap objectForKey:requestID];
}


- (NSArray<NSString *> *)observerBlockTable {
    __block NSArray *keys = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        keys = self.blockMap.keyEnumerator.allObjects;
    }]] waitUntilFinished:YES];
    return keys;
}

- (void)addObserverBlock:(MessagerInfoBlock)block forRequestID:(NSString *)requestID {
    [self.blockMap setObject:block forKey:requestID];
}

- (void)removeObserverBlockWithRequestID:(NSString *)requestID {
    [self.blockMap removeObjectForKey:requestID];
}

- (MessagerInfoBlock)observerBlockWithRequestID:(NSString *)requestID {
    __block MessagerInfoBlock block = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        block = [self.blockMap objectForKey:requestID];
    }]] waitUntilFinished:YES];
    return block;
}


- (void)addObserverBarrelIndex:(NSString *)barre forURL:(NSString *)url {
    [self.barrelIndexMap setObject:barre forKey:url];
}

- (void)removeObserverBarrelIndexWithRequestID:(NSString *)requestID {
    [self.barrelIndexMap removeObjectForKey:requestID];
}

- (NSString *)observerBarrelIndexWithRequestID:(NSString *)requestID {
    return [self.barrelIndexMap objectForKey:requestID];
}


- (NSArray<NSString *> *)observerBarrelTable {
    __block NSArray *keys = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        keys = self.barrelMap.keyEnumerator.allObjects;
    }]] waitUntilFinished:YES];
    return keys;
}

- (void)addObserverBarrelWithURLs:(NSArray<NSString *> *)urls forBarrel:(NSString *)barrel {
    [self.barrelMap setObject:urls forKey:barrel];
}

- (void)addURL:(NSString *)url fromObserverBarrel:(NSString *)barrel {
    NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
    if (urls) {
        NSMutableArray<NSString *> *temp = [NSMutableArray arrayWithArray:urls];
        [temp addObject:url];
        [[FKCache cache] addObserverBarrelWithURLs:[NSArray arrayWithArray:temp] forBarrel:barrel];
    }
}

- (void)removeURL:(NSString *)url fromObserverBarrel:(NSString *)barrel {
    NSArray<NSString *> *urls = [self.barrelMap objectForKey:barrel];
    if ([urls containsObject:url]) {
        NSMutableArray<NSString *> *temp = [NSMutableArray arrayWithArray:urls];
        [temp removeObject:url];
        [[FKCache cache] addObserverBarrelWithURLs:[NSArray arrayWithArray:temp] forBarrel:barrel];
    }
}

- (void)removeObserverBarrelWithBarrel:(NSString *)barrel {
    [self.barrelMap removeObjectForKey:barrel];
}

- (NSArray<NSString *> *)observerBarrelWithBarrel:(NSString *)barrel {
    __block NSMutableArray <NSString *> *urls = [NSMutableArray array];
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        NSArray<NSString *> *requestIDs = [self.barrelMap objectForKey:barrel];
        for (NSString *requestID in requestIDs) {
            NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
            FKCacheRequestModel *model = [self.requestMap objectForKey:requestSingleID];
            if (model.url.length) {
                [urls addObject:model.url];
            }
        }
    }]] waitUntilFinished:YES];
    return [NSArray arrayWithArray:urls];
}


- (void)addObserverBarrelBlock:(MessagerBarrelBlock)block forBarrel:(NSString *)barrel {
    [self.barrelBlockMap setObject:block forKey:barrel];
}

- (void)removeObserverBarrelBlockWithBarrel:(NSString *)barrel {
    [self.barrelBlockMap removeObjectForKey:barrel];
}

- (MessagerBarrelBlock)observerBarrelBlockWithBarrel:(NSString *)barrel {
    __block MessagerBarrelBlock block = nil;
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        block = [self.barrelBlockMap objectForKey:barrel];
    }]] waitUntilFinished:YES];
    return block;
}


@end
