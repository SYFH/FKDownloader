//
//  FKSingleNumber.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKSingleNumber.h"
#import <stdatomic.h>

@interface FKSingleNumber ()

@property (nonatomic, assign) atomic_ullong atomicNumber;

@end

@implementation FKSingleNumber

+ (instancetype)shared {
    static FKSingleNumber *instance = nil;
    static dispatch_once_t FKSingleNumberOnceToken;
    dispatch_once(&FKSingleNumberOnceToken, ^{
        instance = [[FKSingleNumber alloc] init];
    });
    return instance;
}

- (void)initialNumber {
    self.atomicNumber = ATOMIC_VAR_INIT(0ull);
}

- (unsigned long long)number {
    @synchronized (self) {
        unsigned long long num = self.atomicNumber;
        self.atomicNumber += 1;
        return num;
    }
}

@end
