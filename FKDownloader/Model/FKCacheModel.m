//
//  FKCacheModel.m
//  FKDownloader
//
//  Created by norld on 2020/1/2.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKCacheModel.h"

@implementation FKCacheTaskModel

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.taskID forKey:@"taskID"];
    [coder encodeObject:self.urls forKey:@"urls"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        self.taskID = [coder decodeObjectForKey:@"taskID"];
        self.urls   = [coder decodeObjectForKey:@"urls"];
    }
    return self;
}

@end

@implementation FKCacheRequestModel

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.header forKey:@"header"];
    [coder encodeInteger:self.state forKey:@"state"];
    [coder encodeInteger:self.dataLength forKey:@"dataLength"];
    [coder encodeObject:self.resumeData forKey:@"resumeData"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        self.url = [coder decodeObjectForKey:@"url"];
        self.header = [coder decodeObjectForKey:@"header"];
        self.state = [coder decodeIntegerForKey:@"state"];
        self.dataLength = [coder decodeIntegerForKey:@"dataLength"];
        self.resumeData = [coder decodeObjectForKey:@"resumeData"];
    }
    return self;
}

@end
