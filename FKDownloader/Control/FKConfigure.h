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

@property (nonatomic, assign) NSTimeInterval timeoutTimeInterval;

+ (instancetype)configure;

@end

NS_ASSUME_NONNULL_END
