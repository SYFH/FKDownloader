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
#import "FKSystemHelper.h"
#import "FKTaskStorage.h"
#import "NSString+FKDownload.h"
#import "NSArray+FKDownload.h"
#import "FKDefine.h"
#import "FKReachability.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKDownloadManager ()

@property (nonatomic, strong) NSURLSession              *session;
@property (nonatomic, strong) FKDownloadExecutor        *executor;
@property (nonatomic, strong) NSProgress                *progress;
@property (nonatomic, copy  ) NSMutableArray<FKTask *>  *tasks;
@property (nonatomic, copy  ) NSMutableDictionary       *tasksMap;

@property (nonatomic, strong) FKReachability            *reachability;

@property (nonatomic, assign) BOOL                      isDidEnterBackground;

@end

NS_ASSUME_NONNULL_END

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
        [self setupProperty];
        [self setupNotification];
        [self setupReachability];
    }
    return self;
}

- (void)setupSession {
    FKLog(@"配置 NSURLSession")
    if (self.session) {
        return;
    } else {
        if (self.configure.isBackgroudExecute) {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.configure.sessionIdentifier];
            config.timeoutIntervalForRequest = self.configure.timeoutInterval;
            config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            self.session = [NSURLSession sessionWithConfiguration:config delegate:self.executor delegateQueue:nil];
        } else {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.timeoutIntervalForRequest = self.configure.timeoutInterval;
            config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            self.session = [NSURLSession sessionWithConfiguration:config delegate:self.executor delegateQueue:nil];
        }
    }
}

- (void)setupPath {
    FKLog(@"配置所需文件夹")
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

- (void)setupProperty {
    self.progress = [[NSProgress alloc] init];
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveTasks)
                                                 name:FKTaskDidExecuteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveTasks)
                                                 name:FKTaskDidSuspendNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveTasks)
                                                 name:FKTaskDidCancelldNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveTasks)
                                                 name:FKTaskDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)setupReachability {
    self.reachability = [FKReachability reachabilityWithHostName:@"www.baidu.com"];
    [self.reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:FKReachabilityChangedNotification
                                               object:nil];
}


#pragma mark - Operation
- (nullable FKTask *)acquire:(NSString *)url {
    FKLog(@"获取 FKTask: %@", url)
    checkURL(url);
    
    NSURL *u = [NSURL URLWithString:url];
    NSString *identifier = [[NSString stringWithFormat:@"%@://%@%@", u.scheme, u.host, u.path] SHA256];
    return self.tasksMap[identifier];
}

- (FKTask *)createPreserveTask:(NSString *)url {
    FKLog(@"创建并保存 FKTask:%@", url)
    FKTask *task = [[FKTask alloc] init];
    task.url = url;
    task.manager = self;
    if (task.isHasResumeData) {
        [task setValue:@(TaskStatusSuspend) forKey:@"status"];
    } else if (task.isFinish) {
        [task setValue:@(TaskStatusFinish) forKey:@"status"];
    } else {
        [task setValue:@(TaskStatusNone) forKey:@"status"];
    }
    [self.tasks addObject:task];
    self.tasksMap[task.identifier] = task;
    return task;
}

- (void)executeTask:(FKTask *)task {
    FKLog(@"开始执行 FKTask: %@", task)
    [task reday];
    if ([self filterTaskWithStatus:TaskStatusExecuting].count < self.configure.maximumExecutionTask) {
        FKLog(@"当前执行数量 %lu 小于 %ld", (unsigned long)[self filterTaskWithStatus:TaskStatusExecuting].count, (unsigned long)self.configure.maximumExecutionTask)
        [task execute];
    } else {
        FKLog(@"当前执行数量 %ld 已超过 %ld", (unsigned long)[self filterTaskWithStatus:TaskStatusExecuting].count, (unsigned long)self.configure.maximumExecutionTask)
        [task sendIdleInfo];
    }
}

// TODO: 状态切换: 在添加任务时是 none, 直接开始任务时是 idle/executing, 暂停时是 suspend, 取消时是 del?/idle?/none?
- (FKTask *)add:(NSString *)url {
    FKLog(@"添加任务: %@", url)
    checkURL(url);
    
    if ([self acquire:url]) {
        return [self acquire:url];
    }
    
    FKTask *task = [self createPreserveTask:url];
    [self saveTasks];
    return task;
}

- (FKTask *)addInfo:(NSDictionary *)info {
    if ([info.allKeys containsObject:FKTaskInfoURL]) {
        NSString *url = info[FKTaskInfoURL];
        FKLog(@"添加任务: %@", url)
        checkURL(url);
        
        if ([self acquire:url]) {
            FKTask *task = [self acquire:url];
            [task settingInfo:info];
            return [self acquire:url];
        }
        
        FKTask *task = [self createPreserveTask:url];
        [task settingInfo:info];
        
        [self saveTasks];
        return task;
    } else {
        checkURL(@"");
        return nil;
    }
}

- (FKTask *)start:(NSString *)url {
    FKLog(@"开始任务: %@", url)
    checkURL(url);
    
    if ([self acquire:url].status == TaskStatusExecuting) {
        return [self acquire:url];
    }
    
    if ([self acquire:url]) {
        FKTask *task = [self acquire:url];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self executeTask:task];
        });
        return task;
    }
    
    FKTask *task = [self createPreserveTask:url];
    
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
    FKLog(@"开始执行下一个等待中任务")
    if ([self filterTaskWithStatus:TaskStatusExecuting].count < self.configure.maximumExecutionTask) {
        FKTask *nextTask = [[FKDownloadManager manager] filterTaskWithStatus:TaskStatusIdle].firstObject;
        if (nextTask) {
            [nextTask execute];
        }
    }
}

- (void)cancel:(NSString *)url {
    FKLog(@"取消任务: %@", url)
    checkURL(url);
    
    FKTask *task = [self acquire:url];
    if (!task) { return; }
    if (task.status == TaskStatusCancelld) { return; }
    [task cancel];
}

- (void)suspend:(NSString *)url {
    FKLog(@"暂停任务: %@", url)
    checkURL(url);
    
    if (![self acquire:url]) { return; }
    if ([self acquire:url].status == TaskStatusSuspend) { return; }
    
    FKTask *task = [self acquire:url];
    [task suspend];
}

- (void)resume:(NSString *)url {
    FKLog(@"恢复任务: %@", url)
    checkURL(url);
    
    if (![self acquire:url]) { return; }
    if ([self acquire:url].status == TaskStatusExecuting) { return; }
    
    FKTask *task = [self acquire:url];
    [task resume];
}

- (void)remove:(NSString *)url {
    FKLog(@"移除任务: %@", url)
    checkURL(url);
    
    if (![self acquire:url]) { return; }
    
    FKTask *task = [self acquire:url];
    if (task.status == TaskStatusExecuting) { [task cancel]; }
    [task clear];
    [self.tasks removeObject:task];
    [self.tasksMap removeObjectForKey:[url SHA256]];
    
    [self saveTasks];
}


#pragma mark - Restore
- (void)restory {
    [[FKDownloadManager manager] loadTasks];
    [[FKDownloadManager manager].session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> *dataTasks, NSArray<NSURLSessionUploadTask *> *uploadTasks, NSArray<NSURLSessionDownloadTask *> *downloadTasks) {
        
        [self restory:downloadTasks];
    }];
}

- (void)restory:(NSArray<NSURLSessionDownloadTask *> *)tasks {
    [tasks forEach:^(NSURLSessionDownloadTask *downloadTask, NSUInteger idx) {
        NSString *url = downloadTask.currentRequest.URL.absoluteString;
        FKTask *task = [self acquire:url];
        if (task) {
            [task restore:downloadTask];
        }
    }];
}

- (void)saveTasks {
    FKLog(@"归档所有任务")
    [FKTaskStorage saveObject:self.tasks toPath:self.configure.restorePath];
}

- (void)loadTasks {
    FKLog(@"解档所有任务")
    if ([self.fileManager fileExistsAtPath:self.configure.restorePath]) {
        NSArray<FKTask *> *tasks = [FKTaskStorage loadData:self.configure.restorePath];
        [tasks forEach:^(FKTask *task, NSUInteger idx) {
            if (![self acquire:task.url]) {
                task.manager = self;
                [self.tasks addObject:task];
                self.tasksMap[task.identifier] = task;
                if (self.configure.isAutoStart) {
                    if (task.status != TaskStatusUnknowError) {
                        [self executeTask:task];
                    }
                }
            }
        }];
    }
}

// !!!: iOS 12/12.1, iPhone 8以下, 后台下载时, 进入后台会导致监听失败, 但暂停时, 进度获取正确, 说明下载还在执行, 目前重置监听无效, 需要尝试进入后台暂停, 即将前台继续
// !!!: 目前前后台切换状态尝试都失效, 会出现 unknown error, 可能需要针对性判断, 使用 NSTimer 监听进度
// !!!: 问题根源在于 countOfBytesReceived/countOfBytesExpectedToReceive 没有改变, 导致代理, KVO 和 NSTimer 失效, 需要寻找新的方法来获取进度
// !!!: 目前使用带有恢复数据的取消后再次继续执行可解决问题, 但必须在 -[AppDelegate applicationDidBecomeActive] 内执行, 在`applicationWillEnterForeground` 内执行失败, 且必须在写入恢复数据后继续才有效, 否则出现 load error.
- (void)fixProgressNotChanage {
    if (self.isDidEnterBackground == NO) {
        return;
    }
    if (([[FKSystemHelper currentSystemVersion] isEqualToString:@"12.0"] ||
         [[FKSystemHelper currentSystemVersion] isEqualToString:@"12.1"]) &&
        [FKSystemHelper currentDeviceModelVersion:DeviceModeliPhone] < 10) {
        
        FKLog(@"开始解决进度监听失效")
        [self.tasks forEach:^(FKTask *task, NSUInteger idx) {
            if (task.status == TaskStatusExecuting) {
                [task suspendWithComplete:^{
                    [task resume];
                }];
            }
        }];
        self.isDidEnterBackground = NO;
    }
}


#pragma mark - Filter
- (NSArray<FKTask *> *)filterTaskWithStatus:(NSUInteger)status {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %d", status];
    return [self.tasks filteredArrayUsingPredicate:predicate];
}


#pragma mark - Private Methode
- (void)reachabilityChanged:(NSNotification *)note {
    switch (self.reachability.currentReachabilityStatus) {
        case NotReachable: {
            [self.tasks forEach:^(FKTask *task, NSUInteger idx) {
                if (task.status == TaskStatusExecuting) {
                    task.error = [NSError errorWithDomain:NSURLErrorDomain
                                                     code:NSURLErrorNotConnectedToInternet
                                                 userInfo:@{NSFilePathErrorKey: task.url,
                                                            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Network Unavailable"]}];
                    [task suspend];
                }
                if (task.status == TaskStatusIdle) {
                    [task cancel];
                }
            }];
        } break;
            
        case ReachableViaWiFi: {
            [self.tasks forEach:^(FKTask *task, NSUInteger idx) {
                if (task.error.code == NSURLErrorNotConnectedToInternet) {
                    [task execute];
                }
            }];
        } break;
            
        case ReachableViaWWAN: {
            if (self.configure.isAllowCellular) {
                [self.tasks forEach:^(FKTask *task, NSUInteger idx) {
                    if (task.error.code == NSURLErrorNotConnectedToInternet) {
                        [task execute];
                    }
                }];
            }
        } break;
    }
}

- (void)didEnterBackground:(NSNotification *)notify {
    self.isDidEnterBackground = YES;
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
