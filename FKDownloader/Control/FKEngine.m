//
//  FKEngine.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKEngine.h"

#import "FKScheduler.h"

@interface FKEngine ()

@end

@implementation FKEngine

+ (instancetype)engine {
    static FKEngine *instance = nil;
    static dispatch_once_t FKEngineOnceToken;
    dispatch_once(&FKEngineOnceToken, ^{
        instance = [[FKEngine alloc] init];
    });
    return instance;
}

- (void)startWithTask:(NSString *)taskID {
    [[FKScheduler shared] startWithTask:taskID];
}

- (void)cancelWithTask:(NSString *)taskID {
    [[FKScheduler shared] cancelWithTask:taskID];
}

- (void)suspendWithTask:(NSString *)taskID {
    [[FKScheduler shared] suspendWithTask:taskID];
}

- (void)resumeWithTask:(NSString *)taskID {
    [[FKScheduler shared] resumeWithTask:taskID];
}

- (void)processRequest:(NSMutableURLRequest *)request {
    // 检测是否有中间件
    
    // 将 request 进行下载
    
    // 添加 KVO
}

@end
