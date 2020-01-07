//
//  FKFileManager.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKFileManager.h"

#import "NSString+FKCategory.h"

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
    __weak typeof(self) weak = self;
    [FKEngine.engine.ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *path = [self.workPath stringByAppendingPathComponent:@"singleNumner"];
        unsigned long long number = FKSingleNumber.shared.curren;
        [self.fileManager createFileAtPath:path contents:[NSData dataWithBytes:&number length:sizeof(unsigned long long)] attributes:nil];
    }];
}

- (unsigned long long)loadSingleNumber {
    __weak typeof(self) weak = self;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block unsigned long long number = 0;
    [FKEngine.engine.ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *path = [self.workPath stringByAppendingPathComponent:@"singleNumner"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        [data getBytes:&number length:sizeof(unsigned long long)];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return number;
}

- (NSString *)workFinder {
    return self.workPath;
}

- (void)createRequestFinderWithRequestID:(NSString *)request {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestPath = [self.workPath stringByAppendingPathComponent:request];
        
        if ([self.fileManager fileExistsAtPath:requestPath] == NO) {
            [self.fileManager createDirectoryAtPath:requestPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }];
}

- (void)createRequestFileWithRequest:(FKCacheRequestModel *)request {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestPath = [self.workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", request.url.SHA256, request.url.SHA256, self.requestFileExtension]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
        [self.fileManager createFileAtPath:requestPath contents:data attributes:nil];
    }];
}

- (void)updateRequestFileWithRequest:(FKCacheRequestModel *)request {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestPath = [self.workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", request.url.SHA256, request.url.SHA256, self.requestFileExtension]];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:request];
        [data writeToFile:requestPath atomically:YES];
    }];
}

- (BOOL)existRequestWithRequest:(FKCacheRequestModel *)request {
    NSString *requestPath = [self.workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", request.url.SHA256, request.url.SHA256, self.requestFileExtension]];
    return [self.fileManager fileExistsAtPath:requestPath];
}

- (void)loadLocalRequestWithURL:(NSString *)url complete:(void (^)(FKCacheRequestModel * _Nullable request))complete {
    __weak typeof(self) weak = self;
    [[FKEngine engine].ioQueue addOperationWithBlock:^{
        __strong typeof(weak) self = weak;
        NSString *requestPath = [self.workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.%@", url.SHA256, url.SHA256, self.requestFileExtension]];
        FKCacheRequestModel *request = [NSKeyedUnarchiver unarchiveObjectWithFile:requestPath];
        if (complete) {
            complete(request);
        }
    }];
}


#pragma mark - Getter/Setter
- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

- (NSString *)requestFileExtension {
    return @"rqi";
}

@end
