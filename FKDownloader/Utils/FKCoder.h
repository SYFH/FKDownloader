//
//  FKCoder.h
//  FKDownloader
//
//  Created by norld on 2020/1/16.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKCoder : NSObject

+ (NSString *)encode:(NSString *)url;
+ (NSString *)decode:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
