//
//  FKDownloader.m
//  FKDownloader
//
//  Created by norld on 2019/12/28.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKDownloader.h"

#import "FKCache.h"
#import "FKCacheModel.h"

@implementation FKDownloader

/// 添加并开始方法
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

/// 获取任务所有信息
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

/// 暂停
+ (void)suspendWithURL:(NSString *)url {
    [FKControl suspendRequestWithURL:url];
}

/// 暂停所有任务
+ (void)suspendAllTask {
    [FKControl suspendAllTask];
}

/// 恢复
+ (void)resumeWithURL:(NSString *)url {
    [FKControl resumeRequestWithURL:url];
}

/// 恢复所有任务
+ (void)resumeAllTask {
    [FKControl resumeAllTask];
}

/// 取消并删除任务
+ (void)cancelWithURL:(NSString *)url {
    [FKControl trashRequestWithURL:url];
}

@end
