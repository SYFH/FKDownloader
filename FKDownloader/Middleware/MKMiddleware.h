//
//  MKMiddleware.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 管理中间件, 对外接口
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// 请求中间件协议, 在下载前调用, 进行处理 NSURLRequest
@protocol FKRequestMiddlewareProtocol <NSObject>

@required

/// 优先级, 数字越小, 优先级越高, 数字相同时则随机顺序
+ (NSUInteger)priority;

/// 处理
/// @param task 下载请求
+ (NSMutableURLRequest *)processRequest:(NSMutableURLRequest *)task;

@end


/// 响应中间件协议, 在下载返回响应后调用, 进行处理 NSURLResponse
@protocol FKResponseMiddlewareProtocol <NSObject>

@required

/// 优先级, 数字越小, 优先级越高, 数字相同时则随机顺序
+ (NSUInteger)priority;

/// 处理
/// @param task 下载请求
+ (NSURLResponse *)processResponse:(NSURLResponse *)task;

@end

@interface MKMiddleware : NSObject

+ (instancetype)shared;

- (void)registeRequestMiddleware:(id<FKRequestMiddlewareProtocol>)middleware;
- (void)registeResponseMiddleware:(id<FKResponseMiddlewareProtocol>)middleware;

@end

NS_ASSUME_NONNULL_END
