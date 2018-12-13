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


- (void)orderEach:(void (^)(id _Nonnull, NSUInteger))block {
    NSArray *orderTasks = [self sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES]]];
    [orderTasks forEach:block];
}

- (void)disorderEach:(void (^)(id _Nonnull, NSUInteger))block {
    [self forEach:block];
}

- (NSArray *)flatten {
    NSMutableArray *array = [NSMutableArray array];
    
    for (id object in self) {
        if ([object isKindOfClass:NSArray.class]) {
            [array addObjectsFromArray:[object flatten]];
        } else {
            [array addObject:object];
        }
    }
    
    return array;
}

- (void)groupProgress:(nullable void (^)(double))progressBlock {
    if (progressBlock == nil) { return; }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            __block double total = 0.f;
            [self forEach:^(FKTask *task, NSUInteger idx) {
                if ([task isKindOfClass:[FKTask class]]) {
                    total += task.progress.fractionCompleted;
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                progressBlock(total / self.count);
            });
        }
    });
}

@end
NS_ASSUME_NONNULL_END
