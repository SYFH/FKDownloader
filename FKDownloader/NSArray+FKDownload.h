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

@end
NS_ASSUME_NONNULL_END
