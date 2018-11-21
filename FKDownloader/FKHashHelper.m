//
//  FKChecksum.m
//  FKDownloader
//
//  Created by Norld on 2018/11/18.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKHashHelper.h"
#import "NSData+FKDownload.h"

@implementation FKHashHelper

+ (NSString *)MD5:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    return [data MD5];
}

+ (NSString *)SHA1:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    return [data SHA1];
}

+ (NSString *)SHA256:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    return [data SHA256];
}

+ (NSString *)SHA512:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    return [data SHA512];
}

@end
