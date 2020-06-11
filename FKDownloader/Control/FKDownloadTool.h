//
//  FKDownloadTool.h
//  FKDownloader
//
//  Created by norld on 2020/6/11.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 *  简单实用类, 对外开放
 */

#import <Foundation/Foundation.h>

#import "FKMessager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKDownloadTool : NSObject

/// 添加并开始任务
/// @param url 连接
+ (void)addURL:(NSString *)url;

/// 获取任务所有信息
/// @param url 连接
/// @param complete 信息回调
+ (void)getInfoWithURL:(NSString *)url complete:(MessagerInfoBlock)complete;

/// 暂停
/// @param url 连接
+ (void)suspendWithURL:(NSString *)url;

/// 暂停所有任务
+ (void)suspendAllTask;

/// 恢复
/// @param url 连接
+ (void)resumeWithURL:(NSString *)url;

/// 恢复所有任务
+ (void)resumeAllTask;

/// 取消并删除任务
/// @param url 连接
+ (void)cancelWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
