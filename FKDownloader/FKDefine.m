//
//  FKDefine.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/22.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKDefine.h"

void checkURL(NSString *address) {
    if (address.length == 0) {
        NSCAssert(NO, @"URL 地址不合法, 请填写正确的 URL!");
    }
    
    NSURL *url = [NSURL URLWithString:address];
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        NSCAssert(url != nil, @"URL 地址不合法, 请填写正确的 URL!");
    } else {
        NSCAssert(NO, @"不支持的 URL");
    }
}

FKNotificationName const FKTaskPrepareNotification      = @"FKTaskPrepareNotification";
FKNotificationName const FKTaskDidIdleNotification      = @"FKTaskDidIdleNotification";
FKNotificationName const FKTaskWillExecuteNotification  = @"FKTaskWillExecuteNotification";
FKNotificationName const FKTaskDidExecuteNotication     = @"FKTaskDidExecuteNotication";
FKNotificationName const FKTaskProgressNotication       = @"FKTaskProgressNotication";
FKNotificationName const FKTaskDidResumingNotification  = @"FKTaskDidResumingNotification";
FKNotificationName const FKTaskWillChecksumNotification = @"FKTaskWillChecksumNotification";
FKNotificationName const FKTaskDidChecksumNotification  = @"FKTaskDidChecksumNotification";
FKNotificationName const FKTaskDidFinishNotication      = @"FKTaskDidFinishNotication";
FKNotificationName const FKTaskErrorNotication          = @"FKTaskErrorNotication";
FKNotificationName const FKTaskWillSuspendNotication    = @"FKTaskWillSuspendNotication";
FKNotificationName const FKTaskDidSuspendNotication     = @"FKTaskDidSuspendNotication";
FKNotificationName const FKTaskWillCancelldNotication   = @"FKTaskWillCancelldNotication";
FKNotificationName const FKTaskDidCancelldNotication    = @"FKTaskDidCancelldNotication";
FKNotificationName const FKTaskSpeedInfoNotication      = @"FKTaskSpeedInfoNotication";

FKTaskInfoName const FKTaskInfoURL              = @"FKTaskInfoURL";
FKTaskInfoName const FKTaskInfoFileName         = @"FKTaskInfoFileName";
FKTaskInfoName const FKTaskInfoVerificationType = @"FKTaskInfoVerificationType";
FKTaskInfoName const FKTaskInfoVerification     = @"FKTaskInfoVerification";
FKTaskInfoName const FKTaskInfoRequestHeader    = @"FKTaskInfoRequestHeader";

FKReachabilityNotificationName const FKReachabilityChangedNotification = @"FKReachabilityChangedNotification";

FKResumeDataKey const FKResumeDataDownloaderURL         = @"NSURLSessionDownloadURL";
FKResumeDataKey const FKResumeDataByteRange             = @"NSURLSessionResumeByteRange";
FKResumeDataKey const FKResumeDataBytesReceived         = @"NSURLSessionResumeBytesReceived";
FKResumeDataKey const FKResumeDataCurrentRequest        = @"NSURLSessionResumeCurrentRequest";
FKResumeDataKey const FKResumeDataInfoLocalPath         = @"NSURLSessionResumeInfoLocalPath";
FKResumeDataKey const FKResumeDataInfoTempFileName      = @"NSURLSessionResumeInfoTempFileName";
FKResumeDataKey const FKResumeDataInfoVersion           = @"NSURLSessionResumeInfoVersion";
FKResumeDataKey const FKResumeDataOriginalRequest       = @"NSURLSessionResumeOriginalRequest";
FKResumeDataKey const FKResumeDataServerDownloadDate    = @"NSURLSessionResumeServerDownloadDate";
