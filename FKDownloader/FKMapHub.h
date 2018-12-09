//
//  FKMapHub.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/12/6.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FKTask;

NS_ASSUME_NONNULL_BEGIN
@interface FKMapHub : NSObject

#pragma mark - Task
- (void)addTask:(FKTask *)task withTag:(nullable NSString *)tag;
- (void)removeTask:(FKTask *)task;

#pragma mark - Tag
- (void)addTag:(NSString *)tag to:(FKTask *)task;
- (void)removeTag:(NSString *)tag from:(FKTask *)task;

#pragma mark - Operation
- (NSArray<FKTask *> *)allTask;
- (nullable FKTask *)taskWithIdentifier:(NSString *)identifier;
- (NSArray<FKTask *> *)taskForTag:(NSString *)tag;
- (BOOL)containsTask:(FKTask *)task;
- (NSInteger)countOfTasks;
- (void)clear;

@end
NS_ASSUME_NONNULL_END
