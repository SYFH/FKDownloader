//
//  FKResponse.h
//  FKDownloader
//
//  Created by norld on 2020/1/20.
//  Copyright © 2020 norld. All rights reserved.
//

/**
 响应模型, 包含请求响应信息, 文件路径和错误信息, 用于响应中间件
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FKResponse : NSObject

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
