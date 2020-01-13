//
//  FKSingleNumber.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责创建顺序不重复的编号, 以主程序生存周期为始终点
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKSingleNumber : NSObject

+ (instancetype)shared;

- (void)initialNumber;
- (void)initialNumberWithNumber:(unsigned long long)number;
- (unsigned long long)current;
- (unsigned long long)number;

@end

NS_ASSUME_NONNULL_END
