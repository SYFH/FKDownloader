//
//  NSURLSessionDownloadTask+FKCategory.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 下载任务的扩展, 负责以 URL 为唯一标示进行通用数据生成, 将包含所属任务, 所属文件夹等信息
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionDownloadTask (FKCategory)

/// 写入基本信息
/// @param taskID 任务编号
/// 将使用 taskDescription 属性储存信息, 格式为 `{"taskID":"","url":""}`, 其中 `url` 代表 downloadTask 的原始下载地址
- (void)writeDescriptionWithTaskID:(NSString *)taskID url:(NSString *)url;

/// 从 taskDescription 读取任务编号
- (NSString *)taskID;

/// 从 taskDescription 读取下载地址
- (NSString *)requestURL;

@end

NS_ASSUME_NONNULL_END
