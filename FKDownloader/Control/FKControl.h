//
//  FKControl.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责控制任务状态, 对外接口.
 状态变化对应:
 prepare -> idel
 idel -> action
 action -> suspend/cancel
 suspend -> action/cancel
 cancel -> idel
 error -> idel
 complete -> .
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKControl : NSObject

/// 链接对应的状态
/// @param url 请求链接
+ (FKState)stateWithURL:(NSString *)url;

/// 链接对应的错误信息
/// @param url 请求链接
+ (NSError * _Nullable)errorWithURL:(NSString *)url;

/// 激活任务, 对 cancel/error 状态任务起作用
/// @param url 请求链接
+ (void)actionRequestWithURL:(NSString *)url;

/// 暂停任务, 只对 action 状态任务起作用
/// @param url 请求链接
+ (void)suspendRequestWithURL:(NSString *)url;

/// 继续任务, 只对 suspend 状态任务起作用
/// @param url 请求链接
+ (void)resumeRequestWithURL:(NSString *)url;

/// 取消任务, 只对 action/suspend 状态任务起作用
/// @param url 请求链接
+ (void)cancelRequestWithURL:(NSString *)url;

/// 彻底删除任务, 包括本地信息文件
/// @param url 请求链接
+ (void)trashRequestWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
