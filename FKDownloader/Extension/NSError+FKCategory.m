//
//  NSError+FKCategory.m
//  FKDownloader
//
//  Created by norld on 2020/5/16.
//  Copyright © 2020 norld. All rights reserved.
//

#import "NSError+FKCategory.h"

@implementation NSError (FKCategory)

+ (NSError *)fk_errorWithCode:(NSInteger)code message:(NSString *)message {
    return [NSError errorWithDomain:@"com.fk.downloader.error" code:code userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
