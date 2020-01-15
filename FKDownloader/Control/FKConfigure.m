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
    }
    return self;
}

- (void)take {
    [[FKEngine engine] configtureSession];
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

- (NSURLSessionConfiguration *)templateBackgroundConfiguration {
    if (!_templateBackgroundConfiguration) {
        _templateBackgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fk.downloader.background.session.config"];
    }
    return _templateBackgroundConfiguration;
}

@end
