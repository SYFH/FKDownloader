//
//  FKScheduler.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKScheduler.h"

#import "NSString+FKCategory.h"

#import "FKCache.h"
#import "FKCacheModel.h"
#import "FKFileManager.h"
#import "FKLogger.h"
#import "FKEngine.h"
#import "FKObserver.h"

@interface FKScheduler ()

@end

@implementation FKScheduler

+ (instancetype)shared {
    static FKScheduler *instance = nil;
    static dispatch_once_t FKSchedulerOnceToken;
    dispatch_once(&FKSchedulerOnceToken, ^{
        instance = [[FKScheduler alloc] init];
    });
    return instance;
}

- (void)prepareRequest:(FKCacheRequestModel *)request {
    // 检查是否已存在请求
    BOOL isExist = [[FKCache cache] existRequestWithRequestID:request.requestID];
    if (isExist) { [FKLogger debug:@"%@\n请求已存在", request.url]; return; }
    
    // 检查本地是否存在请求信息
    if ([[FKCache cache] existLocalRequestFileWithRequest:request]) {
        // 当添加的任务不在缓存表中, 但本地信息文件存在, 则重新添加到缓存表中, 不进行重复下载
        FKCacheRequestModel *localRequest = [[FKCache cache] localRequestFileWithRequestID:request.requestID];
        // 清除错误信息
        localRequest.error = nil;
        
        [[FKCache cache] addRequestWithModel:localRequest];
        [FKLogger debug:@"%@\n请求文件已在本地存在, 直接添加到缓存队列", [FKLogger requestCacheModelDebugInfo:localRequest]];
    }
    
    else {
        // 创建任务相关文件与文件夹
        [[FKFileManager manager] createRequestFinderWithRequestID:request.requestID];
        [[FKFileManager manager] createRequestFileWithRequest:request];
        [FKLogger debug:@"%@\n创建请求相关文件夹和文件", [FKLogger requestCacheModelDebugInfo:request]];
        
        // 添加到缓存表
        request.state = FKStateIdel;
        [[FKCache cache] addRequestWithModel:request];
        [[FKCache cache] updateLocalRequestWithModel:request];
        [FKLogger debug:@"%@\nprepare -> idel, 添加到缓存列表", [FKLogger requestCacheModelDebugInfo:request]];
    }
    
    // 保存唯一编号到磁盘
    [[FKFileManager manager] saveSingleNumber];
    [FKLogger debug:@"保存唯一编号"];
}

- (void)actionRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    
    if (info.state == FKStateCancel) {
        info.state = FKStateIdel;
        
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
        [FKLogger debug:@"%@\ncancel -> idel, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];
    }
    
    else if (info.state == FKStateError) {
        info.state = FKStateIdel;
        info.error = nil;
        
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        
        NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
        [downloadTask cancel];
        [[FKObserver observer] removeDownloadTask:downloadTask];
        [[FKCache cache] removeDownloadTask:downloadTask];
        [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
        [FKLogger debug:@"%@\nerror -> idel, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];
    }
}

- (void)suspendRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (info.state == FKStateAction) {
        NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
        [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            // 此处不做处理, 统一在代理中处理所有错误
        }];
    }
}

- (void)resumeRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (info.state == FKStateSuspend) {
        if (info.resumeData.length) {
            NSURLSessionDownloadTask *downloadTask = [[FKEngine engine].backgroundSession downloadTaskWithResumeData:info.resumeData];
            downloadTask.taskDescription = info.requestID;
            [downloadTask resume];
            
            [[FKCache cache] repleaceDownloadTask:downloadTask];
            [[FKObserver observer] observerDownloadTask:downloadTask];
            
            info.state = FKStateAction;
            [[FKCache cache] updateRequestWithModel:info];
            [[FKCache cache] updateLocalRequestWithModel:info];
            [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
            [FKLogger debug:@"%@\nsuspend -> action, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];
        }
    }
}

- (void)cancelRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (info.state == FKStateAction || info.state == FKStateSuspend) {
        NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
        [downloadTask cancel];
        
        [[FKCache cache] removeDownloadTask:downloadTask];
        [[FKObserver observer] removeCacheProgressWithDownloadTask:downloadTask];
        
        info.state = FKStateCancel;
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
        [FKLogger debug:@"%@\naction -> cancen, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];
    }
}

- (void)trashRequestWithURL:(NSString *)url {
    // 取消请求
    [[FKEngine engine] cancelRequestWithURL:url];
    
    // 删除监听
    [[FKObserver observer] removeObserverWithRequestID:url.SHA256];
    
    // 删除本地文件
    [[FKFileManager manager] deleteRequestFinderWithRequestID:url.SHA256];
}

@end
