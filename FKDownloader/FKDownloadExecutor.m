//
//  FKDownloadExecutor.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKDownloadExecutor.h"
#import "FKDownloadManager.h"
#import "FKConfigure.h"
#import "FKTask.h"
#import "FKResumeHelper.h"
#import "NSString+FKDownload.h"

@implementation FKDownloadExecutor

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.manager.configure.backgroundHandler) {
        self.manager.configure.backgroundHandler();
        self.manager.configure.backgroundHandler = nil;
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSURL *url = [NSURL URLWithString:task.taskDescription];
    FKTask *downloadTask = [[FKDownloadManager manager] acquire:url.absoluteString.decodeEscapedString];
    if (downloadTask == nil) {
        // !!!: kill app 后可能有任务会被系统取消, 再次启动时将恢复数据保存到默认文件中.
        if (error.code == NSURLErrorCancelled && error.userInfo[NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            NSString *identifier = task.currentRequest.URL.absoluteString.identifier;
            NSString *resumeFielPath = [[FKDownloadManager manager].configure.resumeSavePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.resume", identifier]];
            [[FKResumeHelper correctResumeData:resumeData] writeToFile:resumeFielPath atomically:YES];
        }
        return;
    }
    
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorUnknown
                                             userInfo:@{NSFilePathErrorKey:url.absoluteString,
                                                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Status Code: %d", (int)statusCode]}];
            [downloadTask sendErrorInfo:error];
            
            // 下载链接有问题, 继续下一个任务
            [[FKDownloadManager manager] startNextIdleTask];
            return;
        }
    }
    
    if (error) {
        if (error.code == NSURLErrorCancelled) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                // 取消, 带恢复数据
                if ([FKResumeHelper checkUsable:resumeData]) {
                    [downloadTask setValue:[FKResumeHelper correctResumeData:resumeData] forKey:@"resumeData"];
                }
                [downloadTask sendSuspendInfo];
            } else {
                // 取消
                [downloadTask sendCancelldInfo];
            }
        } else {
            [downloadTask sendErrorInfo:error];
        }
    }
    
    [[FKDownloadManager manager] startNextIdleTask];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSURL *url = [NSURL URLWithString:downloadTask.taskDescription];
    [[FKDownloadManager manager] setupPath];
    FKTask *task = [[FKDownloadManager manager] acquire:url.absoluteString];
    if (task == nil) {
        return;
    }
    
    if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)downloadTask.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:NSURLErrorUnknown
                                             userInfo:@{NSFilePathErrorKey:url.absoluteString,
                                                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Status Code: %d", (int)statusCode]}];
            [task sendErrorInfo:error];
            return;
        }
    }
    
    if ([[FKDownloadManager manager].fileManager fileExistsAtPath:location.path]) {
        if ([[FKDownloadManager manager].fileManager fileExistsAtPath:task.filePath]) {
            [task sendFinishInfo];
        } else {
            NSError *error;
            [[FKDownloadManager manager].fileManager copyItemAtPath:location.path toPath:task.filePath error:&error];
            if (error) {
                [task sendErrorInfo:error];
            } else {
                if ([task checksum]) {
                    [task sendFinishInfo];
                } else {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                                         code:NSURLErrorUnknown
                                                     userInfo:@{NSFilePathErrorKey:task.url,
                                                                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"File verification failed"]}];
                    [task sendErrorInfo:error];
                }
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                             code:2
                                         userInfo:@{NSFilePathErrorKey:location.path,
                                                    NSLocalizedDescriptionKey: @"The operation couldn’t be completed. No such file or directory"}];
        [task sendErrorInfo:error];
    }
}

@end
