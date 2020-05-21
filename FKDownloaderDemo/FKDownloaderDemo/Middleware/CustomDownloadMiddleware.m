//
//  CustomDownloadMiddleware.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/5/21.
//  Copyright © 2020 norld. All rights reserved.
//

#import "CustomDownloadMiddleware.h"

@implementation CustomDownloadMiddleware

- (void)downloadURL:(NSString *)url state:(FKState)state {
    NSLog(@"url: %@, state: %ld", url, state);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.fk.middleware.download.state" object:nil userInfo:@{@"url": url, @"state": @(state)}];
}

- (void)downloadURL:(NSString *)url countOfBytesReceived:(int64_t)countOfBytesReceived countOfBytesPreviousReceived:(int64_t)countOfBytesPreviousReceived countOfBytesExpectedToReceive:(int64_t)countOfBytesExpectedToReceive {
    
    printf("url: %s, progress: %lld, %lld, %lld\n", url.UTF8String, countOfBytesReceived, countOfBytesPreviousReceived, countOfBytesExpectedToReceive);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.fk.middleware.download.progress" object:nil userInfo:@{@"url": url, @"countOfBytesReceived": @(countOfBytesReceived), @"countOfBytesPreviousReceived": @(countOfBytesPreviousReceived), @"countOfBytesExpectedToReceive": @(countOfBytesExpectedToReceive)}];
}

@end
