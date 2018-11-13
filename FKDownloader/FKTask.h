//
//  FKTask.h
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FKDownloadManager;
@class FKTask;

// 人物状态的细化通知, 与枚举 ·TaskStatus· 等同, will 表示开始处理, did 表示处理完成
typedef NSString * FKNotificationName;
extern FKNotificationName const FKTaskDidPrepareNotification;
extern FKNotificationName const FKTaskDidIdleNotification;
extern FKNotificationName const FKTaskWillExecuteNotification;
extern FKNotificationName const FKTaskDidExecuteNotication;
extern FKNotificationName const FKTaskProgressNotication;
extern FKNotificationName const FKTaskDidResumingNotification;
extern FKNotificationName const FKTaskDidFinishNotication;
extern FKNotificationName const FKTaskErrorNotication;
extern FKNotificationName const FKTaskWillSuspendNotication;
extern FKNotificationName const FKTaskDidSuspendNotication;
extern FKNotificationName const FKTaskWillCancelldNotication;
extern FKNotificationName const FKTaskDidCancelldNotication;

typedef void(^FKStatus  )   (FKTask *task); // 状态变动 Block
typedef void(^FKProgress)   (FKTask *task); // 进度变动 Block

typedef NS_ENUM(NSUInteger, TaskStatus) {
    TaskStatusNone,         // 无状态, 仅表示已加入队列
    TaskStatusPrepare,      // 预处理
    TaskStatusIdle,         // 等待中
    TaskStatusExecuting,    // 执行中
    TaskStatusFinish,       // 已完成
    TaskStatusSuspend,      // 已暂停
    TaskStatusResuming,     // 恢复中
    TaskStatusChecking,     // 文件校验中
    TaskStatusCancelld,     // 已取消
    TaskStatusUnknowError   // 未知错误
};

@protocol FKTaskDelegate<NSObject>

// 与通知等价
@optional
- (void)downloader:(FKDownloadManager *)downloader didPrepareTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didIdleTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willExecuteTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didExecuteTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didResumingTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader progressingTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didFinishTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willSuspendTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didSuspendTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willCanceldTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didCancelldTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader errorTask:(FKTask *)task;

@end

@interface FKTask : NSObject

/**
 任务标示, 由 URL 通过 SHA256 计算得出
 */
@property (nonatomic, strong, readonly) NSString    *identifier;

/**
 任务的下载链接, 只支持 http 和 https, 不合法 URL 会造成断言不通过
 */
@property (nonatomic, strong) NSString              *url;

/**
 父管理器
 */
@property (nonatomic, weak  ) FKDownloadManager     *manager;

/**
 当前任务状态
 */
@property (nonatomic, assign, readonly) TaskStatus  status;

/**
 当前任务的下载进度, progress.totalUnitCount 为文件总大小, progress.completedUnitCount 为已下载大小, progress.fractionCompleted 为进度百分比
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

// TODO: 目前下载速度依赖数据接收监听, 后期可改为按指定间隔计算
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
 任务进度监听 Blok
 */
@property (nonatomic, copy  ) FKProgress            progressBlock;

/**
 任务状态监听 Block
 */
@property (nonatomic, copy  ) FKStatus              statusBlock;


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
 清除任务, 从管理器中排除, 并解除持久化
 */
- (void)clear;


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
