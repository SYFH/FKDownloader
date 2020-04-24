//
//  FKMessager.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责指定任务的信息接收, 外部获取任务信息的入口
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"

typedef void(^MessagerInfoBlock)(int64_t countOfBytesReceived,
                                 int64_t countOfBytesPreviousReceived,
                                 int64_t countOfBytesExpectedToReceive,
                                 FKState state,
                                 NSError * _Nullable error);

typedef void(^MessagerBarrelBlock)(int64_t countOfBytesReceived,
                                   int64_t countOfBytesPreviousReceived,
                                   int64_t countOfBytesExpectedToReceive);

NS_ASSUME_NONNULL_BEGIN

@interface FKMessager : NSObject

/// 链接对应的状态
/// @param url 请求链接
+ (FKState)stateWithURL:(NSString *)url;

/// 链接对应的错误信息
/// @param url 请求链接
+ (NSError * _Nullable)errorWithURL:(NSString *)url;

/// 获取下载完成后文件的路径, 文件可能不存在
/// @param url 请求链接
+ (NSString *)downloadedFilePathWithURL:(NSString *)url;

/// 定时获取链接对应的下载信息
/// @param url 链接
/// @param info 下载信息, 此回调会根据 FKConfigure 的 distributeTimeinterval 属性进行定时执行
+ (void)messagerWithURL:(NSString *)url
                   info:(MessagerInfoBlock)info;

/// 获取任务信息
/// 此方法不会将回调缓存, 执行完成后会直接销毁, 如果需要定时获取任务信息, 请使用 +[FKMessager messagerWithURL:info:]
/// @param info 下载信息
/// @param url 链接
+ (void)acqireMessagerInfo:(MessagerInfoBlock)info
                       url:(NSString *)url;

/// 移除链接对应的信息回调
/// @param url 链接
+ (void)removeMessagerInfoWithURL:(NSString *)url;

/// 添加一个获取链接集合信息的标记
/// @param urls 多个链接
/// @param barrel 集合名字, 最好唯一, 否则会被覆盖
+ (void)addMessagerWithURLs:(NSArray<NSString *> *)urls
                     barrel:(NSString *)barrel;

/// 将链接添加到指定集合中, 注意, 链接对应的任务必须存在
/// @param url 链接
/// @param barrel 集合名
+ (void)addURL:(NSString *)url
    fromBarrel:(NSString *)barrel;

/// 将链接从指定集合中移除
/// @param url 链接
/// @param barrel 集合名
+ (void)removeURL:(NSString *)url
       fromBarrel:(NSString *)barrel;

/// 移除集合标记
/// @param barrel 集合名
+ (void)removeMessagerBarrel:(NSString *)barrel;

/// 获取链接集合对应的下载信息
/// @param barrel 集合名
/// @param info 下载信息
+ (void)messagerWithBarrel:(NSString *)barrel
                      info:(MessagerBarrelBlock)info;

/// 获取集合中的已有链接
/// @param barrel 集合名
+ (NSArray<NSString *> *)acquireURLsWithBarrel:(NSString *)barrel;

@end

NS_ASSUME_NONNULL_END
