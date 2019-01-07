//
//  FKResumeHelper.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKResumeHelper.h"
#import "FKSystemHelper.h"
#import "FKDefine.h"
#import "NSString+FKDownload.h"

@implementation FKResumeHelper
+ (NSDictionary *)pockResumeData:(NSData *)resumeData {
#ifdef DEBUG
    if ([FKSystemHelper currentSystemVersion].floatValue < 12) {
        NSMutableDictionary *dic = [NSPropertyListSerialization propertyListWithData:resumeData
                                                                             options:0
                                                                              format:NULL
                                                                               error:nil];
        dic[FKResumeDataCurrentRequest] = [NSKeyedUnarchiver unarchiveObjectWithData:[self correctRequestData:dic[FKResumeDataCurrentRequest]]];
        dic[FKResumeDataOriginalRequest] = [NSKeyedUnarchiver unarchiveObjectWithData:[self correctRequestData:dic[FKResumeDataOriginalRequest]]];
        return [dic copy];
    } else {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[self getResumeDictionary:resumeData]];
        dic[FKResumeDataCurrentRequest] = [NSKeyedUnarchiver unarchiveObjectWithData:[self correctRequestData:dic[FKResumeDataCurrentRequest]]];
        dic[FKResumeDataOriginalRequest] = [NSKeyedUnarchiver unarchiveObjectWithData:[self correctRequestData:dic[FKResumeDataOriginalRequest]]];
        return [dic copy];
    }
#endif
    return [NSDictionary dictionary];
}

+ (NSDictionary *)readResumeData:(NSData *)resumeData {
    if ([FKSystemHelper currentSystemVersion].floatValue < 12) {
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
    if ([FKSystemHelper currentSystemVersion].floatValue < 12) {
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

+ (NSData *)updateResumeData:(NSData *)resumeData url:(NSString *)url {
    /*
    NSMutableDictionary *resumeDictionary = [[self readResumeData:resumeData] mutableCopy];
    if ([resumeDictionary.allKeys containsObject:FKResumeDataByteRange]) {
        [resumeDictionary removeObjectForKey:FKResumeDataByteRange];
    }
    
    NSURLRequest *oldCurrentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:[self correctRequestData:resumeDictionary[FKResumeDataCurrentRequest]]];
    NSMutableURLRequest *currentRequest = [oldCurrentRequest mutableCopy];
    currentRequest.URL = [NSURL URLWithString:[url encodeEscapedString]];
    
    if ([resumeDictionary.allKeys containsObject:FKResumeDataOriginalRequest]) {
        NSURLRequest *oldOriginalReuqest = [NSKeyedUnarchiver unarchiveObjectWithData:[self correctRequestData:resumeDictionary[FKResumeDataOriginalRequest]]];
        NSMutableURLRequest *originalReuqest = [oldOriginalReuqest mutableCopy];
        originalReuqest.URL = [NSURL URLWithString:[url encodeEscapedString]];
        resumeDictionary[FKResumeDataOriginalRequest] = [NSKeyedArchiver archivedDataWithRootObject:[originalReuqest copy]];
    }
    
    resumeDictionary[FKResumeDataCurrentRequest] = [NSKeyedArchiver archivedDataWithRootObject:[currentRequest copy]];
    resumeDictionary[FKResumeDataDownloaderURL] = [url encodeEscapedString];
    
    return [self packetResumeData:resumeDictionary];
     */
    return nil;
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

+ (NSDictionary *)getResumeDictionary:(NSData *)data {
    NSDictionary *iresumeDictionary = nil;
    id root = nil;
    id keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    @try {
        if (@available(iOS 9.0, *)) {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
        }
        if (root == nil) {
            if (@available(iOS 9.0, *)) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        }
    } @catch(NSException *exception) { }
    [keyedUnarchiver finishDecoding];
    iresumeDictionary = [NSDictionary dictionaryWithDictionary:root];
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data
                                                                      options:NSPropertyListMutableContainersAndLeaves
                                                                       format:nil
                                                                        error:nil];
    }
    return iresumeDictionary;
}

+ (NSData *)correctResumeData:(NSData *)data {
    // !!!:https://stackoverflow.com/questions/39346231/resume-nsurlsession-on-ios10/39347461#39347461
    if ([[FKSystemHelper currentSystemVersion] hasPrefix:@"10.0"] ||
        [[FKSystemHelper currentSystemVersion] hasPrefix:@"10.1"]) {
        
        if (data == nil) { return  nil; }
        NSMutableDictionary *resumeDictionary = [[self getResumeDictionary:data] mutableCopy];
        if (resumeDictionary == nil) {
            return nil;
        }
        if ([resumeDictionary.allKeys containsObject:FKResumeDataByteRange]) {
            [resumeDictionary removeObjectForKey:FKResumeDataByteRange];
        }
        
        if ([resumeDictionary objectForKey:FKResumeDataCurrentRequest] == nil) {
            resumeDictionary[FKResumeDataCurrentRequest] = [NSKeyedUnarchiver unarchiveObjectWithData:resumeDictionary[FKResumeDataCurrentRequest]];
        }
        if ([resumeDictionary objectForKey:FKResumeDataOriginalRequest] == nil) {
            resumeDictionary[FKResumeDataOriginalRequest] = [NSKeyedUnarchiver unarchiveObjectWithData:resumeDictionary[FKResumeDataOriginalRequest]];
        }
        
        NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary
                                                                    format:NSPropertyListXMLFormat_v1_0
                                                                   options:0
                                                                     error:nil];
        return result;
    } else {
        NSMutableDictionary *resumeDictionary = [[self readResumeData:data] mutableCopy];
        if (resumeDictionary == nil) {
            return data;
        }
        if ([resumeDictionary.allKeys containsObject:FKResumeDataByteRange]) {
            [resumeDictionary removeObjectForKey:FKResumeDataByteRange];
        }
        
        if ([[resumeDictionary valueForKey:FKResumeDataInfoVersion] integerValue] == 1) {
            // !!!: FKResumeDataInfoLocalPath 字段会因为沙盒目录不断更新而失效, 需要更新路径
            NSURL *fileURL = [NSURL fileURLWithPath:[resumeDictionary valueForKey:FKResumeDataInfoLocalPath]];
            NSString *updateTempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileURL.lastPathComponent];
            [resumeDictionary setObject:updateTempFilePath forKey:FKResumeDataInfoLocalPath];
        }
        
        NSData *result = [self packetResumeData:[NSDictionary dictionaryWithDictionary:resumeDictionary]];
        return result;
    }
}

+ (BOOL)checkUsable:(NSData *)resumeData {
    if (resumeData == nil) { return NO; }
    
    NSDictionary *resumeDictionary = [self readResumeData:resumeData];
    if ([resumeDictionary objectForKey:@"$objects"] != nil) {
        if ([resumeDictionary[@"$objects"] count] > 1) {
            return YES;
        } else {
            return NO;
        }
    } else if ([resumeDictionary objectForKey:FKResumeDataDownloaderURL] != nil) {
        return YES;
    } else {
        return NO;
    }
}

@end
