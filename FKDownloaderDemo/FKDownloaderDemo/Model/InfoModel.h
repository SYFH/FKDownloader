//
//  InfoModel.h
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InfoModel : NSObject<NSCoding>

@property (nonatomic, strong) NSString *url;

+ (instancetype)modelWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
