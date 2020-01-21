//
//  FKLogger.h
//  FKDownloader
//
//  Created by norld on 2020/1/8.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKLogger : NSObject

/// 输出调试日志
/// @param debug 内容
+ (void)debug:(NSString *)debug, ... NS_FORMAT_FUNCTION(1,2);

/// 获取下载任务的详细信息
/// @param downloadTask 下载任务
+ (NSString *)downloadTaskDebugInfo:(NSURLSessionDownloadTask *)downloadTask;

/// 获取请求模型的详细信息
/// @param requestModel 请求模型
+ (NSString *)requestCacheModelDebugInfo:(FKCacheRequestModel *)requestModel;

@end

NS_ASSUME_NONNULL_END
