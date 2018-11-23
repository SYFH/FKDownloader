//
//  FKTask.h
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKDefine.h"

@class FKDownloadManager;
@class FKTask;

@protocol FKTaskDelegate<NSObject>

// 与通知等价
@optional
- (void)downloader:(FKDownloadManager *)downloader prepareTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didIdleTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willExecuteTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didExecuteTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didResumingTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader progressingTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willChecksumTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didChecksumTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didFinishTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willSuspendTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didSuspendTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willCanceldTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didCancelldTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader errorTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader speedInfo:(FKTask *)task;

@end

@interface FKTask : NSObject <NSCoding>

/**
 任务标示, 由 URL 部分参数通过 SHA256 计算得出, 忽略 URL 参数
 */
@property (nonatomic, strong, readonly) NSString    *identifier;

/**
 任务的下载链接, 只支持 http 和 https, 不合法 URL 会造成断言不通过
 */
@property (nonatomic, strong) NSString              *url;

/**
 保存时的文件名, 注意: 设置时不必添加后缀名
 */
@property (nonatomic, strong) NSString              *fileName;

/**
 文件校验码, 支持 MD5, SHA1, SHA256
 */
@property (nonatomic, strong) NSString              *verification;

/**
 文件校验码类型
 */
@property (nonatomic, assign) VerifyType            verificationType;

/**
 自定义请求头
 */
@property (nonatomic, strong) NSDictionary          *requestHeader;

/**
 父管理器
 */
@property (nonatomic, weak  ) FKDownloadManager     *manager;

/**
 当前任务状态
 */
@property (nonatomic, assign, readonly) TaskStatus  status;

/**
 当前任务的下载进度, progress.totalUnitCount 为文件总大小
 progress.completedUnitCount 为已下载大小, progress.fractionCompleted 为进度百分比
 */
@property (nonatomic, strong, readonly) NSProgress  *progress;

/**
 下载任务的恢复数据
 */
@property (nonatomic, strong, readonly) NSData      *resumeData;

/**
 发生下载失败等问题时保存的 error
 */
@property (nonatomic, strong) NSError               *error;

/**
 进行下载任务的 task
 */
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;

/**
 预期下载完成需要的时间
 */
@property (nonatomic, strong, readonly) NSNumber    *estimatedTimeRemaining;

/**
 预期下载完成需要的时间, 格式化输出: 时分秒, 不满一分钟只显示秒, 时分同理
 */
@property (nonatomic, strong, readonly) NSString    *estimatedTimeRemainingDescription;

/**
 每秒下载字节速度
 */
@property (nonatomic, strong, readonly) NSNumber    *bytesPerSecondSpeed;

/**
 每秒下载字节速度, 格式化: BytesFormatter/s, 自动计算 KB, MB, GB
 */
@property (nonatomic, strong, readonly) NSString    *bytesPerSecondSpeedDescription;

/**
 是否通过校验
 */
@property (nonatomic, assign, readonly) BOOL        isPassChecksum;

/**
 任务进度监听 Blok
 */
@property (nonatomic, copy  ) FKProgress            progressBlock;

/**
 任务状态监听 Block
 */
@property (nonatomic, copy  ) FKStatus              statusBlock;

/**
 任务速度监听 Block
 */
@property (nonatomic, copy  ) FKSpeed               speedBlock;


/**
 任务状态与进度监听 Delegate, 推荐使用此方式接受任务状态和进度
 */
@property (nonatomic, weak  ) id<FKTaskDelegate>    delegate;


#pragma mark - Operation
/**
 恢复 task, 不推荐手动调用, 可直接使用 +[FKDownloadManager restory]

 @param task task
 */
- (void)restore:(NSURLSessionDownloadTask *)task;

/**
 设置附加数据

 @param info 附加数据
 */
- (void)settingInfo:(NSDictionary *)info;

/**
 开始准备任务, 如创建 task, 添加 KVO, 持久化等
 */
- (void)reday;

/**
 执行任务
 */
- (void)execute;

/**
 暂停任务, 实质上使用了系统的 -[NSURLSessionDownloadTask cancelByProducingResumeData:] 方法, 用以保存家恢复数据
 */
- (void)suspend;

/**
 暂停的上级调用方法

 @param complete 暂停并保存恢复数据完成
 */
- (void)suspendWithComplete:(void (^)(void))complete;

/**
 恢复任务
 */
- (void)resume;

/**
 取消任务
 */
- (void)cancel;

/**
 检验文件

 @return 是否通过校验
 */
- (BOOL)checksum;

/**
 清除任务, 从管理器中排除, 并解除持久化
 */
- (void)clear;

/**
 更新恢复数据中的 URL, 任务开始前操作有效
 仅在有恢复数据时做更新 URL, 否则只更新属性值

 @param url 更新后的 URL
 */
- (void)updateURL:(NSString *)url;


#pragma mark - Send Info
/**
 发送 TaskStatusIdle 状态信息
 */
- (void)sendIdleInfo;

/**
 发送 TaskStatusSuspend 状态信息
 */
- (void)sendSuspendInfo;

/**
 发送 TaskStatusCancelld 状态信息
 */
- (void)sendCancelldInfo;

/**
 发送 TaskStatusChecking 状态信息
 */
- (void)sendChecksumInfo;

/**
 发送 TaskStatusFinish 状态信息
 */
- (void)sendFinishInfo;

/**
 发送 TaskStatusUnknowError 状态信息

 @param error 错误实例
 */
- (void)sendErrorInfo:(NSError *)error;

/**
 发送任务下载进度信息
 */
- (void)sendProgressInfo;

/**
 发送任务下载速度/预期时间信息
 */
- (void)sendSpeedInfo;


#pragma mark - Description
/**
 任务状态描述

 @param status 任务状态
 @return 状态描述
 */
- (NSString *)statusDescription:(TaskStatus)status;


#pragma mark - Basic
/**
 任务下载保存地址

 @return 地址
 */
- (NSString *)filePath;

/**
 任务恢复数据保存地址

 @return 地址
 */
- (NSString *)resumeFilePath;

/**
 任务是否有恢复数据

 @return 是否有恢复数据
 */
- (BOOL)isHasResumeData;

/**
 任务文件是否已存在

 @return 是否已存在
 */
- (BOOL)isFinish;

@end
