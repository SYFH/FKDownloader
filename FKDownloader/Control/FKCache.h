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

/// 检查请求是否已存在
/// @param url 链接
/// @param complete 回调
- (void)existRequestWithURL:(NSString *)url complete:(void(^)(BOOL exist))complete;

/// 添加请求缓存
/// @param model 请求
- (void)addRequestWithModel:(FKCacheRequestModel *)model;

@end

NS_ASSUME_NONNULL_END
