//
//  FKDefine.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/22.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
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
extern FKNotificationName const FKTaskDidExecuteNotication;
extern FKNotificationName const FKTaskProgressNotication;
extern FKNotificationName const FKTaskDidResumingNotification;
extern FKNotificationName const FKTaskWillChecksumNotification;
extern FKNotificationName const FKTaskDidChecksumNotification;
extern FKNotificationName const FKTaskDidFinishNotication;
extern FKNotificationName const FKTaskErrorNotication;
extern FKNotificationName const FKTaskWillSuspendNotication;
extern FKNotificationName const FKTaskDidSuspendNotication;
extern FKNotificationName const FKTaskWillCancelldNotication;
extern FKNotificationName const FKTaskDidCancelldNotication;
extern FKNotificationName const FKTaskSpeedInfoNotication;

typedef NSString * FKTaskInfoName;
extern FKTaskInfoName const FKTaskInfoURL;
extern FKTaskInfoName const FKTaskInfoFileName;
extern FKTaskInfoName const FKTaskInfoVerificationType;
extern FKTaskInfoName const FKTaskInfoVerification;
extern FKTaskInfoName const FKTaskInfoRequestHeader;

typedef void(^FKStatus  )   (FKTask *task); // 状态变动 Block
typedef void(^FKProgress)   (FKTask *task); // 进度变动 Block
typedef void(^FKSpeed   )   (FKTask *task); // 速度/预期时间 Block

typedef NS_ENUM(NSInteger, TaskStatus) {
    TaskStatusNone,         // 无状态, 仅表示已加入队列
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
    VerifyTypeMD5,
    VerifyTypeSHA1,
    VerifyTypeSHA256,
    VerifyTypeSHA512
};

typedef NS_OPTIONS(NSInteger, DeviceModel) {
    DeviceModelAirPods,
    DeviceModelAppleTV,
    DeviceModelAppleWatch,
    DeviceModelHomePod,
    DeviceModeliPad,
    DeviceModeliPadMini,
    DeviceModeliPhone,
    DeviceModeliPodTouch,
};
