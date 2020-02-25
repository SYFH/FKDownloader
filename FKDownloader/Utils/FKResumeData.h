//
//  FKResumeData.h
//  FKDownloader
//
//  Created by norld on 2020/2/24.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKResumeData : NSObject

+ (NSData *)correctResumeData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
