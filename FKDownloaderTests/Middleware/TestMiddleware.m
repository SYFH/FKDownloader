//
//  TestMiddleware.m
//  FKDownloaderTests
//
//  Created by norld on 2020/2/2.
//  Copyright © 2020 norld. All rights reserved.
//

#import "TestMiddleware.h"

@implementation TestMiddleware
@synthesize priority;

- (NSMutableURLRequest *)processRequest:(NSMutableURLRequest *)request {
    if (self.requestMiddlewareHandle) {
        return self.requestMiddlewareHandle(request);
    } else {
        return request;
    }
}

- (void)processResponse:(FKResponse *)response {
    if (self.responseMiddlewareHandle) {
        self.responseMiddlewareHandle(response);
    }
}

- (NSUInteger)priority {
    return 0;
}

@end
