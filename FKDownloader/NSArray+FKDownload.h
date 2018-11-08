//
//  NSArray+FKDownload.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/7.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (FKDownload)

- (NSArray *)map:(id (^)(ObjectType obj))block;
- (void)forEach:(void (^)(ObjectType obj))block;

@end
