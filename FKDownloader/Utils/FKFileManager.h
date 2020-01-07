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
- (void)createRequestFinderWithRequestID:(NSString *)request;

/// 创建请求信息文件
/// @param request 请求信息
- (void)createRequestFileWithRequest:(FKCacheRequestModel *)request;

/// 更新请求信息文件
/// @param request 请求信息
- (void)updateRequestFileWithRequest:(FKCacheRequestModel *)request;

/// 检查请求文件是否存在
/// @param request 请求信息
- (BOOL)existRequestWithRequest:(FKCacheRequestModel *)request;

/// 根据请求链接读取本地信息文件
/// @param url 请求链接
/// @param complete 回调
- (void)loadLocalRequestWithURL:(NSString *)url complete:(void(^)(FKCacheRequestModel * _Nullable request))complete;

@end

NS_ASSUME_NONNULL_END
