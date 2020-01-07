//
//  FKCache.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKCache.h"

#import "NSString+FKCategory.h"

#import "FKCacheModel.h"
#import "FKEngine.h"

@interface FKCache ()

/// 请求表, 包含所有请求信息, {SingleNumber_SHA256(Request.URL): Cache.Request.Model}
@property (nonatomic, strong) NSMapTable<NSString *, FKCacheRequestModel *> *requestMap;

/// 任务表, 包含所有下载任务, {SingleNumber_SHA256(Request.URL): Download.Task}
@property (nonatomic, strong) NSMapTable<NSString *, NSURLSessionDownloadTask *> *taskMap;

/// 请求索引表, {SHA256(Request.URL): SingleNumber_SHA256(Request.URL)}
@property (nonatomic, strong) NSMapTable<NSString *, NSString *> *requestIndexMap;

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
    }
    return self;
}

- (void)existRequestWithURL:(NSString *)url complete:(void (^)(BOOL))complete {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestID = [self.requestIndexMap objectForKey:url.SHA256];
        
        if (complete) {
            complete(requestID.length > 0);
        }
    }];
}

- (void)addRequestWithModel:(FKCacheRequestModel *)model {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        [self.requestMap setObject:model forKey:model.requestID];
        [self.requestIndexMap setObject:model.requestID forKey:model.url.SHA256];
    }];
}

- (void)updateRequestWithModel:(FKCacheRequestModel *)model {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestSingleID = [self.requestIndexMap objectForKey:model.requestID];
        [self.requestMap setObject:model forKey:requestSingleID];
    }];
}

- (void)actionRequestCountWithComplete:(void (^)(NSUInteger))complete {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        
        NSUInteger count = 0;
        for (FKCacheRequestModel *request in self.requestMap.objectEnumerator) {
            if (request.state == FKStateAction) {
                count += 1;
            }
        }
        
        if (complete) {
            complete(count);
        }
    }];
}

- (NSArray<FKCacheRequestModel *> *)requestArray {
    return self.requestMap.objectEnumerator.allObjects;
}

- (void)addDownloadTask:(NSURLSessionDownloadTask *)downloadtTask {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestID = downloadtTask.taskDescription;
        NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
        [self.taskMap setObject:downloadtTask forKey:requestSingleID];
    }];
}

- (void)existDownloadTaskWithRequestID:(NSString *)requestID complete:(void (^)(BOOL))complete {
    NSString *requestSingleID = [self.requestIndexMap objectForKey:requestID];
    NSURLSessionDownloadTask *downloadTask = [self.taskMap objectForKey:requestSingleID];
    BOOL isExist = NO;
    if (downloadTask) { isExist = YES; }
    
    if (complete) {
        complete(isExist);
    }
}


#pragma mark - Getter/Setter
- (NSMapTable<NSString *,FKCacheRequestModel *> *)requestMap {
    @synchronized (self) {
        if (!_requestMap) {
            _requestMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _requestMap;
    }
}

- (NSMapTable<NSString *,NSURLSessionDownloadTask *> *)taskMap {
    @synchronized (self) {
        if (!_taskMap) {
            _taskMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory
                                             valueOptions:NSPointerFunctionsWeakMemory];
        }
        return _taskMap;
    }
}

- (NSMapTable<NSString *,NSString *> *)requestIndexMap {
    @synchronized (self) {
        if (!_requestIndexMap) {
            _requestIndexMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                     valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _requestIndexMap;
    }
}

@end
