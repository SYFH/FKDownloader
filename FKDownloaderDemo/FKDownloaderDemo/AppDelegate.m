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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[FKConfigure configure] take];
    [[FKMiddleware shared] registeRequestMiddleware:[CustomRequestMiddleware new]];
    [[FKMiddleware shared] registeResponseMiddleware:[CustomResponseMiddleware new]];
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    
    if ([identifier isEqualToString:[FKConfigure configure].backgroundSessionIdentifier]) {
        [FKConfigure configure].completionHandler = completionHandler;
    }
}


@end
