//
//  FKConfigure.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKConfigure.h"

@implementation FKConfigure

+ (instancetype)configure {
    static FKConfigure *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FKConfigure alloc] init];
    });
    return instance;
}

@end
