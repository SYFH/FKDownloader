//
//  FKMiddleware.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 管理中间件, 对外接口
 */

#import <Foundation/Foundation.h>

#import "FKResponse.h"
#import "FKCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

/// 请求中间件协议, 在下载前调用, 进行处理 NSURLRequest
@protocol FKRequestMiddlewareProtocol <NSObject>

@required

/// 优先级, 数字越小, 优先级越高, 数字相同时则随机顺序
@property (nonatomic, assign) NSUInteger priority;

/// 处理
/// @param request 下载请求
- (NSMutableURLRequest *)processRequest:(NSMutableURLRequest *)request;

@end

typedef void(^ProgressBlock)(int64_t countOfBytesReceived,
                             int64_t countOfBytesPreviousReceived,
                             int64_t countOfBytesExpectedToReceive);
/// 下载中间件, 下载中被调用, 处理状态和进度信息
@protocol FKDownloadMiddlewareProtocol <NSObject>

@optional
- (void)downloadURL:(NSString *)url state:(FKState)state;
- (void)downloadURL:(NSString *)url countOfBytesReceived:(int64_t)countOfBytesReceived
                            countOfBytesPreviousReceived:(int64_t)countOfBytesPreviousReceived
                           countOfBytesExpectedToReceive:(int64_t)countOfBytesExpectedToReceive;

@end


/// 响应中间件协议, 在下载返回响应后调用, 进行处理 NSURLResponse
@protocol FKResponseMiddlewareProtocol <NSObject>

@required

/// 优先级, 数字越小, 优先级越高, 数字相同时则随机顺序
@property (nonatomic, assign) NSUInteger priority;

/// 处理
/// @param response 响应数据
- (void)processResponse:(FKResponse *)response;

@end

@interface FKMiddleware : NSObject

+ (instancetype)shared;

- (void)registeRequestMiddleware:(id<FKRequestMiddlewareProtocol>)middleware;
- (void)registeDownloadMiddleware:(id<FKDownloadMiddlewareProtocol>)middleware;
- (void)registeResponseMiddleware:(id<FKResponseMiddlewareProtocol>)middleware;

/// 获取所有请求中间件, 按照优先级排序
- (NSArray<id<FKRequestMiddlewareProtocol>> *)requestMiddlewareArray;

/// 获取所有下载中间件
- (NSArray<id<FKDownloadMiddlewareProtocol>> *)downloadMiddlewareArray;

/// 获取所有响应中间件, 按照优先级排序
- (NSArray<id<FKResponseMiddlewareProtocol>> *)responseMiddlewareArray;

@end

NS_ASSUME_NONNULL_END
