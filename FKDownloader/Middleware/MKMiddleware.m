//
//  MKMiddleware.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "MKMiddleware.h"

@interface MKMiddleware ()

@property (nonatomic, strong) NSHashTable<id<FKRequestMiddlewareProtocol>> *scheduleMiddlewares;
@property (nonatomic, strong) NSHashTable<id<FKResponseMiddlewareProtocol>> *responseMiddlewares;

@end

@implementation MKMiddleware

+ (instancetype)shared {
    static MKMiddleware *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MKMiddleware alloc] init];
    });
    return instance;
}

@end
