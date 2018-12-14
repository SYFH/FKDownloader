//
//  FKDefine.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/22.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKDefine.h"
#import "NSString+FKDownload.h"

void checkURL(NSString *address) {
    if (address.length == 0) {
        NSCAssert(NO, @"URL 地址不合法, 请填写正确的 URL!");
    }
    
    NSURL *url = [NSURL URLWithString:[address encodeEscapedString]];
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
        NSCAssert(url != nil, @"URL 地址不合法, 请填写正确的 URL!");
    } else {
        NSCAssert(NO, @"不支持的 URL");
    }
}

void onQueue(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_async(queue, block);
}

void onWait(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_semaphore_t se = dispatch_semaphore_create(0);
    dispatch_async(queue, ^{
        block();
        dispatch_semaphore_signal(se);
    });
    dispatch_semaphore_wait(se, DISPATCH_TIME_FOREVER);
}

FKNotificationName const FKTaskPrepareNotification      = @"FKTaskPrepareNotification";
FKNotificationName const FKTaskDidIdleNotification      = @"FKTaskDidIdleNotification";
FKNotificationName const FKTaskWillExecuteNotification  = @"FKTaskWillExecuteNotification";
FKNotificationName const FKTaskDidExecuteNotification   = @"FKTaskDidExecuteNotication";
FKNotificationName const FKTaskProgressNotification     = @"FKTaskProgressNotification";
FKNotificationName const FKTaskDidResumingNotification  = @"FKTaskDidResumingNotification";
FKNotificationName const FKTaskWillChecksumNotification = @"FKTaskWillChecksumNotification";
FKNotificationName const FKTaskDidChecksumNotification  = @"FKTaskDidChecksumNotification";
FKNotificationName const FKTaskDidFinishNotification    = @"FKTaskDidFinishNotification";
FKNotificationName const FKTaskErrorNotification        = @"FKTaskErrorNotification";
FKNotificationName const FKTaskWillSuspendNotification  = @"FKTaskWillSuspendNotification";
FKNotificationName const FKTaskDidSuspendNotification   = @"FKTaskDidSuspendNotification";
FKNotificationName const FKTaskWillCancelldNotification = @"FKTaskWillCancelldNotification";
FKNotificationName const FKTaskDidCancelldNotification  = @"FKTaskDidCancelldNotification";
FKNotificationName const FKTaskSpeedInfoNotification    = @"FKTaskSpeedInfoNotification";
FKNotificationName const FKTaskWillRemoveNotification   = @"FKTaskWillRemoveNotification";
FKNotificationName const FKTaskDidRemoveNotification    = @"FKTaskDidRemoveNotification";

FKTaskInfoName const FKTaskInfoURL              = @"FKTaskInfoURL";
FKTaskInfoName const FKTaskInfoFileName         = @"FKTaskInfoFileName";
FKTaskInfoName const FKTaskInfoVerificationType = @"FKTaskInfoVerificationType";
FKTaskInfoName const FKTaskInfoVerification     = @"FKTaskInfoVerification";
FKTaskInfoName const FKTaskInfoRequestHeader    = @"FKTaskInfoRequestHeader";
FKTaskInfoName const FKTaskInfoTags             = @"FKTaskInfoTags";
FKTaskInfoName const FKTaskInfoResumeSavePath   = @"FKTaskInfoResumeSavePath";
FKTaskInfoName const FKTaskInfoSavePath         = @"FKTaskInfoSavePath";
FKTaskInfoName const FKTaskInfoCalculateSpeedWithEstimated  = @"FKTaskInfoCalculateSpeedWithEstimated";

FKReachabilityNotificationName const FKReachabilityChangedNotification = @"FKReachabilityChangedNotification";

NSErrorDomain const FKErrorDomain                   = @"FKErrorDomain";
FKErrorInfoName const FKErrorInfoTaskKey            = @"FKErrorInfoTaskKey";
FKErrorInfoName const FKErrorInfoDescriptKey        = @"FKErrorInfoDescriptKey";
FKErrorInfoName const FKErrorInfoUnderlyingErrorKey = @"FKErrorInfoUnderlyingErrorKey";

FKResumeDataKey const FKResumeDataDownloaderURL         = @"NSURLSessionDownloadURL";
FKResumeDataKey const FKResumeDataByteRange             = @"NSURLSessionResumeByteRange";
FKResumeDataKey const FKResumeDataBytesReceived         = @"NSURLSessionResumeBytesReceived";
FKResumeDataKey const FKResumeDataCurrentRequest        = @"NSURLSessionResumeCurrentRequest";
FKResumeDataKey const FKResumeDataInfoLocalPath         = @"NSURLSessionResumeInfoLocalPath";
FKResumeDataKey const FKResumeDataInfoTempFileName      = @"NSURLSessionResumeInfoTempFileName";
FKResumeDataKey const FKResumeDataInfoVersion           = @"NSURLSessionResumeInfoVersion";
FKResumeDataKey const FKResumeDataOriginalRequest       = @"NSURLSessionResumeOriginalRequest";
FKResumeDataKey const FKResumeDataServerDownloadDate    = @"NSURLSessionResumeServerDownloadDate";
