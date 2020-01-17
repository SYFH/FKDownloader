//
//  FKLogger.m
//  FKDownloader
//
//  Created by norld on 2020/1/8.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKLogger.h"

#import "FKCache.h"
#import "FKCacheModel.h"

@implementation FKLogger

+ (void)debug:(NSString *)debug, ... NS_FORMAT_FUNCTION(1,2) {
#if DEBUG
    va_list args;
    
    va_start(args, debug);
    NSString *str = [[NSString alloc] initWithFormat:debug arguments:args];
    va_end(args);
        
    printf("%s\n\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
}

+ (NSString *)downloadTaskDebugInfo:(NSURLSessionDownloadTask *)downloadTask {
#if DEBUG
    NSString *requestID = downloadTask.taskDescription;
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:requestID];
    return [NSString stringWithFormat:@"%@\n%@\n%@", info.requestID, info.requestSingleID, info.url];
#endif
    return @"";
}

+ (NSString *)requestCacheModelDebugInfo:(FKCacheRequestModel *)requestModel {
#if DEBUG
    return [NSString stringWithFormat:@"%@\n%@\n%@", requestModel.requestID, requestModel.requestSingleID, requestModel.url];
#endif
    return @"";
}

@end
