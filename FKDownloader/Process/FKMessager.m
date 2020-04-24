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

@implementation FKMessager

+ (FKState)stateWithURL:(NSString *)url {
    return [[FKCache cache] stateRequestWithRequestID:url.SHA256];
}

+ (NSError *)errorWithURL:(NSString *)url {
    return [[FKCache cache] errorRequestWithRequestID:url.SHA256];
}

+ (NSString *)downloadedFilePathWithURL:(NSString *)url {
    return [[FKFileManager manager] filePathWithRequestID:url.SHA256];
}

+ (void)messagerWithURL:(NSString *)url info:(MessagerInfoBlock)info {
    [[FKObserver observer] addBlock:info requestID:url.SHA256];
}

+ (void)acqireMessagerInfo:(MessagerInfoBlock)info url:(NSString *)url {
    [[FKObserver observer] execAcquireInfo:info requestID:url.SHA256];
}

+ (void)removeMessagerInfoWithURL:(NSString *)url {
    [[FKObserver observer] removeBlockWithRequestID:url.SHA256];
}

+ (void)addURL:(NSString *)url fromBarrel:(NSString *)barrel {
    [[FKObserver observer] addURL:url fromBarrel:barrel];
}

+ (void)removeURL:(NSString *)url fromBarrel:(NSString *)barrel {
    [[FKObserver observer] removeURL:url fromBarrel:barrel];
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

@end
