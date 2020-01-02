//
//  FKObserver.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责统一管理任务监听数据, 并进行数据分发
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKObserver : NSObject

+ (instancetype)observer;

- (void)addObserverWithRequest:(NSMutableURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
