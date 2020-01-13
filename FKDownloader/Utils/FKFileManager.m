//
//  FKFileManager.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKFileManager.h"

#import "NSString+FKCategory.h"

#import "FKLogger.h"
#import "FKEngine.h"
#import "FKCache.h"
#import "FKSingleNumber.h"
#import "FKCacheModel.h"

@interface FKFileManager ()

@property (nonatomic, strong) NSString *requestFileExtension;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *workPath;

@end

@implementation FKFileManager

+ (instancetype)manager {
    static FKFileManager *instance = nil;
    static dispatch_once_t FKFileManagerOnceToken;
    dispatch_once(&FKFileManagerOnceToken, ^{
        instance = [[FKFileManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *workName = @"com.fk.downloader.work";
        NSString *workPath = [cachePath stringByAppendingPathComponent:workName];
        [self.fileManager createDirectoryAtPath:workPath withIntermediateDirectories:YES attributes:nil error:nil];
        self.workPath = workPath;
    }
    return self;
}

- (void)saveSingleNumber {
    NSString *path = [self.workPath stringByAppendingPathComponent:@"singleNumner"];
    unsigned long long number = FKSingleNumber.shared.current;
    [self.fileManager createFileAtPath:path contents:[NSData dataWithBytes:&number length:sizeof(unsigned long long)] attributes:nil];
}

- (unsigned long long)loadSingleNumber {
    unsigned long long number = 0;
    NSString *path = [self.workPath stringByAppendingPathComponent:@"singleNumner"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [data getBytes:&number length:sizeof(unsigned long long)];
    return number;
}

- (NSString *)workFinder {
    return self.workPath;
}

- (void)createRequestFinderWithRequestID:(NSString *)request {
    NSString *requestPath = [self.workPath stringByAppendingPathComponent:request];
    
    if ([self.fileManager fileExistsAtPath:requestPath] == NO) {
        [self.fileManager createDirectoryAtPath:requestPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)createRequestFileWithRequest:(FKCacheRequestModel *)request {
    NSString *requestPath = [self requestFielPath:request.requestID extension:self.requestFileExtension];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
    [self.fileManager createFileAtPath:requestPath contents:data attributes:nil];
}

- (void)updateRequestFileWithRequest:(FKCacheRequestModel *)request {
    NSString *requestPath = [self requestFielPath:request.requestID extension:self.requestFileExtension];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
    [data writeToFile:requestPath atomically:YES];
}

- (BOOL)existLocalRequestWithRequest:(FKCacheRequestModel *)request {
    NSString *requestPath = [self requestFielPath:request.requestID extension:self.requestFileExtension];
    return [self.fileManager fileExistsAtPath:requestPath];
}

- (void)loadLocalRequestWithURL:(NSString *)url complete:(void (^)(FKCacheRequestModel * _Nullable request))complete {
    NSString *requestPath = [self requestFielPath:url.SHA256 extension:self.requestFileExtension];
    FKCacheRequestModel *request = [NSKeyedUnarchiver unarchiveObjectWithFile:requestPath];
    if (complete) {
        complete(request);
    }
}

- (FKCacheRequestModel *)loadLocalRequestWithRequestID:(NSString *)requestID {
    NSString *requestPath = [self requestFielPath:requestID extension:self.requestFileExtension];
    FKCacheRequestModel *request = [NSKeyedUnarchiver unarchiveObjectWithFile:requestPath];
    return request;
}

- (void)moveFile:(NSURL *)fileURL toRequestFinder:(NSString *)requestID fileName:(nonnull NSString *)fileName {
    NSString *requestFinder = [self.workPath stringByAppendingPathComponent:requestID];
    NSString *requestFileName = [requestFinder stringByAppendingPathComponent:fileName];
    [self.fileManager moveItemAtURL:fileURL toURL:[NSURL fileURLWithPath:requestFileName] error:nil];
}

- (unsigned long long)fileSizeWithPath:(NSString *)path {
    unsigned long long size = 0;
    NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:path error:nil];
    size = [attributes[NSFileSize] unsignedLongLongValue];
    return size;
}

- (NSString *)requestFinderPath:(NSString *)requestID {
    return [self.workPath stringByAppendingPathComponent:requestID];
}

- (NSString *)requestFielPath:(NSString *)requestID extension:(NSString *)extension {
    NSString *fileName = [NSString stringWithFormat:@"%@%@", requestID, extension];
    return [[self requestFinderPath:requestID] stringByAppendingPathComponent:fileName];
}


#pragma mark - Getter/Setter
- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

- (NSString *)requestFileExtension {
    return @".rqi";
}

@end
