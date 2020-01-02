//
//  FKSingleNumber.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责创建顺序不重复的编号
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKSingleNumber : NSObject

+ (instancetype)shared;

/// 初始原子数字, 务必在主线程中使用, 子线程中不保证初始化为原子性
- (void)initialNumber;
- (unsigned long long)number;

@end

NS_ASSUME_NONNULL_END
