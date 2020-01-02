//
//  FKEngine.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 核心引擎，负责控制和调度各个组件，保证数据流转
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKEngine : NSObject

+ (instancetype)engine;

// 任务入口
- (void)startWithTask:(NSString *)taskID;
- (void)cancelWithTask:(NSString *)taskID;
- (void)suspendWithTask:(NSString *)taskID;
- (void)resumeWithTask:(NSString *)taskID;

// 请求入口
- (void)processRequest:(NSMutableURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
