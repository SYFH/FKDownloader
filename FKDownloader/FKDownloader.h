//
//  FKDownloader.h
//  FKDownloader
//
//  Created by norld on 2019/12/28.
//  Copyright © 2019 norld. All rights reserved.
//

/*
 简单实用类, 对外开放
 */

#import <Foundation/Foundation.h>

// Control
#import <FKDownloader/FKConfigure.h>
#import <FKDownloader/FKBuilder.h>
#import <FKDownloader/FKControl.h>

// Process
#import <FKDownloader/FKMessager.h>

// Middleware
#import <FKDownloader/FKMiddleware.h>

// Utils
#import <FKDownloader/FKCommonHeader.h>

// Model
#import <FKDownloader/FKResponse.h>

@interface FKDownloader : NSObject

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

/// 恢复
/// @param url 连接
+ (void)resumeWithURL:(NSString *)url;

/// 取消并删除任务
/// @param url 连接
+ (void)cancelWithURL:(NSString *)url;

@end
