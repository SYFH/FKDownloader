//
//  FKScheduler.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责管理任务、过滤任务，存储、去重任务都在此控制
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKScheduler : NSObject

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
