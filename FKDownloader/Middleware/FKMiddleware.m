//
//  FKMiddleware.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKMiddleware.h"

#import "FKLogger.h"

@interface FKMiddleware ()

@property (nonatomic, strong) NSHashTable<id<FKRequestMiddlewareProtocol>> *requestMiddlewares;
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
    [self.requestMiddlewares addObject:middleware];
    [FKLogger info:@"注册请求中间件"];
}

- (void)registeResponseMiddleware:(id<FKResponseMiddlewareProtocol>)middleware {
    [self.responseMiddlewares addObject:middleware];
    [FKLogger info:@"注册响应中间件"];
}

- (void)processRequest:(NSMutableURLRequest *)request complete:(void (^)(NSMutableURLRequest *request))complete {
    NSMutableURLRequest *processed = request;
    for (id<FKRequestMiddlewareProtocol> middleware in self.requestMiddlewares) {
        if ([middleware respondsToSelector:@selector(processRequest:)]) {
            processed = [middleware processRequest:processed];
        }
    }
    if (complete) {
        complete(processed);
    }
}

- (NSArray<id<FKRequestMiddlewareProtocol>> *)requestMiddlewareArray {
    NSArray<id<FKRequestMiddlewareProtocol>> *allRequestMiddleware = self.requestMiddlewares.objectEnumerator.allObjects;
    NSSortDescriptor *requestMiddlewareSort = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES];
    NSArray<id<FKRequestMiddlewareProtocol>> *middlewares = [allRequestMiddleware sortedArrayUsingDescriptors:@[requestMiddlewareSort]];
    return middlewares;
}

- (NSArray<id<FKResponseMiddlewareProtocol>> *)responseMiddlewareArray {
    NSArray<id<FKResponseMiddlewareProtocol>> *allResponseMiddleware = self.responseMiddlewares.objectEnumerator.allObjects;
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

- (NSHashTable<id<FKResponseMiddlewareProtocol>> *)responseMiddlewares {
    if (!_responseMiddlewares) {
        _responseMiddlewares = [NSHashTable hashTableWithOptions:NSPointerFunctionsStrongMemory];
    }
    return _responseMiddlewares;
}

@end
