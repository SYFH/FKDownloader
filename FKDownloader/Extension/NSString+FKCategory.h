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

- (NSString *)MD5;
- (NSData *)MD5Data;
- (NSString *)SHA1;
- (NSData *)SHA1Data;
- (NSString *)SHA256;
- (NSData *)SHA256Data;
- (NSString *)SHA512;
- (NSData *)SHA512Data;

@end

NS_ASSUME_NONNULL_END
