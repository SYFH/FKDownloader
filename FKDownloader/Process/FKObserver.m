//
//  FKObserver.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKObserver.h"


@interface FKObserver ()

@property (nonatomic, strong) NSOperationQueue *queue;

/// 请求信息
/// 结构: {"SHA1(Request.URL)":{"progress":0, "state":0}}
@property (nonatomic, strong) NSMapTable *infoMap;

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
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)addObserverWithRequest:(NSMutableURLRequest *)request {
    [self.queue addOperationWithBlock:^{
        // 监听进度
        
        // 监听状态
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}

@end
