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

NS_ASSUME_NONNULL_BEGIN

@interface FKCacheRequestModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger dataLength;
@property (nonatomic, strong, nullable) NSData *resumeData;

@end

NS_ASSUME_NONNULL_END
