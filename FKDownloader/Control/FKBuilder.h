//
//  FKBuilder.h
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

/**
 负责创建任务, 设定任务的基本信息, 对外接口
 */

#import <Foundation/Foundation.h>

#import "FKCommonHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKBuilder : NSMutableURLRequest

+ (instancetype)buildWithURL:(NSString *)url;

/// 下载类型, 默认为后台下载. 执行预处理前可改动, 预处理后改动不会生效
@property (nonatomic, assign) FKDownloadType downloadType;

/// 进行预处理
/// 主要流程包括但不限于: 磁盘创建请求信息文件, 加入等待执行队列
- (void)prepare;

@end

NS_ASSUME_NONNULL_END
