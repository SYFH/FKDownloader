//
//  CustomRequestMiddleware.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/15.
//  Copyright © 2020 norld. All rights reserved.
//

#import "CustomRequestMiddleware.h"

@implementation CustomRequestMiddleware
@synthesize priority;

- (NSMutableURLRequest *)processRequest:(NSMutableURLRequest *)request {
    // 添加 User-Agent
    [request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (NSUInteger)priority {
    return 0;
}

@end
