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
#import "FKFileManager.h"

@implementation FKControl

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

+ (void)cancelAllRequest {
    [[FKEngine engine] cancelAllRequest];
}

+ (void)trashRequestWithURL:(NSString *)url {
    [[FKEngine engine] trashRequestWithURL:url];
}

@end
