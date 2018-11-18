//
//  FKChecksum.m
//  FKDownloader
//
//  Created by Norld on 2018/11/18.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKChecksum.h"
#import <CommonCrypto/CommonDigest.h>

@implementation FKChecksum

+ (NSString *)MD5:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char digest[outputLength];
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done) {
        @autoreleasepool {
            NSData* fileData = [handle readDataOfLength:4 * 1024 * 1024];
            CC_MD5_Update(&md5, [fileData bytes], (unsigned int)[fileData length]);
            if ([fileData length] == 0) { done = YES; }
        }
    }
    CC_MD5_Final(digest, &md5);
    return [self toHexString:digest length:outputLength];
}

+ (NSString *)SHA1:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char digest[outputLength];
    CC_SHA1_CTX sha1;
    CC_SHA1_Init(&sha1);
    
    BOOL done = NO;
    while(!done) {
        @autoreleasepool {
            NSData* fileData = [handle readDataOfLength:4 * 1024 * 1024];
            CC_SHA1_Update(&sha1, [fileData bytes], (unsigned int)[fileData length]);
            if ([fileData length] == 0) { done = YES; }
        }
    }
    CC_SHA1_Final(digest, &sha1);
    return [self toHexString:digest length:outputLength];
}

+ (NSString *)SHA256:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char digest[outputLength];
    CC_SHA256_CTX sha256;
    CC_SHA256_Init(&sha256);
    
    BOOL done = NO;
    while(!done) {
        @autoreleasepool {
            NSData* fileData = [handle readDataOfLength:4 * 1024 * 1024];
            CC_SHA256_Update(&sha256, [fileData bytes], (unsigned int)[fileData length]);
            if ([fileData length] == 0) { done = YES; }
        }
    }
    CC_SHA256_Final(digest, &sha256);
    return [self toHexString:digest length:outputLength];
}

+ (NSString *)SHA512:(NSString *)path {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char digest[outputLength];
    CC_SHA512_CTX sha512;
    CC_SHA512_Init(&sha512);
    
    BOOL done = NO;
    while(!done) {
        @autoreleasepool {
            NSData* fileData = [handle readDataOfLength:4 * 1024 * 1024];
            CC_SHA512_Update(&sha512, [fileData bytes], (unsigned int)[fileData length]);
            if ([fileData length] == 0) { done = YES; }
        }
    }
    CC_SHA512_Final(digest, &sha512);
    return [self toHexString:digest length:outputLength];
}

+ (NSString *)toHexString:(unsigned char*)data length:(unsigned int)length {
    NSMutableString *hash = [NSMutableString stringWithCapacity:length * 2];
    for (unsigned int i = 0; i < length; i++) {
        [hash appendFormat:@"%02x", data[i]];
        data[i] = 0;
    }
    return [hash copy];
}

@end
