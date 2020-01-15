//
//  FKControl.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKControl.h"

#import "NSString+FKCategory.h"

#import "FKEngine.h"
#import "FKCache.h"

@implementation FKControl

+ (FKState)stateWithURL:(NSString *)url {
    return [[FKCache cache] stateRequestWithRequestID:url.SHA256];
}

+ (void)actionRequestWithURL:(NSString *)url {
    [[FKEngine engine] actionRequestWithURL:url];
}

+ (void)suspendRequestWithURL:(NSString *)url {
    [[FKEngine engine] suspendRequestWithURL:url];
}

+ (void)resumeRequestWithURL:(NSString *)url {
    [[FKEngine engine] resumeRequestWithURL:url];
}

+ (void)cancelRequestWithURL:(NSString *)url {
    [[FKEngine engine] cancelRequestWithURL:url];
}

@end
