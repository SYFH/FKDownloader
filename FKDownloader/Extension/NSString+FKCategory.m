//
//  NSString+FKCategory.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "NSString+FKCategory.h"

#import <CommonCrypto/CommonDigest.h>
#import <CoreServices/CoreServices.h>

#import "FKMIMEType.h"

@implementation NSString (FKCategory)

- (NSString *)SHA256 {
    unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA256(self.UTF8String, [self UTF8Length], output);
    return [self toHexString:output length:outputLength];
}

- (unsigned int)UTF8Length {
    return (unsigned int) [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)toHexString:(unsigned char*) data length: (unsigned int) length {
    NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
    for (unsigned int i = 0; i < length; i++) {
        [hash appendFormat:@"%02x", data[i]];
        data[i] = 0;
    }
    return [hash copy];
}

- (NSString *)toExtension {
    CFStringRef mimeType = (__bridge CFStringRef)self;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    NSString *fileExtension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    
    // 部分 MIMEType 无法找到对应的文件后缀
    if (fileExtension.length == 0) {
        fileExtension = [FKMIMEType extensionWithMIMEType:self];
    }
    
    // 如果依然无法找到对应的文件后缀, 则使用 unknown
    if (fileExtension.length == 0) {
        fileExtension = @"unknown";
    }
    
    return fileExtension;
}

@end
