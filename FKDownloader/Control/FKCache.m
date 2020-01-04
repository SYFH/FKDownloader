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
