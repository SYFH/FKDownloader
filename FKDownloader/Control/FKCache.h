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

@class FKTaskBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface FKCache : NSObject

+ (instancetype)cache;

/// 添加预处理任务
/// @param taskID 任务编号
/// @param requests 请求
- (void)addPrepareTaskID:(NSString *)taskID requests:(NSArray<NSMutableURLRequest *> *)requests;

/// 删除任务
/// @param taskID 任务编号
- (void)removeTaskID:(NSString *)taskID;

/// 检查是否存在任务, 只检查缓存队列, 不包含磁盘缓存
/// @param taskID 任务编号
/// @param complete 回调
- (void)containWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete;
- (void)containFromPrepareWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete;
- (void)containFromIdelWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete;
- (void)containFromActionWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete;
- (void)containFromSuspendWithTaskID:(NSString *)taskID complete:(void(^)(BOOL isExist))complete;

/// 获取任务对应的请求
/// @param taskID 任务编号
/// @param complete 回调
- (void)requestsWithTaskID:(NSString *)taskID complete:(void(^)(NSArray<NSMutableURLRequest *> *requests))complete;

/// 获取请求对应的任务
/// @param requestURL 请求地址
/// @param complete 回调
- (void)taskWithRequestURL:(NSString *)requestURL complete:(void(^)(NSString * __nullable taskID))complete;

/// 等待任务的数量
/// @param complete 回调
- (void)idelTaskCountWithComplete:(void(^)(NSUInteger count))complete;

/// 执行任务的数量
/// @param complete 回调
- (void)actionTaskCountWithComplete:(void(^)(NSUInteger count))complete;

@end

NS_ASSUME_NONNULL_END
