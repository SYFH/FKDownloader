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

/// 添加监听缓存
/// @param downloadTask 下载任务
- (void)observerCacheWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 移除不需要监听的下载任务
/// @param downloadTask 下载任务
- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 移除监听缓存
/// @param downloadTask 下载任务
- (void)removeCacheWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 清除缓存的监听进度
/// @param downloadTask 下载任务
- (void)removeCacheProgressWithDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 添加信息回调到指定请求
/// @param block 信息回调
/// @param requestID 请求标识
- (void)addBlock:(MessagerInfoBlock)block requestID:(NSString *)requestID;

/// 添加一个链接集合
/// @param barrel 集合名
/// @param urls 多个链接
- (void)addBarrel:(NSString *)barrel urls:(NSArray<NSString *> *)urls;

/// 移除一个链接集合
/// @param barrel 集合名
- (void)removeBarrel:(NSString *)barrel;

/// 添加一个信息集合回调
/// @param barrel 集合名
/// @param info 信息回调
- (void)addBarrel:(NSString *)barrel info:(MessagerBarrelBlock)info;

/// 执行现有请求的信息回调
- (void)execRequestInfoBlock;

@end

NS_ASSUME_NONNULL_END
