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

- (void)orderEach:(void (^)(ObjectType obj, NSUInteger idx))block;
- (void)disorderEach:(void (^)(ObjectType obj, NSUInteger idx))block;
- (NSArray *)flatten;

/**
 计算一组 FKTask 的进度
 注意: 频繁段时间间隔调用可能会提高 CPU 占用

 @param progressBlock 进度Block
 */
- (void)groupProgress:(nullable void(^)(double progress))progressBlock;

@end
NS_ASSUME_NONNULL_END
