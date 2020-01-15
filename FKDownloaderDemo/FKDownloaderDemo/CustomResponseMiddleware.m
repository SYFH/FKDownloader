//
//  CustomResponseMiddleware.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/15.
//  Copyright © 2020 norld. All rights reserved.
//

#import "CustomResponseMiddleware.h"

@implementation CustomResponseMiddleware
@synthesize priority;

- (NSURLResponse *)processResponse:(NSURLResponse *)response {
    NSLog(@"CustomResponseMiddleware: %@", response);
    return response;
}

- (NSUInteger)priority {
    return 0;
}

@end
