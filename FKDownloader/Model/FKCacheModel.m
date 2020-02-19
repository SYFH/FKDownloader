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
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.request forKey:@"request"];
    [coder encodeInteger:self.state forKey:@"state"];
    [coder encodeInt64:self.receivedLength forKey:@"receivedLength"];
    [coder encodeInt64:self.dataLength forKey:@"dataLength"];
    [coder encodeObject:self.extension forKey:@"extension"];
    
    if (self.resumeData) {
        [coder encodeObject:self.resumeData forKey:@"resumeData"];
    }
    
    if (self.error) {
        [coder encodeObject:self.error forKey:@"error"];
    }
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        self.requestID = [coder decodeObjectForKey:@"requestID"];
        self.requestSingleID = [coder decodeObjectForKey:@"requestSingleID"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.request = [coder decodeObjectForKey:@"request"];
        self.state = [coder decodeIntegerForKey:@"state"];
        self.receivedLength = [coder decodeInt64ForKey:@"receivedLength"];
        self.dataLength = [coder decodeInt64ForKey:@"dataLength"];
        self.extension = [coder decodeObjectForKey:@"extension"];
        self.resumeData = [coder decodeObjectForKey:@"resumeData"];
        self.error = [coder decodeObjectForKey:@"error"];
    }
    return self;
}

@end
