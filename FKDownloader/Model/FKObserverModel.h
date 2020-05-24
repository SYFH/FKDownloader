//
//  FKObserverModel.h
//  FKDownloader
//
//  Created by norld on 2020/1/2.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 监控信息对象, 负责接收 KVO 回传的信息, 以 Request 为单位
 */

#import <Foundation/Foundation.h>
#import <stdatomic.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKObserverModel : NSObject

/// 任务标示, SHA256(Request.URL)
@property (nonatomic, strong) NSString *requestID;

/// 已下载长度
@property (nonatomic, assign) atomic_uint_fast64_t countOfBytesReceived;

/// 上次已下载长度, 时间间隔与 FKConfigure 配置相关
@property (nonatomic, assign) atomic_uint_fast64_t countOfBytesPreviousReceived;

/// 辅助属性, 记录与上次已下载长度相差长度, 赋值时间间隔与 KVO 监听间隔相关, 在 FKConfigure 配置相关的时间间隔后清零
@property (nonatomic, assign) atomic_uint_fast64_t countOfBytesAccumulateReceived;

/// 预计文件总长度
@property (nonatomic, assign) atomic_uint_fast64_t countOfBytesExpectedToReceive;

@end

NS_ASSUME_NONNULL_END
