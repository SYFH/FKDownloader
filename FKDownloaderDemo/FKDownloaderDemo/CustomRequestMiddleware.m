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
    NSLog(@"CustomRequestMiddleware: %@", request);
    return request;
}

- (NSUInteger)priority {
    return 0;
}

@end
