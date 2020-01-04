//
//  FKFileManager.h
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 管理磁盘
 */

#import <Foundation/Foundation.h>

@class FKCacheRequestModel;

NS_ASSUME_NONNULL_BEGIN

@interface FKFileManager : NSObject

+ (instancetype)manager;

- (void)saveSingleNumber;
- (unsigned long long)loadSingleNumber;

- (NSString *)workFinder;

/// 创建请求文件夹
/// @param request SHA256(Request.URL)
- (void)createRequestWithRequestID:(NSString *)request;
- (void)createRequestWithRequest:(FKCacheRequestModel *)model;

@end

NS_ASSUME_NONNULL_END
