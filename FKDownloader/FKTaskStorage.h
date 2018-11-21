//
//  FKTaskStorage.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/21.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKTaskStorage : NSObject

+ (BOOL)saveObject:(id)obj toPath:(NSString *)path;
+ (id)loadData:(NSString *)path;

@end
