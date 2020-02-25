//
//  FKCache.h
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 任务缓存, 负责将任务信息缓存到内存, 以加快任务查找与分发的性能
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"
#import "FKObserver.h"
#import "FKObserverModel.h"

@class FKBuilder;
@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKCache : NSObject

+ (instancetype)cache;

@end

@interface FKCache (Request)

/// 检查请求是否已存在
/// @param url 链接
- (BOOL)existRequestWithURL:(NSString *)url;

/// 检查请求是否已存在
/// @param requestID 请求标识
- (BOOL)existRequestWithRequestID:(NSString *)requestID;

/// 检查本地请求文件是否已存在
/// @param model 请求
- (BOOL)existLocalRequestFileWithRequest:(FKCacheRequestModel *)model;

/// 添加请求缓存
/// @param model 请求
- (void)addRequestWithModel:(FKCacheRequestModel *)model;

/// 更新请求缓存
/// @param model 请求
- (void)updateRequestWithModel:(FKCacheRequestModel *)model;

/// 更新本地请求缓存
/// @param model 请求
- (void)updateLocalRequestWithModel:(FKCacheRequestModel *)model;

/// 获取本地请求缓存路径
/// @param requestID 请求标识
- (NSString *)localRequestFilePathWithRequestID:(NSString *)requestID;

/// 获取下载成功的文件地址, 文件可能不存在
/// @param requestID 请求标识
- (NSString *)requestExpectedFilePathWithRequestID:(NSString *)requestID;

/// 当前进行中任务数量
- (NSUInteger)actionRequestCount;

/// 根据请求编号获取缓存请求信息
/// @param requestID 请求标识
- (FKCacheRequestModel *)requestWithRequestID:(NSString *)requestID;

/// 根据请求编号从本地获取缓存请求信息
/// @param requestID 请求标识
- (FKCacheRequestModel *)localRequestFileWithRequestID:(NSString *)requestID;

/// 获取当前所有请求
- (NSArray<FKCacheRequestModel *> *)requestArray;

/// 获取第一个待执行任务
- (FKCacheRequestModel * _Nullable)firstIdelRequest;

@end

@interface FKCache (DownloadTask)

/// 添加下载任务
/// @param downloadTask 下载任务
- (void)addDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 移除下载任务, 取消或完成下载的任务将从缓存队列中移除
/// @param downloadTask 下载任务
- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 替换下载任务
/// @param downloadTask 下载任务
- (void)repleaceDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

/// 检查下载任务是否已存在
/// @param requestID 请求编号
- (BOOL)existDownloadTaskWithRequestID:(NSString *)requestID;

/// 获取下载任务
/// @param requestID 请求编号
- (NSURLSessionDownloadTask *)downloadTaskWithRequestID:(NSString *)requestID;

/// 获取链接对应的任务状态
/// @param requestID 请求编号
- (FKState)stateRequestWithRequestID:(NSString *)requestID;

/// 获取链接对应的错误信息
/// @param requestID 请求编号
- (NSError * _Nullable)errorRequestWithRequestID:(NSString *)requestID;

@end

@interface FKCache (Observer)

- (void)addObserverInfo:(FKObserverModel *)info forRequestID:(NSString *)requestID;
- (void)removeObserverInfoWithRequestID:(NSString *)requestID;
- (FKObserverModel *)observerInfoWithRequestID:(NSString *)requestID;

- (void)addReserveObserverBlock:(MessagerInfoBlock)block forRequestID:(NSString *)requestID;
- (void)removeReserveObserverBlockWithRequestID:(NSString *)requestID;
- (MessagerInfoBlock)reserveObserverBlockWithRequestID:(NSString *)requestID;

- (NSMapTable *)observerBlockTable;
- (void)addObserverBlock:(MessagerInfoBlock)block forRequestID:(NSString *)requestID;
- (void)removeObserverBlockWithRequestID:(NSString *)requestID;
- (MessagerInfoBlock)observerBlockWithRequestID:(NSString *)requestID;

- (void)addObserverBarrelIndex:(NSString *)barre forURL:(NSString *)url;
- (void)removeObserverBarrelIndexWithRequestID:(NSString *)requestID;
- (NSString *)observerBarrelIndexWithRequestID:(NSString *)requestID;

- (NSMapTable *)observerBarrelTable;
- (void)addObserverBarrelWithURLs:(NSArray<NSString *> *)urls forBarrel:(NSString *)barrel;
- (void)removeObserverBarrelWithBarrel:(NSString *)barrel;
- (NSArray<NSString *> *)observerBarrelWithBarrel:(NSString *)barrel;

- (void)addObserverBarrelBlock:(MessagerBarrelBlock)block forBarrel:(NSString *)barrel;
- (void)removeObserverBarrelBlockWithBarrel:(NSString *)barrel;
- (MessagerBarrelBlock)observerBarrelBlockWithBarrel:(NSString *)barrel;

@end

NS_ASSUME_NONNULL_END
