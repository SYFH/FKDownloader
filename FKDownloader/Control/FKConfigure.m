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

- (void)take {
    [[FKEngine engine] configtureSession];
}


#pragma mark - Getter/Setter
- (NSURLSessionConfiguration *)templateBackgroundConfiguration {
    if (!_templateBackgroundConfiguration) {
        _templateBackgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.fk.downloader.background.session.config"];
    }
    return _templateBackgroundConfiguration;
}

@end
