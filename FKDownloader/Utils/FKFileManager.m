//
//  FKFileManager.m
//  FKDownloader
//
//  Created by norld on 2020/1/1.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKFileManager.h"

#import "NSURLSessionDownloadTask+FKCategory.h"
#import "NSString+FKCategory.h"

#import "FKCache.h"

@interface FKFileManager ()

@property (nonatomic, strong) NSString *taskFileExtension;
@property (nonatomic, strong) NSString *requestFileExtension;
@property (nonatomic, strong) NSOperationQueue *queue;
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
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (NSString *)workFinder {
    return self.workPath;
}

- (BOOL)existWithTaskID:(NSString *)taskID {
    NSString *taskPath = [self.workPath stringByAppendingPathComponent:taskID];
    return [self.fileManager fileExistsAtPath:taskPath];
}

- (BOOL)existWithRequestURL:(NSString *)requestURL taskID:(NSString *)taskID {
    NSString *requestPath = [self.workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", taskID, requestURL.SHA1]];
    return [self.fileManager fileExistsAtPath:requestPath];
}

- (void)createFinderWithTaskID:(NSString *)taskID requests:(nonnull NSArray<NSMutableURLRequest *> *)requests {
    for (NSMutableURLRequest *request in requests) {
        NSString *requestURL = request.URL.absoluteString;
        NSString *requestURLSHA1 = requestURL.SHA1;
        NSString *requestPath = [self.workPath stringByAppendingPathComponent:requestURLSHA1];
        [self.fileManager createDirectoryAtPath:requestPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)taskInfoWithTaskID:(NSString *)taskID complete:(void (^)(FKCacheTaskModel * _Nullable))complete {
    [self.queue addOperationWithBlock:^{
        NSString *taskFileName = [NSString stringWithFormat:@"%@.%@", taskID, self.taskFileExtension];
        NSString *taskFilePath = [self.workPath stringByAppendingPathComponent:taskFileName];
        FKCacheTaskModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:taskFilePath];
        if (complete) {
            complete(model);
        }
    }];
}

- (void)requestInfoWithRequestURL:(NSString *)url complete:(void (^)(FKCacheRequestModel * _Nullable))complete {
    [self.queue addOperationWithBlock:^{
        NSString *requestFileName = [NSString stringWithFormat:@"%@.%@", url.SHA1, self.requestFileExtension];
        __block NSString *targetTaskID = @"";
        [[FKCache cache] taskWithRequestURL:url complete:^(NSString *taskID) {
            targetTaskID = taskID;
        }];
        NSString *requestFilePath = [self.workPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", targetTaskID, requestFileName]];
        FKCacheRequestModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:requestFilePath];
        if (complete) {
            complete(model);
        }
    }];
}


#pragma mark - Getter/Setter
- (NSOperationQueue *)queue {
    @synchronized (self) {
        if (!_queue) {
            _queue = [[NSOperationQueue alloc] init];
        }
        return _queue;
    }
}

- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

- (NSString *)taskFileExtension {
    return @"tki";
}

- (NSString *)requestFileExtension {
    return @"rqi";
}

@end
