//
//  FKFileManager.h
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 管理磁盘
 */

#import <Foundation/Foundation.h>

@class FKCacheTaskModel;
@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKFileManager : NSObject

+ (instancetype)manager;

- (NSString *)workFinder;

- (BOOL)existWithTaskID:(NSString *)taskID;
- (BOOL)existWithRequestURL:(NSString *)requestURL taskID:(NSString *)taskID;

/// 创建任务目录
/// @param taskID 任务编号
/// 结构:
/// ---:Dir(taskID)
///  |---:Dir(sha1(Request.URL))
///    |---:File(Response)
///  |---:Dir(sha1(Request.URL))
///    |---:File(Response)
///  ...
- (void)createFinderWithTaskID:(NSString *)taskID requests:(NSArray<NSMutableURLRequest *> *)requests;

/// 获取本地储存的任务信息
/// @param taskID 任务编号
/// @param complete 回调
- (void)taskInfoWithTaskID:(NSString *)taskID complete:(void(^)(FKCacheTaskModel * _Nullable model))complete;

/// 获取本地储存的请求信息
/// @param url 请求链接
/// @param complete 回调
- (void)requestInfoWithRequestURL:(NSString *)url complete:(void(^)(FKCacheRequestModel * _Nullable model))complete;

@end

NS_ASSUME_NONNULL_END
