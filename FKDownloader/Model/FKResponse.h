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

@property (nonatomic, strong) NSString *originalURL; // 原始请求链接
@property (nonatomic, strong) NSURLResponse *response; // 请求响应
@property (nonatomic, strong) NSString *filePath; // 预计下载文件路径
@property (nonatomic, strong, nullable) NSError *error; // 请求错误

@end

NS_ASSUME_NONNULL_END
