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
    NSString *decode = url;
    while (![decode isEqualToString:[FKCoder decode:decode]]) {
        decode = [FKCoder decode:decode];
    }
    
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
