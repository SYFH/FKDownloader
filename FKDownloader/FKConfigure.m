//
//  FKConfigure.m
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKConfigure.h"

@implementation FKConfigure

+ (nonnull instancetype)defaultConfigure {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    FKConfigure *config = [[FKConfigure alloc] init];
    config.isAutoStart          = NO;
    config.isAutoClearTask      = NO;
    config.isBackgroudExecute   = YES;
    config.isFileChecksum       = NO;
    config.isAllowCellular      = NO;
    config.isAutoCoding         = YES;
    config.isDeleteFinishFile   = NO;
    config.timeoutInterval      = 30;
    config.sessionIdentifier    = @"com.fk.downloader";
    config.maximumExecutionTask = 3;
    config.speedRefreshInterval = 1;
    config.rootPath     = [cachePath stringByAppendingPathComponent:@"com.fk.downloader"];
    config.savePath     = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/file"];
    config.resumePath   = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/resume"];
    config.restorePath  = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/downloader.restore"];
    return config;
}


#pragma mark - Setter/Getter
- (void)setSpeedRefreshInterval:(NSTimeInterval)speedRefreshInterval {
    if (speedRefreshInterval > 0) {
        _speedRefreshInterval = speedRefreshInterval;
    } else {
        _speedRefreshInterval = 1;
    }
}

- (void)setTimeoutInterval:(NSInteger)timeoutInterval {
    if (timeoutInterval > 0) {
        _timeoutInterval = timeoutInterval;
    } else {
        _timeoutInterval = 30;
    }
}

- (void)setMaximumExecutionTask:(NSInteger)maximumExecutionTask {
    if (maximumExecutionTask > 3) {
        _maximumExecutionTask = 3;
    } else if (maximumExecutionTask < 0) {
        _maximumExecutionTask = 1;
    } else {
        _maximumExecutionTask = maximumExecutionTask;
    }
}


@end
