//
//  FKMessager.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKMessager.h"

@interface FKMessager ()

@property (nonatomic, strong) NSString *taskID;

@end

@implementation FKMessager

- (instancetype)initWithTaskID:(NSString *)taskID {
    self = [super init];
    if (self) {
        self.taskID = taskID;
    }
    return self;
}

+ (instancetype)messagerWithTaskID:(NSString *)taskID {
    return [[self alloc] initWithTaskID:taskID];
}

@end
