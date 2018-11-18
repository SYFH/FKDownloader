//
//  NSString+FKDownload.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FKDownload)

- (NSString *)MD5;
- (NSString *)SHA1;
- (NSString *)SHA256;
- (NSString *)SHA512;

@end
