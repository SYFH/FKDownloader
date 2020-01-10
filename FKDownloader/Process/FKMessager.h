//
//  FKMessager.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责指定任务的信息接收, 外部获取任务信息的入口
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"

typedef void(^InfoBlock)(int64_t countOfBytesReceived,
                         int64_t countOfBytesExpectedToReceive,
                         FKState state);

NS_ASSUME_NONNULL_BEGIN

@interface FKMessager : NSObject

+ (instancetype)messagerWithURL:(NSString *)url
                           info:(InfoBlock)info;

@end

NS_ASSUME_NONNULL_END
