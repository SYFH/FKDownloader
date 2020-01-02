//
//  FKSessionDelegater.h
//  FKDownloader
//
//  Created by norld on 2019/12/29.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 统一实现系统代理, 进行任务代理处理
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKSessionDelegater : NSObject<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

+ (instancetype)delegater;

@end

NS_ASSUME_NONNULL_END
