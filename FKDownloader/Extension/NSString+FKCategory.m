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

@implementation NSString (FKCategory)

- (NSString *)MD5 {
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_MD5(self.UTF8String, [self UTF8Length], output);
    return [self toHexString:output length:outputLength];
}

- (NSData *)MD5Data {
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_MD5(self.UTF8String, [self UTF8Length], output);
    return [NSData dataWithBytes:output length:outputLength];
}

- (NSString *)SHA1 {
    unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA1(self.UTF8String, [self UTF8Length], output);
    return [self toHexString:output length:outputLength];
}

- (NSData *)SHA1Data {
    unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA1(self.UTF8String, [self UTF8Length], output);
    return [NSData dataWithBytes:output length:outputLength];
}

- (NSString *)SHA256 {
    unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA256(self.UTF8String, [self UTF8Length], output);
    return [self toHexString:output length:outputLength];
}

- (NSString *)SHA512 {
    unsigned int outputLength = CC_SHA512_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA512(self.UTF8String, [self UTF8Length], output);
    return [self toHexString:output length:outputLength];
}

- (NSData *)SHA256Data {
    unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA256(self.UTF8String, [self UTF8Length], output);
    return [NSData dataWithBytes:output length:outputLength];
}

- (NSData *)SHA512Data {
    unsigned int outputLength = CC_SHA512_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_SHA512(self.UTF8String, [self UTF8Length], output);
    return [NSData dataWithBytes:output length:outputLength];
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
    return fileExtension;
}

@end
