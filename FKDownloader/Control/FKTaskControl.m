//
//  FKTaskControl.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKTaskControl.h"

#import "FKEngine.h"

@implementation FKTaskControl

+ (void)startWithTask:(NSString *)taskID {
    [[FKEngine engine] startWithTask:taskID];
}

+ (void)cancelWithTask:(NSString *)taskID {
    [[FKEngine engine] cancelWithTask:taskID];
}

+ (void)suspendWithTask:(NSString *)taskID {
    [[FKEngine engine] suspendWithTask:taskID];
}

+ (void)resumeWithTask:(NSString *)taskID {
    [[FKEngine engine] resumeWithTask:taskID];
}

@end
