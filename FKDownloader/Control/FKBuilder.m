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
#import "FKLogger.h"

@interface FKBuilder ()

@property (nonatomic, strong) NSString *urlHash;
@property (nonatomic, strong) NSString *requestSingleID;
@property (nonatomic, assign, getter=isPrepared) BOOL prepared;

@end

@implementation FKBuilder

+ (instancetype)buildWithURL:(NSString *)url {
    return [[FKBuilder alloc] initWithURL:[NSURL URLWithString:url]];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    if (self) {
        // 计算Hash
        self.urlHash = self.URL.absoluteString.SHA256;
        
        // 创建请求编号
        self.requestSingleID = [NSString stringWithFormat:@"%09llu_%@", FKSingleNumber.shared.number, self.urlHash];
        [FKLogger info:@"创建唯一请求编号: %@", self.requestSingleID];
    }
    return self;
}

- (void)prepare {
    @synchronized (self) {
        if (self.prepared) { return; }
        self.prepared = YES;
        
        // 创建缓存模型
        FKCacheRequestModel *model = [[FKCacheRequestModel alloc] init];
        model.requestID = self.urlHash;
        model.requestSingleID = self.requestSingleID;
        model.url = self.URL.absoluteString;
        model.request = [self copy];
        [FKLogger info:@"创建缓存请求模型: %@", model];
        
        // 进行预处理
        [[FKScheduler shared] prepareRequest:model];
    }
}

@end
