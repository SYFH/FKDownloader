//
//  FKDownloadManager.m
//  FKDownloader
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKDownloadManager.h"
#import "FKConfigure.h"
#import "FKTask.h"
#import "FKDownloadExecutor.h"
#import "NSString+FKDownload.h"
#import "NSArray+FKDownload.h"

@interface FKDownloadManager ()

@property (nonatomic, strong) NSURLSession          *session;
@property (nonatomic, strong) FKDownloadExecutor    *executor;
@property (nonatomic, copy  ) NSMutableArray<FKTask *> *tasks;
@property (nonatomic, copy  ) NSMutableDictionary   *tasksMap;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
static FKDownloadManager *_instance = nil;
@implementation FKDownloadManager
@synthesize configure = _configure;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t downloadManagerToken;
    dispatch_once(&downloadManagerToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)new {
    return [FKDownloadManager manager];
}

+ (instancetype)manager {
    static dispatch_once_t downloadManagerToken;
    dispatch_once(&downloadManagerToken, ^{
        _instance = [[super alloc] initWithSetup];
    });
    return _instance;
}

#pragma mark - Setup
- (instancetype)initWithSetup {
    self = [super init];
    if (self) {
        [self setupSession];
        [self setupPath];
    }
    return self;
}

- (void)setupSession {
    if (self.session) { return; }
    if (self.configure.isBackgroudExecute) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.configure.sessionIdentifier];
        config.timeoutIntervalForRequest = self.configure.timeoutInterval;
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self.executor delegateQueue:nil];
    } else {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = self.configure.timeoutInterval;
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self.executor delegateQueue:nil];
    }
}

- (void)setupPath {
    BOOL isDirectory = NO;
    BOOL isFileExist = NO;
    
    if (self.configure.savePath.length) {
        isDirectory = NO;
        isFileExist = [self.fileManager fileExistsAtPath:self.configure.savePath isDirectory:&isDirectory];
        if (!(isFileExist && isDirectory)) {
            [self.fileManager createDirectoryAtPath:self.configure.savePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
    }
    
    if (self.configure.resumePath.length) {
        isDirectory = NO;
        isFileExist = [self.fileManager fileExistsAtPath:self.configure.resumePath isDirectory:&isDirectory];
        if (!(isFileExist && isDirectory)) {
            [self.fileManager createDirectoryAtPath:self.configure.resumePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
    }
}


#pragma mark - Restore
- (void)restory {
    [[FKDownloadManager manager] loadTasks];
    [[FKDownloadManager manager].session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *dataTasks, NSArray<NSURLSessionUploadTask *> *uploadTasks, NSArray<NSURLSessionDownloadTask *> *downloadTasks) {
        
        [self restory:downloadTasks];
    }];
}

- (void)restory:(NSArray<NSURLSessionDownloadTask *> *)tasks {
    for (NSURLSessionDownloadTask *downloadTask in tasks) {
        NSString *url = downloadTask.currentRequest.URL.absoluteString;
        FKTask *task = [self acquire:url];
        if (task) {
            [task restore:downloadTask];
        }
    }
}

- (void)saveTasks {
    NSArray<NSString *> *urls = [self.tasks map:^id(FKTask *obj) { return obj.url; }];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:urls format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    [data writeToFile:self.configure.restorePath atomically:YES];
}

- (void)loadTasks {
    if ([self.fileManager fileExistsAtPath:self.configure.restorePath]) {
        NSData *data = [NSData dataWithContentsOfFile:self.configure.restorePath options:NSDataReadingMappedIfSafe error:nil];
        NSArray<NSString *> *tasks = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:nil];
        for (NSString *url in tasks) {
            if (![self acquire:url]) {
                [self addTask:url];
            }
        }
    }
}

// TODO: iOS 12/12.1 后台下载时, 进入前台会导致监听失败, 但暂停时, 进度获取正确, 说明下载还在执行, 目前重置监听无效
- (void)resetProgressObserver {
    for (FKTask *task in self.tasks) {
        [task removeProgressObserver];
        [task addProgressObserver];
    }
}


#pragma mark - Filter
- (NSArray<FKTask *> *)filterTaskWithStatus:(NSUInteger)status {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %d", status];
    return [self.tasks filteredArrayUsingPredicate:predicate];
}


#pragma mark - Operation
- (FKTask *)acquire:(NSString *)url {
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    NSString *identifier = [url SHA256];
    return self.tasksMap[identifier];
}

- (FKTask *)addTask:(NSString *)url {
    FKTask *task = [[FKTask alloc] init];
    task.url = url;
    task.manager = self;
    [task setValue:@(TaskStatusNone) forKey:@"status"];
    [self.tasks addObject:task];
    self.tasksMap[task.identifier] = task;
    return task;
}

- (void)executeTask:(FKTask *)task {
    [task reday];
    if ([self filterTaskWithStatus:TaskStatusExecuting].count < self.configure.maximumExecutionTask) {
        [task execute];
    } else {
        [task setValue:@(TaskStatusIdle) forKey:@"status"];
    }
}

- (FKTask *)start:(NSString *)url {
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if ([self acquire:url]) {
        FKTask *task = [self acquire:url];
        if (task.status != TaskStatusExecuting) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self executeTask:task];
            });
        }
        return task;
    }
    
    FKTask *task = [self addTask:url];
    [self saveTasks];
    
    /*
     因在返回 FKTask 后才设置代理, 所以部分代理和回调无法被调用
     设置一个 dispatch_after 表示延时执行, 先返回 FKTask, 延时时间设置为 0
     再执行预处理或执行
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self executeTask:task];
    });
    
    return task;
}

- (void)startNextIdleTask {
    if ([self filterTaskWithStatus:TaskStatusExecuting].count < self.configure.maximumExecutionTask) {
        FKTask *nextTask = [[FKDownloadManager manager] filterTaskWithStatus:TaskStatusIdle].firstObject;
        if (nextTask) {
            [nextTask execute];
        }
    }
}

- (void)cancel:(NSString *)url {
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    FKTask *task = [self acquire:url];
    if (!task) {
        return;
    }
    [task cancel];
}

- (void)suspend:(NSString *)url {
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if (![self acquire:url]) {
        return;
    }
    
    FKTask *task = [self acquire:url];
    [task suspend];
}

- (void)resume:(NSString *)url {
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if (![self acquire:url]) {
        return;
    }
    
    FKTask *task = [self acquire:url];
    [task resume];
}

- (void)remove:(NSString *)url {
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if (![self acquire:url]) {
        return;
    }
    
    FKTask *task = [self acquire:url];
    if (task.status == TaskStatusExecuting) {
        [task cancel];
    }
    [task clear];
    [self.tasks removeObject:task];
    [self.tasksMap removeObjectForKey:[url SHA256]];
    
    [self saveTasks];
}


#pragma mark - Getter/Setter
- (FKConfigure *)configure {
    if (!_configure) {
        _configure = [FKConfigure defaultConfigure];
    }
    return _configure;
}

- (void)setConfigure:(FKConfigure *)configure {
    _configure = configure;
    [self setupSession];
}

- (FKDownloadExecutor *)executor {
    if (!_executor) {
        _executor = [[FKDownloadExecutor alloc] init];
        _executor.manager = self;
    }
    return _executor;
}

- (NSMutableArray<FKTask *> *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

- (NSMutableDictionary *)tasksMap {
    if (!_tasksMap) {
        _tasksMap = [NSMutableDictionary dictionary];
    }
    return _tasksMap;
}

- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}


#pragma mark - Disable Method
- (id)copy                                          {return _instance;}
- (id)mutableCopy                                   {return _instance;}
+ (id)copyWithZone:(struct _NSZone *)zone           {return _instance;}
+ (id)mutableCopyWithZone:(struct _NSZone *)zone    {return _instance;}

@end
#pragma clang diagnostic pop
