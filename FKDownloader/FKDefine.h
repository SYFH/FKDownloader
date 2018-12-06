//
//  FKDefine.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/22.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class FKTask;

#ifdef DEBUG
#define FKLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define FKLog(FORMAT, ...)
#endif

extern void checkURL(NSString *address);

// 任务状态的细化通知, 与枚举 ·TaskStatus· 等同, will 表示开始处理, did 表示处理完成
typedef NSString * FKNotificationName;
extern FKNotificationName const FKTaskPrepareNotification;
extern FKNotificationName const FKTaskDidIdleNotification;
extern FKNotificationName const FKTaskWillExecuteNotification;
extern FKNotificationName const FKTaskDidExecuteNotification;
extern FKNotificationName const FKTaskProgressNotification;
extern FKNotificationName const FKTaskDidResumingNotification;
extern FKNotificationName const FKTaskWillChecksumNotification;
extern FKNotificationName const FKTaskDidChecksumNotification;
extern FKNotificationName const FKTaskDidFinishNotification;
extern FKNotificationName const FKTaskErrorNotification;
extern FKNotificationName const FKTaskWillSuspendNotification;
extern FKNotificationName const FKTaskDidSuspendNotification;
extern FKNotificationName const FKTaskWillCancelldNotification;
extern FKNotificationName const FKTaskDidCancelldNotification;
extern FKNotificationName const FKTaskSpeedInfoNotification;

typedef NSString * FKTaskInfoName;
extern FKTaskInfoName const FKTaskInfoURL;
extern FKTaskInfoName const FKTaskInfoFileName;
extern FKTaskInfoName const FKTaskInfoVerificationType;
extern FKTaskInfoName const FKTaskInfoVerification;
extern FKTaskInfoName const FKTaskInfoRequestHeader;
extern FKTaskInfoName const FKTaskInfoTags;
extern FKTaskInfoName const FKTaskInfoResumeSavePath;
extern FKTaskInfoName const FKTaskInfoSavePath;

typedef NSString * FKReachabilityNotificationName;
extern FKReachabilityNotificationName const FKReachabilityChangedNotification;

typedef NSString * FKErrorInfoName;
extern NSErrorDomain const FKErrorDomain;
extern FKErrorInfoName const FKErrorInfoTaskKey;
extern FKErrorInfoName const FKErrorInfoDescriptKey;
extern FKErrorInfoName const FKErrorInfoUnderlyingErrorKey;

typedef NSString * FKResumeDataKey;
extern FKResumeDataKey const FKResumeDataDownloaderURL;
extern FKResumeDataKey const FKResumeDataByteRange;
extern FKResumeDataKey const FKResumeDataBytesReceived;
extern FKResumeDataKey const FKResumeDataCurrentRequest;
extern FKResumeDataKey const FKResumeDataInfoLocalPath;
extern FKResumeDataKey const FKResumeDataInfoTempFileName;
extern FKResumeDataKey const FKResumeDataInfoVersion;
extern FKResumeDataKey const FKResumeDataOriginalRequest;
extern FKResumeDataKey const FKResumeDataServerDownloadDate;

// TODO: 可添加连接服务器中的状态, 以填补网络环境太差的空缺
typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusNone = 0,     // 无状态, 仅表示已加入队列
    TaskStatusPrepare,      // 预处理
    TaskStatusIdle,         // 等待中
    TaskStatusExecuting,    // 执行中
    TaskStatusFinish,       // 已完成
    TaskStatusSuspend,      // 已暂停
    TaskStatusResuming,     // 恢复中
    TaskStatusChecksumming, // 文件校验中
    TaskStatusChecksummed,  // 文件校验完成
    TaskStatusCancelld,     // 已取消
    TaskStatusUnknowError   // 未知错误
};

typedef NS_ENUM(NSInteger, VerifyType) {
    VerifyTypeMD5 = 0,
    VerifyTypeSHA1,
    VerifyTypeSHA256,
    VerifyTypeSHA512
};

typedef NS_OPTIONS(NSInteger, DeviceModel) {
    DeviceModelAirPods = 0,
    DeviceModelAppleTV,
    DeviceModelAppleWatch,
    DeviceModelHomePod,
    DeviceModeliPad,
    DeviceModeliPadMini,
    DeviceModeliPhone,
    DeviceModeliPodTouch,
};

typedef NS_ENUM(NSInteger, NetworkStatus) {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
};

typedef NS_ENUM(NSInteger, TaskError) {
    TaskErrorDeleteFileFaild = 0
};

NS_ASSUME_NONNULL_BEGIN
typedef void(^FKStatus  )   (FKTask *task); // 状态变动 Block
typedef void(^FKProgress)   (FKTask *task); // 进度变动 Block
typedef void(^FKSpeed   )   (FKTask *task); // 速度/预期时间 Block
typedef void(^FKTotalProgress) (NSProgress *progress);  // 总进度变动 Block
NS_ASSUME_NONNULL_END
