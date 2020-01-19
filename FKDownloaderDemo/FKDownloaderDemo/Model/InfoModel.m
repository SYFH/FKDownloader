//
//  InfoModel.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import "InfoModel.h"

@implementation InfoModel

- (instancetype)initWithWithURL:(NSString *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

+ (instancetype)modelWithURL:(NSString *)url {
    return [[InfoModel alloc] initWithWithURL:url];
}

- (NSUInteger)hash {
    return [self.url hash];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.url forKey:@"url"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self) {
        self.url = [coder decodeObjectForKey:@"url"];
    }
    return self;
}

@end
