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

+ (instancetype)engine;

/// 配置 Session
- (void)configtureSession;

/// 配置计时器
- (void)configtureTimer;

/// 处理下载完成流程
/// @param downloadTask 下载任务
/// @param location 缓存文件地址
- (void)processCompleteDownload:(NSURLSessionDownloadTask *)downloadTask location:(NSURL *)location;

@end

@interface FKEngine (Control)

/// 激活已取消任务
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

/// 将 Background Session 上所有任务取消
- (void)cancelAllRequest;

@end

NS_ASSUME_NONNULL_END
