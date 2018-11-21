//
//  FKTaskStorage.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/21.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKTaskStorage.h"

@implementation FKTaskStorage

+ (BOOL)saveObject:(id)obj toPath:(NSString *)path {
    return [NSKeyedArchiver archiveRootObject:obj toFile:path];
}

+ (id)loadData:(NSString *)path {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

@end
