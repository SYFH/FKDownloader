//
//  FKDownloadManager.h
//  FKDownloader
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FKConfigure;
@class FKTask;

#ifdef DEBUG
#define FKLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define FKLog(FORMAT, ...)
#endif

__attribute__((objc_subclassing_restricted))
@interface FKDownloadManager : NSObject

@property (nonatomic, strong) FKConfigure               *configure;
@property (nonatomic, strong, readonly) NSURLSession    *session;
@property (nonatomic, strong, readonly) NSFileManager   *fileManager;
@property (nonatomic, copy  , readonly) NSMutableArray<FKTask *> *tasks;
+ (instancetype)manager;
- (void)setupPath;

#pragma mark - Operation
- (FKTask *)acquire:(NSString *)url;

- (FKTask *)add:(NSString *)url;
- (FKTask *)start:(NSString *)url;
- (void)cancel:(NSString *)url;
- (void)suspend:(NSString *)url;
- (void)resume:(NSString *)url;
- (void)remove:(NSString *)url;

- (void)startNextIdleTask;

#pragma mark - Progress
// TODO: 可添加总进度和总预期时间


#pragma mark - Restore
- (void)restory;
- (void)restory:(NSArray<NSURLSessionDownloadTask *> *)tasks;
- (void)saveTasks;
- (void)loadTasks;
- (void)fixProgressNotChanage;


#pragma mark - Filter
- (NSArray<FKTask *> *)filterTaskWithStatus:(NSUInteger)status;

#pragma mark - Disable Method
- (instancetype)init                                    OBJC_DEPRECATED("use +[FKDownloadManager manager];");
- (void)dealloc                                         UNAVAILABLE_ATTRIBUTE;
+ (void)init                                            OBJC_DEPRECATED("use +[FKDownloadManager manager];");
+ (instancetype)new                                     OBJC_DEPRECATED("use +[FKDownloadManager manager];");
+ (instancetype)allocWithZone:(struct _NSZone *)zone    OBJC_DEPRECATED("use +[FKDownloadManager manager];");
+ (instancetype)alloc                                   OBJC_DEPRECATED("use +[FKDownloadManager manager];");
- (id)copy                                              OBJC_DEPRECATED("use +[FKDownloadManager manager];");
- (id)mutableCopy                                       OBJC_DEPRECATED("use +[FKDownloadManager manager];");
+ (id)copyWithZone:(struct _NSZone *)zone               OBJC_DEPRECATED("use +[FKDownloadManager manager];");
+ (id)mutableCopyWithZone:(struct _NSZone *)zone        OBJC_DEPRECATED("use +[FKDownloadManager manager];");

@end
