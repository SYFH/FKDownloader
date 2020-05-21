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
    NSLog(@"%@: %ld", url, state);
}

- (void)downloadURL:(NSString *)url countOfBytesReceived:(int64_t)countOfBytesReceived countOfBytesPreviousReceived:(int64_t)countOfBytesPreviousReceived countOfBytesExpectedToReceive:(int64_t)countOfBytesExpectedToReceive {
    
    NSLog(@"%@: %lld, %lld, %lld", url, countOfBytesReceived, countOfBytesPreviousReceived, countOfBytesExpectedToReceive);
}

@end
