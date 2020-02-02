//
//  NSString+FKCategory.h
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 计算 HASH 值
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FKCategory)

- (NSString *)SHA256;

/// MIMEType to file extension
- (NSString *)toExtension;

@end

NS_ASSUME_NONNULL_END
