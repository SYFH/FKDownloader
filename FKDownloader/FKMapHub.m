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

@property (nonatomic, copy  ) NSMutableSet<FKTask *> *tasks;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, FKTask *> *taskMap;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, NSMutableSet<FKTask *> *> *tagMap;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, NSProgress *> *tagProgress;   // 每个 tag 的 progress

@end

@implementation FKMapHub

#pragma mark - Task
- (void)addTask:(FKTask *)task withTag:(nullable NSString *)tag {
    @synchronized (self.tasks) {
        [self.tasks addObject:task];
    }
    @synchronized (self.taskMap) {
        if ([self.taskMap objectForKey:task.identifier] == nil) {
            [self.taskMap setObject:task forKey:task.identifier];
        }
    }
    if (tag.length > 0) {
        @synchronized (self.tagMap) {
            if ([self.tagMap objectForKey:tag] == nil) {
                [self.tagMap setObject:[NSMutableSet set] forKey:tag];
            }
            [[self.tagMap objectForKey:tag] addObject:task];
        }
        
        @synchronized (self.tagProgress) {
            if ([self.tagProgress objectForKey:tag] == nil) {
                [self.tagProgress setObject:[[NSProgress alloc] init] forKey:tag];
            }
        }
    }
}

- (void)addTask:(FKTask *)task withTags:(NSArray<NSString *> *)tags {
    @synchronized (self.tasks) {
        [self.tasks addObject:task];
    }
    @synchronized (self.taskMap) {
        if ([self.taskMap objectForKey:task.identifier] == nil) {
            [self.taskMap setObject:task forKey:task.identifier];
        }
    }
    if (tags.count > 0) {
        for (NSString *tag in tags) {
            @synchronized (self.tagMap) {
                if ([self.tagMap objectForKey:tag] == nil) {
                    [self.tagMap setObject:[NSMutableSet set] forKey:tag];
                }
                [[self.tagMap objectForKey:tag] addObject:task];
            }
            
            @synchronized (self.tagProgress) {
                if ([self.tagProgress objectForKey:tag] == nil) {
                    [self.tagProgress setObject:[[NSProgress alloc] init] forKey:tag];
                }
            }
        }
    }
}

- (void)removeTask:(FKTask *)task {
    @synchronized (self.tasks) {
        [self.tasks removeObject:task];
    }
    @synchronized (self.taskMap) {
        [self.taskMap removeObjectForKey:task.identifier];
    }
    for (NSString *tag in task.tags) {
        @synchronized (self.tagMap) {
            [[self.tagMap objectForKey:tag] removeObject:task];
        }
    }
}


#pragma mark - Tag
- (void)addTag:(NSString *)tag to:(FKTask *)task {
    @synchronized (self.tasks) {
        if ([self.tasks containsObject:task] == NO) {
            return;
        }
    }
    @synchronized (self.tagMap) {
        if ([self.tagMap objectForKey:tag] == nil) {
            [self.tagMap setObject:[NSMutableSet set] forKey:tag];
        }
        [[self.tagMap objectForKey:tag] addObject:task];
    }
}

- (void)removeTag:(NSString *)tag from:(FKTask *)task {
    @synchronized ([self.tagMap objectForKey:tag]) {
        [[self.tagMap objectForKey:tag] removeObject:task];
    }
}


#pragma mark - Progress
- (NSProgress *)progressWithTag:(NSString *)tag {
    @synchronized (self.tagProgress) {
        return [self.tagProgress objectForKey:tag];
    }
}


#pragma mark - Operation
- (NSArray<FKTask *> *)allTask {
    @synchronized (self.tasks) {
        return [self.tasks allObjects];
    }
}

- (FKTask *)taskWithIdentifier:(NSString *)identifier {
    @synchronized (self.taskMap) {
        return [self.taskMap objectForKey:identifier];
    }
}

- (NSArray<FKTask *> *)taskForTag:(NSString *)tag {
    @synchronized (self.tagMap) {
        if ([self.tagMap objectForKey:tag] == nil) {
            return @[];
        }
    }
    @synchronized (self.tagMap) {
        return [[self.tagMap objectForKey:tag] allObjects];
    }
}

- (BOOL)containsTask:(FKTask *)task {
    @synchronized (self.tasks) {
        return [self.tasks containsObject:task];
    }
}

- (NSInteger)countOfTasks {
    @synchronized (self.tasks) {
        return [self.tasks count];
    }
}


#pragma mark - Getter/Setter
- (NSMutableSet<FKTask *> *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableSet set];
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

- (NSMutableDictionary<NSString *,NSProgress *> *)tagProgress {
    if (!_tagProgress) {
        _tagProgress = [NSMutableDictionary dictionary];
    }
    return _tagProgress;
}

@end
