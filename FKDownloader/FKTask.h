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

typedef NSString * FKNotificationName;
extern FKNotificationName const FKTaskWillExecuteNotification;
extern FKNotificationName const FKTaskDidExecuteNotication;
extern FKNotificationName const FKTaskProgressNotication;
extern FKNotificationName const FKTaskDidFinishNotication;
extern FKNotificationName const FKTaskErrorNotication;
extern FKNotificationName const FKTaskWillSuspendNotication;
extern FKNotificationName const FKTaskDidSuspendNotication;
extern FKNotificationName const FKTaskWillCancelldNotication;
extern FKNotificationName const FKTaskDidCancelldNotication;

typedef void(^FKStatus  )   (FKTask *task);
typedef void(^FKProgress)   (FKTask *task);

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

@optional
- (void)downloader:(FKDownloadManager *)downloader willExecuteTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didExecuteTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader progressingTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didFinishTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willSuspendTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didSuspendTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader willCanceldTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader didCancelldTask:(FKTask *)task;
- (void)downloader:(FKDownloadManager *)downloader errorTask:(FKTask *)task;

@end

@interface FKTask : NSObject

@property (nonatomic, strong, readonly) NSString    *identifier;
@property (nonatomic, strong) NSString              *url;
@property (nonatomic, weak  ) FKDownloadManager     *manager;
@property (nonatomic, assign, readonly) TaskStatus  status;
@property (nonatomic, strong, readonly) NSProgress  *progress;
@property (nonatomic, strong, readonly) NSData      *resumeData;
@property (nonatomic, strong) NSError               *error;
@property (nonatomic, strong, readonly) NSString    *speed;

@property (nonatomic, copy  ) FKProgress            progressBlock;
@property (nonatomic, copy  ) FKStatus              statusBlock;
@property (nonatomic, weak  ) id<FKTaskDelegate>    delegate;

- (void)restore:(NSURLSessionDownloadTask *)task;
- (void)reday;
- (void)execute;
- (void)suspend;
- (void)resume;
- (void)cancel;
- (void)clear;

- (void)sendProgressInfo;

- (void)addProgressObserver;
- (void)removeProgressObserver;

- (NSString *)statusDescription:(TaskStatus)status;

- (NSString *)filePath;
- (NSString *)resumeFilePath;
- (BOOL)isHasResumeData;
- (BOOL)isFinish;

@end
