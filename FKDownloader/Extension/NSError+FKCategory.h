//
//  NSError+FKCategory.h
//  FKDownloader
//
//  Created by norld on 2020/5/16.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (FKCategory)

/// 创建错误信息
/// @param code 错误代码
/// @param message 错误描述
+ (NSError *)fk_errorWithCode:(NSInteger)code message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
