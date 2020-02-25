//
//  FKResumeData.m
//  FKDownloader
//
//  Created by norld on 2020/2/24.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKResumeData.h"

typedef NSString * FKResumeDataKey;
FKResumeDataKey const FKResumeDataDownloaderURL         = @"NSURLSessionDownloadURL";
FKResumeDataKey const FKResumeDataByteRange             = @"NSURLSessionResumeByteRange";
FKResumeDataKey const FKResumeDataBytesReceived         = @"NSURLSessionResumeBytesReceived";
FKResumeDataKey const FKResumeDataCurrentRequest        = @"NSURLSessionResumeCurrentRequest";
FKResumeDataKey const FKResumeDataInfoLocalPath         = @"NSURLSessionResumeInfoLocalPath";
FKResumeDataKey const FKResumeDataInfoTempFileName      = @"NSURLSessionResumeInfoTempFileName";
FKResumeDataKey const FKResumeDataInfoVersion           = @"NSURLSessionResumeInfoVersion";
FKResumeDataKey const FKResumeDataOriginalRequest       = @"NSURLSessionResumeOriginalRequest";
FKResumeDataKey const FKResumeDataServerDownloadDate    = @"NSURLSessionResumeServerDownloadDate";

@implementation FKResumeData

+ (NSDictionary *)readResumeData:(NSData *)resumeData {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 12) {
        NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:resumeData
                                                                      options:0
                                                                       format:NULL
                                                                        error:nil];
        return dic;
    } else {
        return [self getResumeDictionary:resumeData];
    }
}

+ (NSData *)packetResumeData:(NSDictionary *)packet {
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion < 12) {
        return [NSPropertyListSerialization dataWithPropertyList:packet
                                                          format:NSPropertyListXMLFormat_v1_0
                                                         options:0
                                                           error:nil];
    } else {
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:packet forKey:@"NSKeyedArchiveRootObjectKey"];
        [archiver finishEncoding];
        return [data copy];
    }
}

+ (NSDictionary *)getResumeDictionary:(NSData *)data {
    NSMutableDictionary *iresumeDictionary;
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 10) {
        NSMutableDictionary *root;
        NSKeyedUnarchiver *keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSError *error = nil;
        if (@available(iOS 9.0, *)) {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:&error];
            if (!root) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:&error];
            }
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = root;
    }
    
    if (!iresumeDictionary) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:nil];
    }
    return iresumeDictionary;
}

+ (NSData *)correctRequestData:(NSData *)data {
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    if ([archive objectForKey:@"$objects"] != nil) {
        id objectss = archive[@"$objects"];
        if ([objectss count] > 1) {
            while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",(long)k]] != nil) {
                k += 1;
            }
            NSInteger i = 0;
            while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]] != nil) {
                NSMutableArray *arr = archive[@"$objects"];
                NSMutableDictionary *dic = arr[1];
                id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]];
                if (obj) {
                    [dic setValue:obj forKey:[NSString stringWithFormat:@"$%d", (int)(i + k)]];
                    [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",(long)i]];
                    [arr replaceObjectAtIndex:1 withObject:dic];
                    archive[@"$objects"] = arr;
                }
                i++;
            }
            if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
                NSMutableArray *arr = archive[@"$objects"];
                NSMutableDictionary *dic = arr[1];
                id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
                if (obj) {
                    [dic setValue:obj forKey:[NSString stringWithFormat:@"$%d", (int)(i + k)]];
                    [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
                    [arr replaceObjectAtIndex:1 withObject:dic];
                    archive[@"$objects"] = arr;
                }
            }
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive objectForKey:@"$top"] != nil) {
        if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
            [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey:NSKeyedArchiveRootObjectKey];
            [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
        }
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                               options:0
                                                                 error:nil];
    return result;
}

+ (NSData *)correctResumeData:(NSData *)data {
    // 参考: https://stackoverflow.com/questions/39346231/resume-nsurlsession-on-ios10/39347461#39347461
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion == 10
        && ([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion == 0 ||
            [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion == 1)) {
        
        if (data == nil) { return  nil; }
        NSMutableDictionary *resumeDictionary = [[self getResumeDictionary:data] mutableCopy];
        if (resumeDictionary == nil) { return nil; }
        
        if ([resumeDictionary.allKeys containsObject:FKResumeDataByteRange]) {
            [resumeDictionary removeObjectForKey:FKResumeDataByteRange];
        }
        
        resumeDictionary[FKResumeDataCurrentRequest] = [self correctRequestData:resumeDictionary[FKResumeDataCurrentRequest]];
        resumeDictionary[FKResumeDataOriginalRequest] = [self correctRequestData:resumeDictionary[FKResumeDataOriginalRequest]];
        
        NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary
                                                                    format:NSPropertyListXMLFormat_v1_0
                                                                   options:0
                                                                     error:nil];
        return result;
    } else {
        NSMutableDictionary *resumeDictionary = [[self readResumeData:data] mutableCopy];
        if (resumeDictionary == nil) { return data; }
        
        if ([resumeDictionary.allKeys containsObject:FKResumeDataByteRange]) {
            [resumeDictionary removeObjectForKey:FKResumeDataByteRange];
        }
        
        if ([[resumeDictionary valueForKey:FKResumeDataInfoVersion] integerValue] == 1) {
            // 在模拟器环境下, FKResumeDataInfoLocalPath 字段会因为沙盒目录不断更新而失效, 需要更新路径
            // 最好在真机中测试
            NSURL *fileURL = [NSURL fileURLWithPath:[resumeDictionary valueForKey:FKResumeDataInfoLocalPath]];
            NSString *updateTempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
            [resumeDictionary setObject:updateTempFilePath forKey:FKResumeDataInfoLocalPath];
        }
        
        NSData *result = [self packetResumeData:[NSDictionary dictionaryWithDictionary:resumeDictionary]];
        return result;
    }
}

@end
