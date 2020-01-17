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

@end

NS_ASSUME_NONNULL_END
