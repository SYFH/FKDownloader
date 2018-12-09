//
//  NSArray+FKDownload.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/7.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSArray<ObjectType> (FKDownload)

- (NSArray *)map:(id (^)(ObjectType obj, NSUInteger idx))block;
- (void)forEach:(void (^)(ObjectType obj, NSUInteger idx))block;

/**
 计算一组 FKTask 的进度
 注意: 频繁段时间间隔调用可能提高 CPU 占用

 @param progressBlock 进度Block
 */
- (void)groupProgress:(nullable void(^)(NSProgress *progress))progressBlock;

@end
NS_ASSUME_NONNULL_END
