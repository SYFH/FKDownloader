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
#import "FKCacheModel.h"
#import "FKScheduler.h"

@interface FKBuilder ()

@property (nonatomic, assign, getter=isPrepared) BOOL prepared;

@end

@implementation FKBuilder

+ (instancetype)buildWithURL:(NSString *)url {
    return [[FKBuilder alloc] initWithURL:[NSURL URLWithString:url]];
}

- (void)prepare {
    @synchronized (self) {
        if (self.prepared) { return; }
        self.prepared = YES;
        
        // 创建请求编号
        NSString *requestID = [NSString stringWithFormat:@"%09llu_%@", FKSingleNumber.shared.number, self.URL.absoluteString.SHA256];
        
        // 创建缓存模型
        FKCacheRequestModel *model = [[FKCacheRequestModel alloc] init];
        model.requestID = requestID;
        model.url = self.URL.absoluteString;
        model.request = [self copy];
        
        // 进行中间件处理
        
        // 进行预处理
        [[FKScheduler shared] prepareRequest:model];
    }
}

@end
