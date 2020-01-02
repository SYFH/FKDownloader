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

@interface FKCacheTaskModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *taskID;
@property (nonatomic, strong) NSArray<NSString *> *urls;

@end

@interface FKCacheRequestModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger dataLength;
@property (nonatomic, strong) NSData *resumeData;

@end

NS_ASSUME_NONNULL_END
