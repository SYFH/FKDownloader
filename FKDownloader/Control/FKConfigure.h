//
//  FKConfigure.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 核心配置, 负责配置下载中需要的通用参数
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKConfigure : NSObject

/// 最大执行任务数量, 默认 3, 范围 1~6, 生成 Session 后可更改, 但超出的正在执行
/// 的任务不受影响, 直至正在执行任务数量小于此值后, 之后的任务才可被控制
@property (nonatomic, assign) unsigned int maxAction;

/// 配置模版, 后台下载, 默认为支持蜂窝网络, 可进行更多自定义配置
@property (nonatomic, strong, readonly) NSURLSessionConfiguration *templateBackgroundConfiguration;

/// 后台下载标识符
@property (nonatomic, strong, readonly) NSString *backgroundSessionIdentifier;

/// 系统后台下载回调设置, -[AppDelegate application:handleEventsForBackgroundURLSession:completionHandler] 中使用
@property (nonatomic, strong, nullable) void(^completionHandler)(void);

+ (instancetype)configure;

/// 使配置生效, 请在程序启动时, 配置完成后调用
- (void)take;

/// 激活队列, 进行任务的开始
- (void)activateQueue;

@end

NS_ASSUME_NONNULL_END
