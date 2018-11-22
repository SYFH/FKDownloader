//
//  FKSystemHelper.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/21.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKDefine.h"

@interface FKSystemHelper : NSObject

+ (NSInteger)currentDeviceModelVersion:(DeviceModel)model;
+ (NSInteger)currentDeviceModelSubversion:(DeviceModel)model;
+ (BOOL)currentDeviceSimulator;
+ (NSString *)currentDeviceName;
+ (NSString *)currentSystemVersion;

@end
