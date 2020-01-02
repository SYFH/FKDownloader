//
//  FKTaskBuilder.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责创建任务, 设定任务的基本信息, 对外接口
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKTaskBuilder : NSObject

@property (nonatomic, strong, readonly) NSArray<NSMutableURLRequest *> *requests;

/// 根据 URLs 创建一个任务, 每个任务可接受多个下载链接
/// @param urls 下载链接
+ (instancetype)builderWithURLs:(NSArray<NSString *> *)urls header:(NSDictionary *)header;

/// 获取当前任务的唯一标识
- (NSString *)taskID;

/// 将任务放入预处理队列中
- (void)prepare;

@end

NS_ASSUME_NONNULL_END
