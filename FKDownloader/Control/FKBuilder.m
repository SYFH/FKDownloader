//
//  FKTasker.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKBuilder.h"

#import "NSString+FKCategory.h"

#import "FKSingleNumber.h"
#import "FKFileManager.h"
#import "FKEngine.h"
#import "FKCache.h"
#import "FKCacheModel.h"

@interface FKBuilder ()

@property (nonatomic, assign, getter=isPrepared) BOOL prepared;

@end

@implementation FKBuilder

+ (instancetype)buildWithURL:(NSString *)url {
    return (FKBuilder *)[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
}

- (void)prepare {
    @synchronized (self) {
        if (self.prepared) { return; }
        self.prepared = YES;
        
        // 检查是否已存在请求
        __block BOOL isExist = NO;
        dispatch_semaphore_t existSemaphore = dispatch_semaphore_create(0);
        [[FKCache cache] existRequestWithURL:self.URL.absoluteString complete:^(BOOL exist) {
            if (exist) {
                isExist = exist;
            }
            dispatch_semaphore_signal(existSemaphore);
        }];
        dispatch_semaphore_wait(existSemaphore, DISPATCH_TIME_FOREVER);
        if (isExist) { return; }
        
        // 创建请求编号
        NSString *requestID = [NSString stringWithFormat:@"%09llu_%@", FKSingleNumber.shared.number, self.URL.absoluteString.SHA256];
        
        // 创建缓存模型
        FKCacheRequestModel *model = [[FKCacheRequestModel alloc] init];
        model.requestID = requestID;
        model.url = self.URL.absoluteString;
        model.request = [self copy];
        
        // 创建任务相关文件与文件夹
        [[FKFileManager manager] createRequestWithRequestID:self.URL.absoluteString.SHA256];
        [[FKFileManager manager] createRequestWithRequest:model];
        
        // 添加到缓存表
        [[FKCache cache] addRequestWithModel:model];
        
        // 保存唯一编号到磁盘
        [[FKFileManager manager] saveSingleNumber];
    }
}

@end
