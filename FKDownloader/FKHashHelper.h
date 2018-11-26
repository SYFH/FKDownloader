//
//  FKChecksum.h
//  FKDownloader
//
//  Created by Norld on 2018/11/18.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface FKHashHelper : NSObject

+ (NSString *)MD5:(NSString *)path;
+ (NSString *)SHA1:(NSString *)path;
+ (NSString *)SHA256:(NSString *)path;
+ (NSString *)SHA512:(NSString *)path;

@end
NS_ASSUME_NONNULL_END
