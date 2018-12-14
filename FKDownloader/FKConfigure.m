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
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    FKConfigure *config = [[FKConfigure alloc] init];
    config.autoStart          = NO;
    config.autoClearTask      = NO;
    config.backgroudExecute   = YES;
    config.fileChecksum       = NO;
    config.allowCellular      = NO;
    config.autoCoding         = YES;
    config.deleteFinishFile   = NO;
    config.calculateSpeedWithEstimated = YES;
    config.timeoutInterval      = 30;
    config.sessionIdentifier    = @"com.fk.downloader";
    config.maximumExecutionTask = 3;
    config.speedRefreshInterval = 1;
    config.savePath     = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/file"];
    config.resumeSavePath   = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/resume"];
    config.restoreFilePath  = [cachePath stringByAppendingPathComponent:@"com.fk.downloader/downloader.restore"];
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
