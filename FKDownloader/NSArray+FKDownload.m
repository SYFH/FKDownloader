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
            progress.totalUnitCount += 100;
            progress.completedUnitCount += (int64_t)(task.progress.fractionCompleted * 100);
        }
    }];
    return progress;
}

@end
NS_ASSUME_NONNULL_END
