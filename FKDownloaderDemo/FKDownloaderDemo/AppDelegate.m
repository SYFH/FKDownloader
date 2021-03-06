//
//  AppDelegate.m
//  FKDownloaderDemo
//
//  Created by norld on 2019/12/28.
//  Copyright © 2019 norld. All rights reserved.
//

#import "AppDelegate.h"

#import <FKDownloader/FKDownloader.h>

#import "CustomRequestMiddleware.h"
#import "CustomResponseMiddleware.h"
#import "CustomDownloadMiddleware.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[FKMiddleware shared] registeRequestMiddleware:[CustomRequestMiddleware new]];
    [[FKMiddleware shared] registeDownloadMiddleware:[CustomDownloadMiddleware new]];
    [[FKMiddleware shared] registeResponseMiddleware:[CustomResponseMiddleware new]];
    
    [FKConfigure configure].distributeSpeed = 1;
    [FKConfigure configure].workPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"FKDownloader"];
    [[FKConfigure configure] takeSession];
    [[FKConfigure configure] activateQueue];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    
    if ([identifier isEqualToString:[FKConfigure configure].backgroundSessionIdentifier]) {
        [FKConfigure configure].completionHandler = completionHandler;
    }
}


@end
