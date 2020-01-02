//
//  FKScheduler.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKScheduler.h"

#import "FKCache.h"
#import "FKFileManager.h"

@interface FKScheduler ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation FKScheduler

+ (instancetype)shared {
    static FKScheduler *instance = nil;
    static dispatch_once_t FKSchedulerOnceToken;
    dispatch_once(&FKSchedulerOnceToken, ^{
        instance = [[FKScheduler alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)startWithTask:(NSString *)taskID {
    [self.queue addOperationWithBlock:^{
        
    }];
}

- (void)cancelWithTask:(NSString *)taskID {
    
}

- (void)suspendWithTask:(NSString *)taskID {
    
}

- (void)resumeWithTask:(NSString *)taskID {
    
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

@end
