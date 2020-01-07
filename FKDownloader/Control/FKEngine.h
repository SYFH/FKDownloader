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

/// I/O线程, 串行
@property (nonatomic, strong) NSOperationQueue *ioQueue;

/// 计时器线程, 串行
@property (nonatomic, strong) NSOperationQueue *timerQueue;

+ (instancetype)engine;

/// 配置 Session
- (void)configtureSession;

@end

NS_ASSUME_NONNULL_END
