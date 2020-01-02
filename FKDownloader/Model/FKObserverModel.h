//
//  FKObserverModel.h
//  FKDownloader
//
//  Created by norld on 2020/1/2.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 监控信息对象, 负责接收 KVO 回传的信息, 以 Request 为单位
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FKState) {
    FKStatePrepare  = 0, // 准备
    FKStateIdel     = 1, // 等待
    FKStateAction   = 2, // 执行
    FKStateSuspend  = 3, // 暂停
    FKStateCancel   = 4, // 取消
};

NS_ASSUME_NONNULL_BEGIN

@interface FKObserverModel : NSObject

@property (nonatomic, assign) double progress;
@property (nonatomic, assign) FKState state;

+ (instancetype)model;

@end

NS_ASSUME_NONNULL_END
