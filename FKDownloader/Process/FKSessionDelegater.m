//
//  FKSessionDelegater.m
//  FKDownloader
//
//  Created by norld on 2019/12/29.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKSessionDelegater.h"

#import "FKEngine.h"
#import "FKObserver.h"
#import "FKCache.h"
#import "FKCacheModel.h"
#import "FKConfigure.h"
#import "FKLogger.h"
#import "FKMiddleware.h"

@implementation FKSessionDelegater

+ (instancetype)delegater {
    static FKSessionDelegater *instance = nil;
    static dispatch_once_t sessionDelegaterOnceToken;
    dispatch_once(&sessionDelegaterOnceToken, ^{
        instance = [[FKSessionDelegater alloc] init];
    });
    return instance;
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        /*disposition：如何处理证书
         NSURLSessionAuthChallengePerformDefaultHandling:默认方式处理
         NSURLSessionAuthChallengeUseCredential：使用指定的证书
         NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消请求
         */
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    //安装证书
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if ([FKConfigure configure].completionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [FKConfigure configure].completionHandler();
        });
        [FKConfigure configure].completionHandler = nil;
    }
}


#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                           didCompleteWithError:(nullable NSError *)error {
    
    if (error) {
        // 区分错误状态
        NSString *requestID = task.taskDescription;
        FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
        NSInteger code = error.code;
        NSDictionary *errorUserInfo = error.userInfo;
        if (code == NSURLErrorCancelled) {
            if ([errorUserInfo.allKeys containsObject:@"NSURLSessionDownloadTaskResumeData"]) {
                // 下载任务进行带有恢复数据的暂停
                NSData *resumeData = [errorUserInfo objectForKey:@"NSURLSessionDownloadTaskResumeData"];
                info.resumeData = resumeData;
                info.state = FKStateSuspend;
            } else {
                // 普通取消或不支持断点下载的链接
                info.state = FKStateCancel;
            }
        } else {
            // 其他错误, 如网路未连接, 超时, 返回数据错误等
            info.state = FKStateError;
            info.error = error;
        }
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:requestID];
    }
    
    // 使用中间件处理响应
    for (id<FKResponseMiddlewareProtocol> middleware in [FKMiddleware shared].responseMiddlewareArray) {
        if ([middleware respondsToSelector:@selector(processResponse:)]) {
            FKResponse *response = [[FKResponse alloc] init];
            response.originalURL = [[FKCache cache] requestWithRequestID:task.taskDescription].url;
            response.response = task.response;
            response.filePath = [[FKCache cache] requestExpectedFilePathWithRequestID:task.taskDescription];
            response.error = error;
            [middleware processResponse:response];
        }
    }
    [FKLogger debug:@"对响应进行中间件处理"];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location {
    
    [[FKEngine engine] processCompleteDownload:downloadTask location:location];
}

@end
