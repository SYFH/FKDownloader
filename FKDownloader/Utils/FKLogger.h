//
//  FKLogger.h
//  FKDownloader
//
//  Created by norld on 2020/1/8.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKLogger : NSObject

+ (void)info:(NSString *)info, ... NS_FORMAT_FUNCTION(1,2);

@end

NS_ASSUME_NONNULL_END
