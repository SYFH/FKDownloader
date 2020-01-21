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

NS_ASSUME_NONNULL_BEGIN

@interface FKObserverModel : NSObject

@property (nonatomic, strong) NSString *requestID; // SHA256(Request.URL)
@property (nonatomic, assign) int64_t countOfBytesReceived;
@property (nonatomic, assign) int64_t countOfBytesExpectedToReceive;

@end

NS_ASSUME_NONNULL_END
