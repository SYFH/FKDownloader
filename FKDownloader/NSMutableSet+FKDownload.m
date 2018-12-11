//
//  NSMutableSet+FKDownload.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/12/5.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "NSMutableSet+FKDownload.h"

@implementation NSMutableSet (FKDownload)

- (void)subtractSet:(NSSet *)set {
    NSMutableSet *temp = [NSMutableSet setWithSet:self];
    [temp intersectSet:set];
    [self minusSet:temp];
}

@end
