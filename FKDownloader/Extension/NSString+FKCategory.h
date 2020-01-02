//
//  NSString+FKCategory.h
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (FKCategory)

/**
 Creates a MD5 hash of the current string as hex NSString representation.
 */
- (NSString*) MD5;

/**
 Creates a MD5 hash of the current string as NSData representation.
 */
- (NSData*) MD5Data;

/**
 Creates a SHA1 hash of the current string as hex NSString representation.
 */
- (NSString*) SHA1;

/**
 Creates a SHA1 hash of the current string as NSData representation.
 */
- (NSData*) SHA1Data;

/**
 Creates a SHA256 hash of the current string as hex NSString representation.
 */
- (NSString*) SHA256;

/**
 Creates a SHA256 hash of the current string as NSData representation.
 */
- (NSData*) SHA256Data;

/**
 Creates a SHA512 hash of the current string as hex NSString representation.
 */
- (NSString*) SHA512;

/**
 Creates a SHA512 hash of the current string as NSData representation.
 */
- (NSData*) SHA512Data;

@end

NS_ASSUME_NONNULL_END
