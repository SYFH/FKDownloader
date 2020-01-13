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
    BOOL isExist = [[FKCache cache] existRequestWithURL:request.url];
    if (isExist) { [FKLogger info:@"请求已存在: %@", request.url]; return; }
    
    // 检查本地是否存在请求信息
    if ([[FKFileManager manager] existLocalRequestWithRequest:request]) {
        // 当添加的任务不在缓存表中, 但本地信息文件存在, 则重新添加到缓存表中, 不进行重复下载
        FKCacheRequestModel *localRequest = [[FKFileManager manager] loadLocalRequestWithRequestID:request.url];
        if (localRequest.state == FKStateComplete) {
            [FKLogger info:@"请求文件已在本地存在, 并且已完成下载"];
        } else {
            [[FKCache cache] addRequestWithModel:localRequest];
            [FKLogger info:@"请求文件已在本地存在, 直接添加到缓存队列"];
        }
    } else {
        // 创建任务相关文件与文件夹
        [[FKFileManager manager] createRequestFinderWithRequestID:request.url.SHA256];
        [[FKFileManager manager] createRequestFileWithRequest:request];
        [FKLogger info:@"创建请求相关文件夹和文件"];
        
        // 添加到缓存表
        request.state = FKStateIdel;
        [[FKCache cache] addRequestWithModel:request];
        [FKLogger info:@"prepare -> idel, 添加到缓存列表: %@", request];
    }
    
    // 保存唯一编号到磁盘
    [[FKFileManager manager] saveSingleNumber];
    [FKLogger info:@"保存唯一编号"];
}

@end
