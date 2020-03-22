//
//  FKConfigure.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKConfigure.h"

#import "FKEngine.h"

@interface FKConfigure ()

@property (nonatomic, strong) NSURLSessionConfiguration *templateBackgroundConfiguration;

@end

@implementation FKConfigure

+ (instancetype)configure {
    static FKConfigure *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FKConfigure alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxAction = 3;
        self.distributeRate = 5;
    }
    return self;
}

- (void)takeSession {
    [[FKEngine engine] configureSession];
}

- (void)activateQueue {
    [[FKEngine engine] configureExecTimer];
    [[FKEngine engine] configureDistributeInfoTimer];
}


#pragma mark - Getter/Setter
- (void)setMaxAction:(unsigned int)maxAction {
    if (maxAction > 6) {
        _maxAction = 6;
    } else if (maxAction < 1) {
        _maxAction = 1;
    } else {
        _maxAction = maxAction;
    }
}

- (void)setDistributeRate:(unsigned int)distributeRate {
    if (distributeRate > 10) {
        _distributeRate = 10;
    } else if (distributeRate < 1) {
        _distributeRate = 1;
    } else {
        _distributeRate = distributeRate;
    }
}

- (NSURLSessionConfiguration *)templateBackgroundConfiguration {
    if (!_templateBackgroundConfiguration) {
        _templateBackgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self backgroundSessionIdentifier]];
        _templateBackgroundConfiguration.allowsCellularAccess = YES;
    }
    return _templateBackgroundConfiguration;
}

- (NSString *)backgroundSessionIdentifier {
    return @"com.fk.downloader.background.session";
}

@end
