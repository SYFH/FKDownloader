//
//  FKResumeHelper.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKResumeHelper : NSObject

/**
 解包恢复数据为字典

 @param resumeData 恢复数据
 @return 解包数据
 */
+ (NSDictionary *)readResumeData:(NSData *)resumeData;

/**
 封包恢复数据

 @param packet Dictionary 数据
 @return 恢复数据
 */
+ (NSData *)packetResumeData:(NSDictionary *)packet;

/**
 更新恢复数据中的 URL

 @param resumeData 恢复数据
 @param url 要更新的 URL
 @return 恢复数据
 */
+ (NSData *)updateResumeData:(NSData *)resumeData url:(NSString *)url;

/**
 根据系统版本修复恢复数据

 @param data 恢复数据
 @return 修复好的恢复数据
 */
+ (NSData *)correctResumeData:(NSData *)data;

@end
