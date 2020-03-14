//
//  FKMessager.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKMessager.h"

#import "NSString+FKCategory.h"

#import "FKObserver.h"

@implementation FKMessager

- (instancetype)initWithBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info {
    self = [super init];
    if (self) {
        [[FKObserver observer] addBarrel:barrel info:info];
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url info:(MessagerInfoBlock)info {
    self = [super init];
    if (self) {
        [[FKObserver observer] addBlock:info requestID:url.SHA256];
    }
    return self;
}

+ (instancetype)messagerWithURL:(NSString *)url info:(MessagerInfoBlock)info {
    return [[FKMessager alloc] initWithURL:url info:info];
}

+ (void)addMessagerWithURLs:(NSArray<NSString *> *)urls barrel:(NSString *)barrel {
    NSMutableArray<NSString *> *urlsTemp = [NSMutableArray arrayWithCapacity:urls.count];
    for (NSString *url in urls) {
        [urlsTemp addObject:url.SHA256];
    }
    [[FKObserver observer] addBarrel:barrel urls:[NSArray arrayWithArray:urlsTemp]];
}

+ (void)removeMessagerBarrel:(NSString *)barrel {
    [[FKObserver observer] removeBarrel:barrel];
}

+ (instancetype)messagerWithBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info {
    return [[FKMessager alloc] initWithBarrel:barrel info:info];
}

@end
