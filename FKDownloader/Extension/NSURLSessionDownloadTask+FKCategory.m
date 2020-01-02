//
//  NSURLSessionDownloadTask+FKCategory.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "NSURLSessionDownloadTask+FKCategory.h"

@implementation NSURLSessionDownloadTask (FKCategory)

- (void)writeDescriptionWithTaskID:(NSString *)taskID url:(nonnull NSString *)url {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setObject:taskID forKey:@"taskID"];
    [parameters setObject:url forKey:@"url"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingFragmentsAllowed error:nil];
    self.taskDescription = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)taskID {
    NSData *jsonData = [self.taskDescription dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingFragmentsAllowed error:nil];
    return [parameters objectForKey:@"taskID"];
}

- (NSString *)requestURL {
    NSData *jsonData = [self.taskDescription dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingFragmentsAllowed error:nil];
    return [parameters objectForKey:@"url"];
}

@end
