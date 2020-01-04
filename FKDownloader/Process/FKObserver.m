//
//  FKObserver.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKObserver.h"


@interface FKObserver ()

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

- (void)addObserverWithRequest:(NSMutableURLRequest *)request {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    
}


#pragma mark - Getter/Setter

@end
