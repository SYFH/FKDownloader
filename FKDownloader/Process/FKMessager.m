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
#import "FKCache.h"
#import "FKFileManager.h"
#import "FKBuilder.h"

@implementation FKMessager

+ (BOOL)existWithURL:(NSString *)url {
    BOOL isExist = NO;
    if ([FKMessager existCacheWithURL:url]) {
        isExist = YES;
    } else if ([FKMessager existLocalWithURL:url]) {
        isExist = YES;
    }
    return isExist;
}

+ (BOOL)existCacheWithURL:(NSString *)url {
    return [[FKCache cache] existRequestWithURL:url.SHA256];
}

+ (BOOL)existLocalWithURL:(NSString *)url {
    return [[FKFileManager manager] existLocalRequestWithRequestID:url.SHA256];
}

+ (void)loadLocalCacheWithURL:(NSString *)url {
    if (![FKMessager existCacheWithURL:url] && [FKMessager existLocalWithURL:url]) {
        [FKBuilder loadCacheWithURL:url];
    }
}

+ (FKState)stateWithURL:(NSString *)url {
    [FKMessager loadLocalCacheWithURL:url];
    return [[FKCache cache] stateRequestWithRequestID:url.SHA256];
}

+ (NSError *)errorWithURL:(NSString *)url {
    [FKMessager loadLocalCacheWithURL:url];
    return [[FKCache cache] errorRequestWithRequestID:url.SHA256];
}

+ (NSString *)downloadedFilePathWithURL:(NSString *)url {
    [FKMessager loadLocalCacheWithURL:url];
    return [[FKFileManager manager] filePathWithRequestID:url.SHA256];
}

+ (void)messagerWithURL:(NSString *)url info:(MessagerInfoBlock)info {
    [FKMessager loadLocalCacheWithURL:url];
    [[FKObserver observer] addBlock:info requestID:url.SHA256];
}

+ (void)acqireMessagerInfo:(MessagerInfoBlock)info url:(NSString *)url {
    [FKMessager loadLocalCacheWithURL:url];
    [[FKObserver observer] execAcquireInfo:info requestID:url.SHA256];
}

+ (void)removeMessagerInfoWithURL:(NSString *)url {
    [FKMessager loadLocalCacheWithURL:url];
    [[FKObserver observer] removeBlockWithRequestID:url.SHA256];
}

+ (void)addURL:(NSString *)url fromBarrel:(NSString *)barrel {
    [[FKObserver observer] addURL:url.SHA256 fromBarrel:barrel];
}

+ (void)removeURL:(NSString *)url fromBarrel:(NSString *)barrel {
    [[FKObserver observer] removeURL:url.SHA256 fromBarrel:barrel];
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

+ (void)messagerWithBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info {
    [[FKObserver observer] addBarrel:barrel info:info];
}

+ (NSArray<NSString *> *)acquireURLsWithBarrel:(NSString *)barrel {
    return [[FKObserver observer] acquireURLsWithBarrel:barrel];
}

@end
