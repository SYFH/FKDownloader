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

// TODO: 将状态传递进行封装
#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.manager.configure.backgroundHandler) {
        self.manager.configure.backgroundHandler();
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (task.currentRequest.URL.absoluteString.length == 0) {
        return;
    }
    
    FKTask *downloadTask = [[FKDownloadManager manager] acquire:task.currentRequest.URL.absoluteString];
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            downloadTask.error = [NSError errorWithDomain:NSURLErrorDomain
                                                     code:NSURLErrorUnknown
                                                 userInfo:@{NSFilePathErrorKey: task.currentRequest.URL.absoluteString,
                                                            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Status Code: %d", (int)statusCode]}];
            [downloadTask setValue:@(TaskStatusUnknowError) forKey:@"status"];
            
            if ([downloadTask.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [downloadTask.delegate downloader:downloadTask.manager errorTask:downloadTask];
                });
            }
            if (downloadTask.statusBlock) {
                __weak typeof(downloadTask) weak = downloadTask;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weak.statusBlock(weak);
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
            });
            return;
        }
    }
    
    if (error) {
        if (error.code == NSURLErrorCancelled) {
            NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (resumeData) {
                // 取消, 带恢复数据
                [resumeData writeToFile:[downloadTask resumeFilePath] atomically:YES];
                [downloadTask setValue:@(TaskStatusSuspend) forKey:@"status"];
                
                if ([downloadTask.delegate respondsToSelector:@selector(downloader:didSuspendTask:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [downloadTask.delegate downloader:downloadTask.manager didSuspendTask:downloadTask];
                    });
                }
                if (downloadTask.statusBlock) {
                    __weak typeof(downloadTask) weak = downloadTask;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weak.statusBlock(weak);
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidSuspendNotication object:nil];
                });
            } else {
                // 取消
                [downloadTask setValue:@(TaskStatusCancelld) forKey:@"status"];
                
                if ([downloadTask.delegate respondsToSelector:@selector(downloader:didCancelldTask:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [downloadTask.delegate downloader:downloadTask.manager didCancelldTask:downloadTask];
                    });
                }
                if (downloadTask.statusBlock) {
                    __weak typeof(downloadTask) weak = downloadTask;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weak.statusBlock(weak);
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidCancelldNotication object:nil];
                });
                
                if ([FKDownloadManager manager].configure.isAutoClearTask) {
                    [[FKDownloadManager manager] remove:task.currentRequest.URL.absoluteString];
                }
            }
        } else {
            downloadTask.error = error;
            [downloadTask setValue:@(TaskStatusUnknowError) forKey:@"status"];
            
            if ([downloadTask.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [downloadTask.delegate downloader:downloadTask.manager errorTask:downloadTask];
                });
            }
            if (downloadTask.statusBlock) {
                __weak typeof(downloadTask) weak = downloadTask;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weak.statusBlock(weak);
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
            });
        }
    }
    
    [[FKDownloadManager manager] startNextIdleTask];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    [[FKDownloadManager manager] setupPath];
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)downloadTask.response;
        NSInteger statusCode = httpResponse.statusCode;
        if (statusCode < 200 || statusCode > 300) {
            task.error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorUnknown
                                         userInfo:@{NSFilePathErrorKey: downloadTask.currentRequest.URL.absoluteString,
                                                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Status Code: %d", (int)statusCode]}];
            [task setValue:@(TaskStatusUnknowError) forKey:@"status"];
            
            if ([task.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [task.delegate downloader:task.manager errorTask:task];
                });
            }
            if (task.statusBlock) {
                __weak typeof(task) weak = task;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weak.statusBlock(weak);
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
            });
            return;
        }
    }
    
    if ([[FKDownloadManager manager].fileManager fileExistsAtPath:location.path]) {
        if ([[FKDownloadManager manager].fileManager fileExistsAtPath:task.filePath]) {
            [task setValue:@(TaskStatusFinish) forKey:@"status"];
            
            if ([task.delegate respondsToSelector:@selector(downloader:didFinishTask:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [task.delegate downloader:task.manager didFinishTask:task];
                });
            }
            if (task.statusBlock) {
                __weak typeof(task) weak = task;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weak.statusBlock(weak);
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidFinishNotication object:nil];
            });
            
            if ([FKDownloadManager manager].configure.isAutoClearTask) {
                [[FKDownloadManager manager] remove:downloadTask.currentRequest.URL.absoluteString];
            }
        } else {
            NSError *error;
            [[FKDownloadManager manager].fileManager copyItemAtPath:location.path toPath:task.filePath error:&error];
            if (error) {
                task.error = error;
                [task setValue:@(TaskStatusUnknowError) forKey:@"status"];
                
                if ([task.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [task.delegate downloader:task.manager errorTask:task];
                    });
                }
                if (task.statusBlock) {
                    __weak typeof(task) weak = task;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weak.statusBlock(weak);
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
                });
            } else {
                [task setValue:@(TaskStatusFinish) forKey:@"status"];
                
                if ([task.delegate respondsToSelector:@selector(downloader:didFinishTask:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [task.delegate downloader:task.manager didFinishTask:task];
                    });
                }
                if (task.statusBlock) {
                    __weak typeof(task) weak = task;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weak.statusBlock(weak);
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskDidFinishNotication object:nil];
                });
                
                if ([FKDownloadManager manager].configure.isAutoClearTask) {
                    [[FKDownloadManager manager] remove:downloadTask.currentRequest.URL.absoluteString];
                }
            }
        }
    } else {
        task.error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                         code:2
                                     userInfo:@{NSFilePathErrorKey: location.path,
                                                NSLocalizedDescriptionKey: @"The operation couldn’t be completed. No such file or directory"}];
        [task setValue:@(TaskStatusUnknowError) forKey:@"status"];
        
        if ([task.delegate respondsToSelector:@selector(downloader:errorTask:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [task.delegate downloader:task.manager errorTask:task];
            });
        }
        if (task.statusBlock) {
            __weak typeof(task) weak = task;
            dispatch_async(dispatch_get_main_queue(), ^{
                weak.statusBlock(weak);
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FKTaskErrorNotication object:nil];
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
    FKTask *task = [[FKDownloadManager manager] acquire:downloadTask.currentRequest.URL.absoluteString];
    task.progress.completedUnitCount = fileOffset;
}

@end
