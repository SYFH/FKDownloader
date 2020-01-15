//
//  FKControl.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责控制任务状态, 对外接口
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKControl : NSObject

/// 链接对应的状态
/// @param url 请求链接
+ (FKState)stateWithURL:(NSString *)url;

/// 激活已取消任务
/// @param url 请求链接
+ (void)actionRequestWithURL:(NSString *)url;

/// 暂停任务
/// @param url 请求链接
+ (void)suspendRequestWithURL:(NSString *)url;

/// 继续任务
/// @param url 请求链接
+ (void)resumeRequestWithURL:(NSString *)url;

/// 取消任务
/// @param url 请求链接
+ (void)cancelRequestWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
