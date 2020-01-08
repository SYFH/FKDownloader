//
//  FKCacheModel.m
//  FKDownloader
//
//  Created by norld on 2020/1/2.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKCacheModel.h"

@implementation FKCacheRequestModel

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.requestID forKey:@"requestID"];
    [coder encodeObject:self.requestSingleID forKey:@"requestSingleID"];
    [coder encodeObject:[NSNumber numberWithUnsignedLongLong:self.idx] forKey:@"idx"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.request forKey:@"request"];
    [coder encodeInteger:self.state forKey:@"state"];
    [coder encodeInteger:self.dataLength forKey:@"dataLength"];
    
    if (self.resumeData) {
        [coder encodeObject:self.resumeData forKey:@"resumeData"];
    }
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        self.requestID = [coder decodeObjectForKey:@"requestID"];
        self.requestSingleID = [coder decodeObjectForKey:@"requestSingleID"];
        self.idx = [[coder decodeObjectForKey:@"idx"] unsignedLongLongValue];
        self.url = [coder decodeObjectForKey:@"url"];
        self.request = [coder decodeObjectForKey:@"request"];
        self.state = [coder decodeIntegerForKey:@"state"];
        self.dataLength = [coder decodeIntegerForKey:@"dataLength"];
        self.resumeData = [coder decodeObjectForKey:@"resumeData"];
    }
    return self;
}

@end
