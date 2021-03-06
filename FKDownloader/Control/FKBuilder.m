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
#import "FKCoder.h"

@interface FKBuilder ()

@property (nonatomic, strong) NSString *normalURL;
@property (nonatomic, strong) NSString *urlHash;
@property (nonatomic, strong) NSString *requestSingleID;
@property (nonatomic, assign) unsigned long long idx;
@property (nonatomic, assign, getter=isPrepared) BOOL prepared;

@end

@implementation FKBuilder

+ (instancetype)buildWithURL:(NSString *)url {
    // 校验 URL 是否合法
    NSString *encodeURL = [FKCoder encode:url];
    NSURL *URL = [NSURL URLWithString:encodeURL];
    if (URL) {
        return [[FKBuilder alloc] initWithNormalURL:url];
    } else {
        return nil;
    }
}

- (instancetype)initWithNormalURL:(NSString *)URL {
    NSURL *url = [NSURL URLWithString:[FKCoder encode:URL]];
    self = [super initWithURL:url];
    if (self) {
        self.normalURL = URL;
        
        // 计算Hash
        self.urlHash = self.normalURL.SHA256;
        
        // 创建请求编号
        self.idx = FKSingleNumber.shared.number;
        self.requestSingleID = [NSString stringWithFormat:@"%09llu_%@", self.idx, self.urlHash];
        [FKLogger debug:@"%@\n创建唯一请求编号", self.requestSingleID];
    }
    return self;
}

+ (void)loadCacheWithURL:(NSString *)url {
    [[FKScheduler shared] loadCacheWithURL:url];
}

- (void)prepare {
    if (self.prepared) { return; }
    if (self.normalURL.length == 0) { return; }
    self.prepared = YES;
    
    // 创建缓存模型
    FKCacheRequestModel *model = [[FKCacheRequestModel alloc] init];
    model.requestID = self.urlHash;
    model.requestSingleID = self.requestSingleID;
    model.idx = self.idx;
    model.url = self.normalURL;
    model.request = [self copy];
    model.downloadType = self.downloadType;
    [FKLogger debug:@"%@\n%@\n%@\n创建请求缓存", model.requestID, model.requestSingleID, model.url];
    
    // 进行预处理
    [[FKScheduler shared] prepareRequest:model];
}

@end
