//
//  FKMiddleware.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKMiddleware.h"

#import "FKEngine.h"
#import "FKLogger.h"

@interface FKMiddleware ()

@property (nonatomic, strong) NSHashTable<id<FKRequestMiddlewareProtocol>> *requestMiddlewares;
@property (nonatomic, strong) NSHashTable<id<FKDownloadMiddlewareProtocol>> *downloadMiddlewares;
@property (nonatomic, strong) NSHashTable<id<FKResponseMiddlewareProtocol>> *responseMiddlewares;

@end

@implementation FKMiddleware

+ (instancetype)shared {
    static FKMiddleware *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FKMiddleware alloc] init];
    });
    return instance;
}

- (void)registeRequestMiddleware:(id<FKRequestMiddlewareProtocol>)middleware {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.requestMiddlewares addObject:middleware];
    }];
    [FKLogger debug:@"%@\n注册请求中间件", middleware];
}

- (void)registeDownloadMiddleware:(id<FKDownloadMiddlewareProtocol>)middleware {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.downloadMiddlewares addObject:middleware];
    }];
    [FKLogger debug:@"%@\n注册下载中间件", middleware];
}

- (void)registeResponseMiddleware:(id<FKResponseMiddlewareProtocol>)middleware {
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        [self.responseMiddlewares addObject:middleware];
    }];
    [FKLogger debug:@"%@\n注册响应中间件", middleware];
}

- (NSArray<id<FKRequestMiddlewareProtocol>> *)requestMiddlewareArray {
    __block NSArray<id<FKRequestMiddlewareProtocol>> *allRequestMiddleware = @[];
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        allRequestMiddleware = self.requestMiddlewares.objectEnumerator.allObjects;
    }]] waitUntilFinished:YES];
    NSSortDescriptor *requestMiddlewareSort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray<id<FKRequestMiddlewareProtocol>> *middlewares = [allRequestMiddleware sortedArrayUsingDescriptors:@[requestMiddlewareSort]];
    return middlewares;
}

- (NSArray<id<FKDownloadMiddlewareProtocol>> *)downloadMiddlewareArray {
    __block NSArray<id<FKDownloadMiddlewareProtocol>> *allDownloadMiddleware = @[];
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        allDownloadMiddleware = self.downloadMiddlewares.objectEnumerator.allObjects;
    }]] waitUntilFinished:YES];
    NSSortDescriptor *downloadMiddlewareSort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray<id<FKDownloadMiddlewareProtocol>> *middlewares = [allDownloadMiddleware sortedArrayUsingDescriptors:@[downloadMiddlewareSort]];
    return middlewares;
}

- (NSArray<id<FKResponseMiddlewareProtocol>> *)responseMiddlewareArray {
    __block NSArray<id<FKResponseMiddlewareProtocol>> *allResponseMiddleware = @[];
    [[FKEngine engine].ioQueue addOperations:@[[NSBlockOperation blockOperationWithBlock:^{
        allResponseMiddleware = self.responseMiddlewares.objectEnumerator.allObjects;
    }]] waitUntilFinished:YES];
    NSSortDescriptor *responseMiddlewareSort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray<id<FKResponseMiddlewareProtocol>> *middlewares = [allResponseMiddleware sortedArrayUsingDescriptors:@[responseMiddlewareSort]];
    return middlewares;
}


#pragma mark - Getter/Setter
- (NSHashTable<id<FKRequestMiddlewareProtocol>> *)requestMiddlewares {
    if (!_requestMiddlewares) {
        _requestMiddlewares = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return _requestMiddlewares;
}

- (NSHashTable<id<FKDownloadMiddlewareProtocol>> *)downloadMiddlewares {
    if (!_downloadMiddlewares) {
        _downloadMiddlewares = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return _downloadMiddlewares;
}

- (NSHashTable<id<FKResponseMiddlewareProtocol>> *)responseMiddlewares {
    if (!_responseMiddlewares) {
        _responseMiddlewares = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return _responseMiddlewares;
}

@end
