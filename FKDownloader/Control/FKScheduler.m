//
//  FKScheduler.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKScheduler.h"

#import "NSString+FKCategory.h"

#import "FKCommonHeader.h"
#import "FKCache.h"
#import "FKConfigure.h"
#import "FKCacheModel.h"
#import "FKFileManager.h"
#import "FKLogger.h"
#import "FKEngine.h"
#import "FKObserver.h"
#import "FKResumeData.h"

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

- (void)loadCacheWithURL:(NSString *)url {
    FKCacheRequestModel *localRequest = [[FKCache cache] localRequestFileWithRequestID:url.SHA256];
    if (localRequest) {
        // 清除错误信息
        localRequest.error = nil;
        
        // 添加并更新请求信息
        [[FKCache cache] addRequestWithModel:localRequest];
        [[FKCache cache] updateRequestWithModel:localRequest];
        [FKLogger debug:@"%@\n加载本地请求信息", [FKLogger requestCacheModelDebugInfo:localRequest]];
    }
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
        
        // 对前台下载任务重置部分信息
        if (localRequest.downloadType == FKDownloadTypeForeground) {
            localRequest.state = FKStateSuspend;
            localRequest.receivedLength = 0;
            localRequest.resumeData = nil;
        }
        
        [[FKCache cache] addRequestWithModel:localRequest];
        [[FKCache cache] updateLocalRequestWithModel:localRequest];
        [FKLogger debug:@"%@\n请求文件已在本地存在, 直接添加到缓存队列", [FKLogger requestCacheModelDebugInfo:localRequest]];
        
        // 下载中间件返回任务状态
        [[FKEngine engine] downloadMiddlewareStateWithRequest:localRequest];
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
        
        // 下载中间件返回任务状态
        [[FKEngine engine] downloadMiddlewareStateWithRequest:request];
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
    
    // 调用下载中间件状态返回方法
    [[FKEngine engine] downloadMiddlewareStateWithRequest:info];
}

- (void)suspendRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (!(info.state == FKStateAction || info.state == FKStateIdel)) { return; }
    
    NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
    if (info.downloadType == FKDownloadTypeBackground) {
        if (info.state == FKStateAction) {
            [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                // 此处不做处理, 统一在代理中处理所有错误
            }];
        }
        else if (info.state == FKStateIdel) {
            // 等待中任务的暂停只标记状态
            info.state = FKStateSuspend;
            
            // 更新状态
            [[FKCache cache] updateRequestWithModel:info];
            [[FKCache cache] updateLocalRequestWithModel:info];
            [[FKObserver observer] execFastInfoBlockWithRequestID:requestID];

            // 调用下载中间件状态返回方法
            [[FKEngine engine] downloadMiddlewareStateWithRequest:info];
        }
    } else {
        [downloadTask suspend];
        info.state = FKStateSuspend;
        
        // 更新状态
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:requestID];

        // 调用下载中间件状态返回方法
        [[FKEngine engine] downloadMiddlewareStateWithRequest:info];
    }
}

- (void)suspendAllTask {
    [[[FKCache cache] requestArray] enumerateObjectsUsingBlock:^(FKCacheRequestModel *model, NSUInteger idx, BOOL *stop) {
        [[FKScheduler shared] suspendRequestWithURL:model.url];
    }];
}

- (void)resumeRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (info.state != FKStateSuspend) { return; }
    
    if ([[FKCache cache] actionRequestCount] >= [FKConfigure configure].maxAction) {
        // 超出可执行数量
        info.state = FKStateIdel;

        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
        [FKLogger debug:@"%@\nsuspend -> action, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];

        // 调用下载中间件状态返回方法
        [[FKEngine engine] downloadMiddlewareStateWithRequest:info];
        return;
    }
    
    if (info.downloadType == FKDownloadTypeBackground) {
        if (info.resumeData.length > 0) {
            // 使用正确的恢复数据恢复下载任务
            NSData *resumeData = [FKResumeData correctResumeData:info.resumeData];
            NSURLSessionDownloadTask *downloadTask = [[FKEngine engine].backgroundSession downloadTaskWithResumeData:resumeData];
            downloadTask.taskDescription = info.requestID;
            [downloadTask resume];
            [FKLogger debug:@"使用恢复数据创建 %@", downloadTask];
            
            // 替换下载任务缓存
            [[FKCache cache] repleaceDownloadTask:downloadTask];
            [[FKObserver observer] observerDownloadTask:downloadTask];
            [[FKObserver observer] observerCacheWithDownloadTask:downloadTask];
        } else {
            // 重新创建下载任务
            NSURLSessionDownloadTask *downloadTask = [[FKEngine engine].backgroundSession downloadTaskWithRequest:info.request];
            downloadTask.taskDescription = info.requestID;
            [downloadTask resume];
            [FKLogger debug:@"重新创建 %@", downloadTask];
            
            // 替换下载任务缓存
            [[FKCache cache] repleaceDownloadTask:downloadTask];
            [[FKObserver observer] observerDownloadTask:downloadTask];
            [[FKObserver observer] observerCacheWithDownloadTask:downloadTask];
        }
    } else {
        NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
        if (downloadTask) {
            [downloadTask resume];
        } else {
            // 重新进行下载流程
            downloadTask = [[FKEngine engine].foregroundSession downloadTaskWithRequest:info.request];
            downloadTask.taskDescription = info.requestID;
            [downloadTask resume];
            
            // 缓存请求任务
            [[FKCache cache] addDownloadTask:downloadTask];
            
            // 添加 KVO
            [[FKObserver observer] observerDownloadTask:downloadTask];
            [[FKObserver observer] observerCacheWithDownloadTask:downloadTask];
        }
    }
    
    info.state = FKStateAction;
    [[FKCache cache] updateRequestWithModel:info];
    [[FKCache cache] updateLocalRequestWithModel:info];
    [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
    [FKLogger debug:@"%@\nsuspend -> action, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];
    
    // 调用下载中间件状态返回方法
    [[FKEngine engine] downloadMiddlewareStateWithRequest:info];
}

- (void)resumeAllTask {
    [[[FKCache cache] requestArray] enumerateObjectsUsingBlock:^(FKCacheRequestModel *model, NSUInteger idx, BOOL *stop) {
        if (model.state == FKStateSuspend) {
            [[FKScheduler shared] resumeRequestWithURL:model.url];
        } else {
            [[FKScheduler shared] actionRequestWithURL:model.url];
        }
    }];
}

- (void)cancelRequestWithURL:(NSString *)url {
    NSString *requestID = url.SHA256;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    if (info.state == FKStateAction || info.state == FKStateSuspend || info.state == FKStateIdel || info.state == FKStateError) {
        NSURLSessionDownloadTask *downloadTask = [[FKCache cache] downloadTaskWithRequestID:requestID];
        [downloadTask cancel];
        
        [[FKCache cache] removeDownloadTask:downloadTask];
        [[FKObserver observer] removeCacheProgressWithDownloadTask:downloadTask];
        
        info.state = FKStateCancel;
        info.resumeData = nil;
        info.error = nil;
        info.receivedLength = 0;
        
        [[FKCache cache] updateRequestWithModel:info];
        [[FKCache cache] updateLocalRequestWithModel:info];
        [[FKObserver observer] execFastInfoBlockWithRequestID:info.requestID];
        [FKLogger debug:@"%@\naction -> cancen, 更新本地缓存", [FKLogger requestCacheModelDebugInfo:info]];

        // 调用下载中间件状态返回方法
        [[FKEngine engine] downloadMiddlewareStateWithRequest:info];
    }
}

- (void)trashRequestWithURL:(NSString *)url {
    // 取消请求
    [[FKEngine engine] cancelRequestWithURL:url];
    
    // 删除回调
    [FKMessager removeMessagerInfoWithURL:url];
    
    // 删除监听
    [[FKObserver observer] removeObserverWithRequestID:url.SHA256];
    
    // 删除本地文件
    [[FKFileManager manager] deleteRequestFinderWithRequestID:url.SHA256];
    
    // 删除缓存
    [[FKCache cache] removeDownloadTask:[[FKCache cache] downloadTaskWithRequestID:url.SHA256]];
    [[FKCache cache] removeRequestWithRequestID:url.SHA256];
}

@end
