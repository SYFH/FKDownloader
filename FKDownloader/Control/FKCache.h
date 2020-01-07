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

@class FKBuilder;
@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKCache : NSObject

+ (instancetype)cache;

// TODO: 所有方法分为两个版本: 在串行线程内执行和不做线程处理

/// 检查请求是否已存在
/// @param url 链接
/// @param complete 回调
- (void)existRequestWithURL:(NSString *)url complete:(void(^)(BOOL exist))complete;

/// 添加请求缓存
/// @param model 请求
- (void)addRequestWithModel:(FKCacheRequestModel *)model;

/// 更新请求缓存
/// @param model 请求
- (void)updateRequestWithModel:(FKCacheRequestModel *)model;

/// 当前进行中任务数量
/// @param complete 回调
- (void)actionRequestCountWithComplete:(void(^)(NSUInteger count))complete;

/// 获取当前所有请求
- (NSArray<FKCacheRequestModel *> *)requestArray;

/// 添加下载任务
/// @param downloadtTask 下载任务
- (void)addDownloadTask:(NSURLSessionDownloadTask *)downloadtTask;

/// 检查下载任务是否已存在
/// @param requestID 请求编号
/// @param complete 回调
- (void)existDownloadTaskWithRequestID:(NSString *)requestID complete:(void(^)(BOOL exist))complete;

@end

NS_ASSUME_NONNULL_END
