//
//  FKConfigure.m
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKConfigure.h"

@implementation FKConfigure

+ (instancetype)defaultConfigure {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    FKConfigure *config = [[FKConfigure alloc] init];
    config.isAutoStart          = NO;
    config.isAutoClearTask      = NO;
    config.isBackgroudExecute   = YES;
    config.timeoutInterval      = 30;
    config.sessionIdentifier    = @"com.fk.downloader";
    config.maximumExecutionTask = 5;
    config.rootPath     = [cachePath stringByAppendingPathComponent:@"com.fk.downloader"];
    config.savePath     = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/file"];
    config.resumePath   = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/resume"];
    config.restorePath  = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/downloader.restore"];
    return config;
}


@end
