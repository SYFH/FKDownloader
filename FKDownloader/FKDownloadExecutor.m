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

@implementation FKDownloadExecutor

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.manager.configure.backgroundHandler) {
        self.manager.configure.backgroundHandler();
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    FKTask *downloadTask = [[FKDownloadManager manager] acquire:task.currentRequest.URL.absoluteString];
    if (error) {
        if (error.code == NSURLErrorCancelled) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                // 取消, 带恢复数据
                [resumeData writeToFile:[downloadTask resumeFilePath] atomically:YES];
                [downloadTask setValue:@(TaskStatusSuspend) forKey:@"status"];
                
                if ([downloadTask.delegate respondsToSelector:@selector(downloader:didSuspendTask:)]) {
                    [downloadTask.delegate downloader:downloadTask.manager didSuspendTask:downloadTask];
                }
                if (downloadTask.statusBlock) {
                    __weak typeof(downloadTask) weak = downloadTask;
                    downloadTask.statusBlock(weak);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidSuspendNotication object:nil];
                if ([FKDownloadManager manager].configure.isAutoStart) {
                    [[FKDownloadManager manager] resume:downloadTask.url];
                }
            } else {
                // 取消
                [downloadTask setValue:@(TaskStatusCancelld) forKey:@"status"];
                
                if ([downloadTask.delegate respondsToSelector:@selector(downloader:didCancelldTask:)]) {
                    [downloadTask.delegate downloader:downloadTask.manager didCancelldTask:downloadTask];
                }
                if (downloadTask.statusBlock) {
                    __weak typeof(downloadTask) weak = downloadTask;
                    downloadTask.statusBlock(weak);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidCancelldNotication object:nil];
                
                if ([FKDownloadManager manager].configure.isAutoClearTask) {
                    [[FKDownloadManager manager] remove:task.currentRequest.URL.absoluteString];
                }
            }
        } else {
            // TODO: 暂停后重启 app, task.status 会标识为 Completed, 移动缓存文件会报 "No such file or directory" 错误, 需矫正
            if ([error.domain isEqualToString:NSPOSIXErrorDomain] && (error.code == 2)
                && downloadTask.isHasResumeData) {
                
                
            } else {
                downloadTask.error = error;
                [downloadTask setValue:@(TaskStatusUnknowError) forKey:@"status"];
                
                if ([downloadTask.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
                    [downloadTask.delegate downloader:downloadTask.manager errorTask:downloadTask];
                }
                if (downloadTask.statusBlock) {
                    __weak typeof(downloadTask) weak = downloadTask;
                    downloadTask.statusBlock(weak);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
            }
        }
    } else {
        [downloadTask setValue:@(TaskStatusFinish) forKey:@"status"];
        
        if ([downloadTask.delegate respondsToSelector:@selector(downloader:didFinishTask:)]) {
            [downloadTask.delegate downloader:downloadTask.manager didFinishTask:downloadTask];
        }
        if (downloadTask.statusBlock) {
            __weak typeof(downloadTask) weak = downloadTask;
            downloadTask.statusBlock(weak);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidFinishNotication object:nil];
        
        if ([FKDownloadManager manager].configure.isAutoClearTask) {
            [[FKDownloadManager manager] remove:task.currentRequest.URL.absoluteString];
        }
        [[FKDownloadManager manager] startNextIdleTask];
    }
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    if ([[FKDownloadManager manager].fileManager fileExistsAtPath:task.filePath]) {
        
    } else {
        NSError *error;
        [[FKDownloadManager manager].fileManager copyItemAtPath:location.absoluteString toPath:task.filePath error:&error];
        if (error) {
            task.error = error;
        }
    }
    [downloadTask setValue:@(TaskStatusFinish) forKey:@"status"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    task.progress.completedUnitCount = fileOffset;
}

@end
