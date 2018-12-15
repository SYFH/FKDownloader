//
//  FKResumeHelper.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface FKResumeHelper : NSObject

/**
 查看恢复数据的具体信息, 此方法只用来测试输出
 
 @param resumeData 恢复数据
 @return 解包数据
 */
+ (nullable NSDictionary *)pockResumeData:(NSData *)resumeData;

/**
 解包恢复数据为字典

 @param resumeData 恢复数据
 @return 解包数据
 */
+ (nullable NSDictionary *)readResumeData:(NSData *)resumeData;

/**
 封包恢复数据

 @param packet Dictionary 数据
 @return 恢复数据
 */
+ (nullable NSData *)packetResumeData:(NSDictionary *)packet;

/**
 更新恢复数据中的 URL

 @param resumeData 恢复数据
 @param url 要更新的 URL
 @return 恢复数据
 */
+ (nullable NSData *)updateResumeData:(NSData *)resumeData url:(NSString *)url UNAVAILABLE_ATTRIBUTE;

/**
 根据系统版本修复恢复数据

 @param data 恢复数据
 @return 修复好的恢复数据
 */
+ (nullable NSData *)correctResumeData:(NSData *)data;

/**
 校验恢复数据是否可用
 针对 iOS 12 中信息为空的恢复数据

 @param resumeData 恢复数据
 @return 是否可用
 */
+ (BOOL)checkUsable:(NSData *)resumeData;

@end
NS_ASSUME_NONNULL_END
