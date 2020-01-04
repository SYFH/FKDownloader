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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.ioQueue.maxConcurrentOperationCount = 1;
        self.ioQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)ioQueue {
    if (!_ioQueue) {
        _ioQueue = [[NSOperationQueue alloc] init];
        _ioQueue.name = @"com.fk.queue.cache.io";
    }
    return _ioQueue;
}

@end
