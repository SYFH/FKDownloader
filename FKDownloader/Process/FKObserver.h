//
//  FKObserver.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责统一管理任务监听数据, 并进行数据分发
 */

#import <Foundation/Foundation.h>

#import "FKMessager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKObserver : NSObject

+ (instancetype)observer;

/// 添加需要监听的下载任务
/// @param downloadTask 下载任务
- (void)observerDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 移除不需要监听的下载任务
/// @param downloadTask 下载任务
- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 添加信息回调到指定请求
/// @param block 信息回调
/// @param requestID 请求标识
- (void)addBlock:(InfoBlock)block requestID:(NSString *)requestID;

/// 执行现有请求的信息回调
- (void)execRequestInfoBlock;

@end

NS_ASSUME_NONNULL_END
