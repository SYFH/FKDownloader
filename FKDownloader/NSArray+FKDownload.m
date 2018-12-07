//
//  NSArray+FKDownload.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/7.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "NSArray+FKDownload.h"
#import "FKTask.h"

NS_ASSUME_NONNULL_BEGIN
@implementation NSArray (FKDownload)

- (NSArray *)map:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [mutableArray addObject:block(obj, idx)];
    }];
    return mutableArray;
}

- (void)forEach:(void (^)(id obj, NSUInteger idx))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

- (NSProgress *)groupProgress {
    NSProgress *progress = [[NSProgress alloc] init];
    [self forEach:^(FKTask *task, NSUInteger idx) {
        if ([task isKindOfClass:[FKTask class]]) {
            // TODO: 兼容没有获取文件总大小的任务, 可使用固定大小进行百分比计算
            progress.totalUnitCount += task.progress.totalUnitCount;
            progress.completedUnitCount += task.progress.completedUnitCount;
        }
    }];
    return progress;
}

@end
NS_ASSUME_NONNULL_END
