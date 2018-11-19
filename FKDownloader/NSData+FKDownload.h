//
//  NSData+FKDownload.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (FKDownload)

- (nonnull NSString *)MD5;
- (nonnull NSString *)SHA1;
- (nonnull NSString *)SHA256;
- (nonnull NSString *)SHA512;

@end
