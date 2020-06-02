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
@property (nonatomic, strong) NSURLSessionConfiguration *templateForegroundConfiguration;
@property (nonatomic, assign) float distributeTimeinterval;

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
        self.distributeSpeed = 5;
        self.distributeTimeinterval = 0.2;
        
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *workName = @"com.fk.downloader.work";
        NSString *workPath = [cachePath stringByAppendingPathComponent:workName];
        self.workPath = workPath;
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

- (void)setDistributeSpeed:(unsigned int)distributeRate {
    if (distributeRate > 10) {
        _distributeSpeed = 10;
    } else if (distributeRate < 1) {
        _distributeSpeed = 1;
    } else {
        _distributeSpeed = distributeRate;
    }
}

- (NSURLSessionConfiguration *)templateBackgroundConfiguration {
    if (!_templateBackgroundConfiguration) {
        _templateBackgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self backgroundSessionIdentifier]];
        _templateBackgroundConfiguration.allowsCellularAccess = YES;
    }
    return _templateBackgroundConfiguration;
}

- (NSURLSessionConfiguration *)templateForegroundConfiguration {
    if (!_templateForegroundConfiguration) {
        _templateForegroundConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _templateForegroundConfiguration.allowsCellularAccess = YES;
    }
    return _templateForegroundConfiguration;
}

- (NSString *)backgroundSessionIdentifier {
    return @"com.fk.downloader.background.session";
}

@end
