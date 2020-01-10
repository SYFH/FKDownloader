//
//  FKMessager.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKMessager.h"

#import "NSString+FKCategory.h"

#import "FKObserver.h"

@interface FKMessager ()

@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) InfoBlock info;

@end

@implementation FKMessager

- (instancetype)initWithURL:(NSString *)url info:(InfoBlock)info {
    self = [super init];
    if (self) {
        self.requestID = url.SHA256;
        self.info = info;
        [[FKObserver observer] addBlock:info requestID:self.requestID];
    }
    return self;
}

+ (instancetype)messagerWithURL:(NSString *)url info:(InfoBlock)info {
    return [[FKMessager alloc] initWithURL:url info:info];
}

@end
