//
//  FKCache.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKCache.h"

#import "NSString+FKCategory.h"

#import "FKTaskBuilder.h"
#import "FKFileManager.h"

@interface FKCache ()

@property (nonatomic, strong) NSOperationQueue *cacheQueue;

/// 保存所有 TaskID, 保持有序, 升序排列
@property (nonatomic, strong) NSMutableOrderedSet *taskSet;

/// 待处理任务队列, 保管尚未创建任务目录, 相关任务文件的请求, 全程强引用
/// 结构: {TaskID: [Request]}
@property (nonatomic, strong) NSMapTable *prepareMap;

/// 等待任务队列, 保管等待执行任务, 全程强引用
/// 结构: {TaskID: [Request]}
@property (nonatomic, strong) NSMapTable *idelMap;

/// 执行队列, 保管 Request, 全程强引用
/// 结构: {TaskID: [Request]}
@property (nonatomic, strong) NSMapTable *actionMap;

/// 暂停队列, 保管 Request, 全程强引用
/// 结构: {TaskID: [Request]}
/// 用户暂停后从执行队列移动到此队列
@property (nonatomic, strong) NSMapTable *suspendMap;

/// 任务与请求映射队列, 以提高使用请求查找任务的性能
/// 结构: {SHA1(Request.URL): TaskID}
@property (nonatomic, strong) NSMapTable *taskRequestMap;

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

- (void)addPrepareTaskID:(NSString *)taskID requests:(NSArray<NSMutableURLRequest *> *)requests {
    [self.cacheQueue addOperationWithBlock:^{
        if ([self.prepareMap objectForKey:taskID]) { return; }
        
        [self.prepareMap setObject:requests forKey:taskID];
        for (NSMutableURLRequest *request in requests) {
            NSString *requestID = request.URL.absoluteString.SHA1;
            [self.taskRequestMap setObject:taskID forKey:requestID];
        }
    }];
}

- (void)removeTaskID:(NSString *)taskID {
    [self.cacheQueue addOperationWithBlock:^{
        [self.prepareMap removeObjectForKey:taskID];
        [self.idelMap removeObjectForKey:taskID];
        [self.actionMap removeObjectForKey:taskID];
        [self.suspendMap removeObjectForKey:taskID];
    }];
}

- (void)containWithTaskID:(NSString *)taskID complete:(void (^)(BOOL))complete {
    [self.cacheQueue addOperationWithBlock:^{
        BOOL isExist = NO;
        if ([self.idelMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if ([self.actionMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if ([self.suspendMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if (complete) {
            complete(isExist);
        }
    }];
}

- (void)containFromPrepareWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete {
    [self.cacheQueue addOperationWithBlock:^{
        BOOL isExist = NO;
        if ([self.prepareMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if (complete) {
            complete(isExist);
        }
    }];
}

- (void)containFromIdelWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete {
    [self.cacheQueue addOperationWithBlock:^{
        BOOL isExist = NO;
        if ([self.idelMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if (complete) {
            complete(isExist);
        }
    }];
}

- (void)containFromActionWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete {
    [self.cacheQueue addOperationWithBlock:^{
        BOOL isExist = NO;
        if ([self.actionMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if (complete) {
            complete(isExist);
        }
    }];
}

- (void)containFromSuspendWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete {
    [self.cacheQueue addOperationWithBlock:^{
        BOOL isExist = NO;
        if ([self.suspendMap objectForKey:taskID]) {
            isExist = YES;
        }
        
        if (complete) {
            complete(isExist);
        }
    }];
}

- (void)requestsWithTaskID:(NSString *)taskID complete:(void (^)(NSArray<NSMutableURLRequest *> *requests))complete {
    [self.cacheQueue addOperationWithBlock:^{
        NSArray<NSMutableURLRequest *> *requests = [NSArray array];
        if ([self.idelMap objectForKey:taskID]) {
            requests = [self.idelMap objectForKey:taskID];
        }
        
        if ([self.actionMap objectForKey:taskID]) {
            requests = [self.idelMap objectForKey:taskID];
        }
        
        if ([self.suspendMap objectForKey:taskID]) {
            requests = [self.idelMap objectForKey:taskID];
        }
        
        if (complete) {
            complete(requests);
        }
    }];
}

- (void)taskWithRequestURL:(NSString *)requestURL complete:(void (^)(NSString * __nullable taskID))complete {
    [self.cacheQueue addOperationWithBlock:^{
        NSString *taskID = [self.taskRequestMap objectForKey:requestURL.SHA1];
        if (complete) {
            complete(taskID);
        }
    }];
}

- (void)idelTaskCountWithComplete:(void (^)(NSUInteger))complete {
    [self.cacheQueue addOperationWithBlock:^{
        if (complete) {
            complete(self.idelMap.count);
        }
    }];
}

- (void)actionTaskCountWithComplete:(void (^)(NSUInteger))complete {
    [self.cacheQueue addOperationWithBlock:^{
        if (complete) {
            complete(self.actionMap.count);
        }
    }];
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)cacheQueue {
    @synchronized (self) {
        if (!_cacheQueue) {
            _cacheQueue = [[NSOperationQueue alloc] init];
            _cacheQueue.maxConcurrentOperationCount = 1;
        }
        return _cacheQueue;
    }
}

- (NSMapTable *)prepareMap {
    @synchronized (self) {
        if (!_prepareMap) {
            _prepareMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _prepareMap;
    }
}

- (NSMapTable *)idelMap {
    @synchronized (self) {
        if (!_idelMap) {
            _idelMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                             valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _idelMap;
    }
}

- (NSMapTable *)actionMap {
    @synchronized (self) {
        if (!_actionMap) {
            _actionMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                               valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _actionMap;
    }
}

- (NSMapTable *)suspendMap {
    @synchronized (self) {
        if (!_suspendMap) {
            _suspendMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _suspendMap;
    }
}

- (NSMapTable *)taskRequestMap {
    @synchronized (self) {
        if (!_taskRequestMap) {
            _taskRequestMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                    valueOptions:NSPointerFunctionsStrongMemory];
        }
        return _taskRequestMap;
    }
}

- (NSMutableOrderedSet *)taskSet {
    @synchronized (self) {
        if (!_taskSet) {
            _taskSet = [NSMutableOrderedSet orderedSet];
        }
        return _taskSet;
    }
}

@end
