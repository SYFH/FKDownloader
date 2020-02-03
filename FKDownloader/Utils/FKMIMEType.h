//
//  FKMIMEType.h
//  FKDownloader
//
//  Created by norld on 2020/2/3.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKMIMEType : NSObject

+ (NSString *)extensionWithMIMEType:(NSString *)MIMEType;

@end

NS_ASSUME_NONNULL_END
