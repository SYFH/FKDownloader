//
//  FKScheduler.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责管理任务、过滤任务，存储、去重任务都在此控制
 */

#import <Foundation/Foundation.h>

@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKScheduler : NSObject

+ (instancetype)shared;

/// 从磁盘缓存加载人物信息
/// @param url 请求链接
- (void)loadCacheWithURL:(NSString *)url;

/// 预处理任务
/// @param request 请求信息
- (void)prepareRequest:(FKCacheRequestModel *)request;

/// 激活任务
/// @param url 请求链接
- (void)actionRequestWithURL:(NSString *)url;

/// 暂停任务
/// @param url 请求链接
- (void)suspendRequestWithURL:(NSString *)url;

/// 继续任务
/// @param url 请求链接
- (void)resumeRequestWithURL:(NSString *)url;

/// 取消任务
/// @param url 请求链接
- (void)cancelRequestWithURL:(NSString *)url;

/// 彻底删除任务, 包括本地信息文件
/// @param url 请求链接
- (void)trashRequestWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
