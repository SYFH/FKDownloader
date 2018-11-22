//
//  FKResumeHelper.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/19.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKResumeHelper.h"
#import "FKSystemHelper.h"

@implementation FKResumeHelper

+ (NSDictionary *)readResumeData:(NSData *)resumeData {
    if ([FKSystemHelper currentSystemVersion].floatValue < 12) {
        NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:resumeData
                                                                      options:0
                                                                       format:NULL
                                                                        error:nil];
        return dic;
    } else {
        NSData *data = [self correctRequestData:resumeData];
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return dic;
    }
}

+ (NSData *)packetResumeData:(NSDictionary *)packet {
    if ([FKSystemHelper currentSystemVersion].floatValue < 12) {
        return [NSPropertyListSerialization dataWithPropertyList:packet
                                                          format:NSPropertyListXMLFormat_v1_0
                                                         options:0
                                                           error:nil];
    } else {
        return [NSKeyedArchiver archivedDataWithRootObject:packet];
    }
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
    id objectss = archive[@"$objects"];
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
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                               options:0
                                                                 error:nil];
    return result;
}

+ (NSMutableDictionary *)getResumeDictionary:(NSData *)data {
    NSMutableDictionary *iresumeDictionary = nil;
    id root = nil;
    id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
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
    iresumeDictionary = [root mutableCopy];
    
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
    if ([[FKSystemHelper currentSystemVersion] isEqualToString:@"10.0"] ||
        [[FKSystemHelper currentSystemVersion] isEqualToString:@"10.1"]) {
        
        NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
        NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
        if (data == nil) {
            return  nil;
        }
        NSMutableDictionary *resumeDictionary = [self getResumeDictionary:data];
        if (resumeDictionary == nil) {
            return nil;
        }
        resumeDictionary[kResumeCurrentRequest] = [self correctRequestData:resumeDictionary[kResumeCurrentRequest]];
        resumeDictionary[kResumeOriginalRequest] = [self correctRequestData:resumeDictionary[kResumeOriginalRequest]];
        NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary
                                                                    format:NSPropertyListXMLFormat_v1_0
                                                                   options:0
                                                                     error:nil];
        return result;
    } else if ([[FKSystemHelper currentSystemVersion] hasPrefix:@"11."]) {
        NSMutableDictionary *resumeDictionary = [[self readResumeData:data] mutableCopy];
        if (resumeDictionary == nil) {
            return data;
        }
        if ([resumeDictionary.allKeys containsObject:@"NSURLSessionResumeByteRange"]) {
            [resumeDictionary removeObjectForKey:@"NSURLSessionResumeByteRange"];
        }
        NSData *result = [self packetResumeData:[NSDictionary dictionaryWithDictionary:resumeDictionary]];
        return result;
    } else {
        return data;
    }
}

@end
