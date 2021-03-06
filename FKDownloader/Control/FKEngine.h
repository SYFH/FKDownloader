//
//  FKEngine.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 核心引擎，负责控制和调度各个组件，保证数据流转
 */

#import <Foundation/Foundation.h>
@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKEngine : NSObject

/// I/O线程, 串行
@property (nonatomic, strong) NSOperationQueue *ioQueue;

/// 计时器线程, 串行
@property (nonatomic, strong) dispatch_queue_t timerQueue;

/// 信息分发线程, 并行
@property (nonatomic, strong) NSOperationQueue *messagerQueue;

/// 后台下载
@property (nonatomic, strong, readonly) NSURLSession *backgroundSession;

/// 前台下载
@property (nonatomic, strong, readonly) NSURLSession *foregroundSession;

+ (instancetype)engine;

/// 配置 Session
- (void)configureSession;

/// 配置任务执行计时器
- (void)configureExecTimer;

/// 配置信息分发计时器
- (void)configureDistributeInfoTimer;

/// 处理下载完成流程
/// @param downloadTask 下载任务
/// @param location 缓存文件地址
- (void)processCompleteDownload:(NSURLSessionDownloadTask *)downloadTask location:(NSURL *)location;

- (void)processTask:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error;

@end

@interface FKEngine (Control)

/// 激活已取消任务
/// @param url 请求链接
- (void)actionRequestWithURL:(NSString *)url;

/// 暂停任务
/// @param url 请求链接
- (void)suspendRequestWithURL:(NSString *)url;

/// 暂停所有任务
- (void)suspendAllTask;

/// 继续任务
/// @param url 请求链接
- (void)resumeRequestWithURL:(NSString *)url;

/// 恢复所有任务
- (void)resumeAllTask;

/// 取消任务
/// @param url 请求链接
- (void)cancelRequestWithURL:(NSString *)url;

/// 彻底删除任务, 包括本地信息文件
/// @param url 请求链接
- (void)trashRequestWithURL:(NSString *)url;

/// 将 Background Session 上所有任务取消
- (void)cancelAllRequest;

/// 调用下载中间件返回任务状态
/// @param request 任务信息
- (void)downloadMiddlewareStateWithRequest:(FKCacheRequestModel *)request;

@end

NS_ASSUME_NONNULL_END
