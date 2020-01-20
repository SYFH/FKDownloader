//
//  FKResponse.h
//  FKDownloader
//
//  Created by norld on 2020/1/20.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKResponse : NSObject

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
