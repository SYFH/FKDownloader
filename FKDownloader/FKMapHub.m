//
//  FKMapHub.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/12/6.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKMapHub.h"
#import "FKTask.h"
#import "FKDefine.h"

@interface FKMapHub ()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, copy  ) NSMutableArray<FKTask *> *tasks;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, FKTask *> *taskMap;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, NSMutableSet<FKTask *> *> *tagMap;

@end

@implementation FKMapHub

#pragma mark - Task
- (void)addTask:(FKTask *)task withTag:(nullable NSString *)tag {
    [self.lock lock];
    if ([self.tasks containsObject:task] == NO) {
        [self.tasks addObject:task];
        self.taskMap[task.identifier] = task;
    }
    if (tag.length > 0) {
        if (self.tagMap[tag] == nil) {
            self.tagMap[tag] = [NSMutableSet set];
        }
        [self.tagMap[tag] addObject:task];
    }
    [self.lock unlock];
}

- (void)removeTask:(FKTask *)task {
    [self.lock lock];
    if ([self.tasks containsObject:task]) {
        [self.tasks removeObject:task];
        [self.taskMap removeObjectForKey:task.identifier];
    }
    for (NSString *tag in task.tags) {
        if ([self.tagMap.allKeys containsObject:tag]) {
            [self.tagMap[tag] removeObject:task];
        }
    }
    [self.lock unlock];
}


#pragma mark - Tag
- (void)addTag:(NSString *)tag to:(FKTask *)task {
    [self.lock lock];
    if ([self.tasks containsObject:task] == NO) { return; }
    if (self.tagMap[tag] == nil) {
        self.tagMap[tag] = [NSMutableSet set];
    }
    [self.tagMap[tag] addObject:task];
    [self.lock unlock];
}

- (void)removeTag:(NSString *)tag from:(FKTask *)task {
    [self.lock lock];
    [self.tagMap[tag] removeObject:task];
    [self.lock unlock];
}


#pragma mark - Operation
- (FKTask *)taskWithIdentifier:(NSString *)identifier {
    [self.lock lock];
    @onExit {
        [self.lock unlock];
    };
    return self.taskMap[identifier];
}

- (NSArray<FKTask *> *)taskForTag:(NSString *)tag {
    [self.lock lock];
    @onExit {
        [self.lock unlock];
    };
    if (self.tagMap[tag] == nil) { return @[]; }
    return self.tagMap[tag].allObjects;
}

- (BOOL)containsTask:(FKTask *)task {
    [self.lock lock];
    @onExit {
        [self.lock unlock];
    };
    return [self.tasks containsObject:task];
}

- (NSInteger)countOfTasks {
    [self.lock lock];
    @onExit {
        [self.lock unlock];
    };
    return self.tasks.count;
}

- (void)clear {
    [self.lock lock];
    @onExit {
        [self.lock unlock];
    };
    [self.tasks removeAllObjects];
    [self.taskMap removeAllObjects];
    [self.tagMap removeAllObjects];
}


#pragma mark - Getter/Setter
- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

- (NSMutableArray<FKTask *> *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

- (NSMutableDictionary<NSString *,FKTask *> *)taskMap {
    if (!_taskMap) {
        _taskMap = [NSMutableDictionary dictionary];
    }
    return _taskMap;
}

- (NSMutableDictionary<NSString *,NSMutableSet<FKTask *> *> *)tagMap {
    if (!_tagMap) {
        _tagMap = [NSMutableDictionary dictionary];
    }
    return _tagMap;
}

@end
