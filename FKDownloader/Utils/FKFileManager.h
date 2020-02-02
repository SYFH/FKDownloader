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

@property (nonatomic, strong, readonly) NSString *requestFileExtension;

+ (instancetype)manager;

/// FKDownloader 工作目录
- (NSString *)workFinder;

@end

@interface FKFileManager (SingleNumber)

/// 保存唯一编号
- (void)saveSingleNumber;

/// 读取唯一编号
- (unsigned long long)loadSingleNumber;

@end

@interface FKFileManager (Request)

/// 创建请求文件夹
/// @param request SHA256(Request.URL)
- (void)createRequestFinderWithRequestID:(NSString *)request;

/// 创建请求信息文件
/// @param request 请求信息
- (void)createRequestFileWithRequest:(FKCacheRequestModel *)request;

/// 删除请求文件夹, 包括此路径下的所有文件
/// @param request 请求信息
- (void)deleteRequestFinderWithRequestID:(NSString *)request;

/// 更新请求信息文件
/// @param request 请求信息
- (void)updateRequestFileWithRequest:(FKCacheRequestModel *)request;

/// 检查请求文件是否存在
/// @param request 请求信息
- (BOOL)existLocalRequestWithRequest:(FKCacheRequestModel *)request;

/// 根据请求链接读取本地信息文件
/// @param url 请求链接
/// @param complete 回调
- (void)loadLocalRequestWithURL:(NSString *)url complete:(void(^)(FKCacheRequestModel * _Nullable request))complete;

/// 根据请求标识读取本地信息文件
/// @param requestID 请求标识
- (FKCacheRequestModel* _Nullable)loadLocalRequestWithRequestID:(NSString *)requestID;

/// 移动已完成任务缓存文件
/// @param fileURL 本地缓存文件地址
/// @param requestID 请求标识
/// @param fileName 文件名
- (void)moveFile:(NSURL *)fileURL toRequestFinder:(NSString *)requestID fileName:(NSString *)fileName;

/// 获取文件大小
/// @param path 文件地址
- (unsigned long long)fileSizeWithPath:(NSString *)path;

/// 获取请求文件地址
/// @param requestID 请求标识
/// @param extension 文件后缀
- (NSString *)requestFielPath:(NSString *)requestID extension:(NSString *)extension;

/// 获取已完成请求数据的路径
/// @param requestID 请求标识
- (NSString *)filePathWithRequestID:(NSString *)requestID;

@end

NS_ASSUME_NONNULL_END
