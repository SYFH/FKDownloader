//
//  FKCacheModel.h
//  FKDownloader
//
//  Created by norld on 2020/1/2.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 内存/磁盘缓存对象, 负责保存 Task/Request 信息
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKCacheRequestModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *requestID; // 请求标识, SHA256(URL)
@property (nonatomic, assign) unsigned long long idx; // 唯一可排序编号
@property (nonatomic, strong) NSString *url; // 原始请求链接
@property (nonatomic, strong) NSMutableURLRequest *request; // 请求
@property (nonatomic, assign) FKState state; // 请求状态
@property (nonatomic, assign) NSInteger dataLength; // 数据长度
@property (nonatomic, strong, nullable) NSData *resumeData; //回复数据

@end

NS_ASSUME_NONNULL_END
