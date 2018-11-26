//
//  NSData+FKDownload.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSData (FKDownload)

- (NSString *)MD5;
- (NSString *)SHA1;
- (NSString *)SHA256;
- (NSString *)SHA512;

@end
NS_ASSUME_NONNULL_END
