//
//  FKDownloadTool.m
//  FKDownloader
//
//  Created by norld on 2020/6/11.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKDownloadTool.h"

@implementation FKDownloadTool

+ (void)addURL:(NSString *)url {
    if ([FKMessager existWithURL:url]) {
        if ([FKMessager stateWithURL:url] == FKStateSuspend) {
            [FKControl resumeRequestWithURL:url];
        }
        else {
            [FKControl actionRequestWithURL:url];
        }
    } else {
        [[FKBuilder buildWithURL:url] prepare];
    }
}

+ (void)getInfoWithURL:(NSString *)url complete:(MessagerInfoBlock)complete {
    if ([FKMessager existWithURL:url]) {
        [FKBuilder loadCacheWithURL:url];
        [FKMessager messagerWithURL:url info:complete];
    }
    else {
        if (complete) {
            complete(0, 0, 0, FKStateUnknown, [NSError errorWithDomain:@"com.fk.downloader.error" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"任务不存在"}]);
        }
    }
}

+ (void)suspendWithURL:(NSString *)url {
    [FKControl suspendRequestWithURL:url];
}

+ (void)suspendAllTask {
    [FKControl suspendAllTask];
}

+ (void)resumeWithURL:(NSString *)url {
    [FKControl resumeRequestWithURL:url];
}

+ (void)resumeAllTask {
    [FKControl resumeAllTask];
}

+ (void)cancelWithURL:(NSString *)url {
    [FKControl trashRequestWithURL:url];
}

@end
