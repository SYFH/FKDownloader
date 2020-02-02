//
//  TestMiddleware.h
//  FKDownloaderTests
//
//  Created by norld on 2020/2/2.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FKMiddleware.h"
#import "FKResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestMiddleware : NSObject<FKRequestMiddlewareProtocol, FKResponseMiddlewareProtocol>

@property (nonatomic, strong) NSMutableURLRequest *(^requestMiddlewareHandle)(NSMutableURLRequest* request);
@property (nonatomic, strong) void(^responseMiddlewareHandle)(FKResponse *response);

@end

NS_ASSUME_NONNULL_END
