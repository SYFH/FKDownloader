//
//  FKSystemHelper.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/21.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKDefine.h"

NS_ASSUME_NONNULL_BEGIN
@interface FKSystemHelper : NSObject

/**
 可从 https://www.theiphonewiki.com/wiki/Models 查看对应的设备标识符, 其中 iPhone 对应
 类似 iPhone6,2 这种格式, FKSystemHelper 会将 6 识别为主版本, 2 识别为子版本
 */

/**
 获取当前设备的主版本

 @param model 设备类型
 @return 主版本
 */
+ (NSInteger)currentDeviceModelVersion:(DeviceModel)model;

/**
 获取当前设备的子版本

 @param model 设备类型
 @return 子版本
 */
+ (NSInteger)currentDeviceModelSubversion:(DeviceModel)model;

/**
 当前设备是否是模拟器

 @return 是否是模拟器
 */
+ (BOOL)currentDeviceSimulator;

/**
 获取当前设备标识符

 @return 标识符
 */
+ (NSString *)currentDeviceName;

/**
 获取当前系统版本

 @return 版本
 */
+ (NSString *)currentSystemVersion;

@end
NS_ASSUME_NONNULL_END
