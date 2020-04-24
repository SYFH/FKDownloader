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
            [FKConfigure configure].completionHandler = nil;
        });
    }
}


#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                           didCompleteWithError:(nullable NSError *)error {

    [[FKEngine engine] processTask:task didCompleteWithError:error];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
                              didFinishDownloadingToURL:(NSURL *)location {
    
    [[FKEngine engine] processCompleteDownload:downloadTask location:location];
}

@end
