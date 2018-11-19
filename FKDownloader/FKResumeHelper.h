//
//  FKResumeHelper.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKResumeHelper : NSObject

+ (NSDictionary *)readResumeData:(NSData *)resumeData;
+ (NSData *)packetResumeData:(NSDictionary *)packet;

+ (NSData *)correctResumeData:(NSData *)data;

@end
