//
//  FKCoder.m
//  FKDownloader
//
//  Created by norld on 2020/1/16.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKCoder.h"

@implementation FKCoder

+ (NSString *)encode:(NSString *)url {
    // 解码至原始链接, 防止多次编码导致请求失败
    NSString *decode = url;
    while (![decode isEqualToString:[FKCoder decode:decode]]) {
        decode = [FKCoder decode:decode];
    }
    
    // 使用 URLQueryAllowedCharacterSet 会导致 fragment 编码错误, 需要分开编码
    NSString *decodeURL = @"";
    NSRange fragmentRange = [decode rangeOfString:@"#" options:NSBackwardsSearch];
    if (fragmentRange.location == NSNotFound) {
        decodeURL = [decode stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {
        NSString *leftString = [decode substringToIndex:fragmentRange.location];
        NSString *rightString = [decode substringFromIndex:fragmentRange.location + 1];
        decodeURL = [NSString stringWithFormat:@"%@#%@", [leftString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], [rightString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    }
    
    return decodeURL;
}

+ (NSString *)decode:(NSString *)url {
    return [url stringByRemovingPercentEncoding];
}

@end
