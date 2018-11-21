//
//  FKSystemHelper.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/21.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKSystemHelper.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@implementation FKSystemHelper

// !!!: https://www.theiphonewiki.com/wiki/Models 可根据版本号和子版本号确定设备, NSNotFound 为暂时无法识别
+ (NSInteger)currentDeviceModelVersion:(DeviceModel)model {
    NSInteger version = NSNotFound;
    if ([self currentDeviceSimulator]) {
        return version;
    }
    
    switch (model) {
        case DeviceModelAirPods: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"AirPods".length, 1)] integerValue];
        } break;
            
        case DeviceModelAppleTV: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"AppleTV".length, 1)] integerValue];
        } break;
            
        case DeviceModelAppleWatch: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"Watch".length, 1)] integerValue];
        } break;
            
        case DeviceModelHomePod: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"AudioAccessory".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPad: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPad".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPadMini: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPad".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPhone: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPhone".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPodTouch: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPod".length, 1)] integerValue];
        } break;
    }
    return version;
}

+ (NSInteger)currentDeviceModelSubversion:(DeviceModel)model {
    NSInteger version = NSNotFound;
    if ([self currentDeviceSimulator]) {
        return version;
    }
    
    version = [[[self currentDeviceName] substringWithRange:NSMakeRange([self currentDeviceName].length - 1, 1)] integerValue];
    return version;
}

+ (BOOL)currentDeviceSimulator {
    if ([[self currentDeviceName] isEqualToString:@"i386"] ||
        [[self currentDeviceName] isEqualToString:@"x86_64"]) {
        
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)currentDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)currentSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

@end
