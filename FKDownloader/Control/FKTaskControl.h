//
//  FKTaskControl.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责控制任务状态, 对外接口
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKTaskControl : NSObject

+ (void)startWithTask:(NSString *)taskID;
+ (void)cancelWithTask:(NSString *)taskID;
+ (void)suspendWithTask:(NSString *)taskID;
+ (void)resumeWithTask:(NSString *)taskID;

@end

NS_ASSUME_NONNULL_END
