//
//  FKTaskStorage.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/21.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface FKTaskStorage : NSObject

/**
 保存任务

 @param obj 任务数组
 @param path 保存地址
 @return 是否成功
 */
+ (BOOL)saveObject:(id)obj toPath:(NSString *)path;

/**
 加载任务

 @param path 保存地址
 @return 任务数组
 */
+ (id)loadData:(NSString *)path;

@end
NS_ASSUME_NONNULL_END
