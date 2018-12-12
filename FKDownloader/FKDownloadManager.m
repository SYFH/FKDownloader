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
#import "FKMapHub.h"
#import "FKDownloadExecutor.h"
#import "FKSystemHelper.h"
#import "FKTaskStorage.h"
#import "NSString+FKDownload.h"
#import "NSArray+FKDownload.h"
#import "FKDefine.h"
#import "FKReachability.h"

NS_ASSUME_NONNULL_BEGIN

@interface FKDownloadManager ()

@property (nonatomic, strong) NSURLSession          *session;
@property (nonatomic, strong) FKDownloadExecutor    *executor;
@property (nonatomic, strong) NSProgress            *progress;
@property (nonatomic, strong) FKMapHub              *taskHub;
@property (nonatomic, strong) NSThread              *timerThread;
@property (nonatomic, strong) FKReachability        *reachability;
@property (nonatomic, assign) BOOL                  isDidEnterBackground;

@end

NS_ASSUME_NONNULL_END

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
static FKDownloadManager *_instance = nil;
@implementation FKDownloadManager
@synthesize configure = _configure;

+ (void)load { [FKDownloadManager manager]; }

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
        [self setupReachability];
        [self setupSession];
        [self setupPath];
        [self setupNotification];
        [self setupProgress];
        [self setupThread];
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
            config.allowsCellularAccess = YES;
            config.discretionary = YES;
            self.session = [NSURLSession sessionWithConfiguration:config delegate:self.executor delegateQueue:nil];
        } else {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.timeoutIntervalForRequest = self.configure.timeoutInterval;
            config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            config.allowsCellularAccess = YES;
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
    
    if (self.configure.resumeSavePath.length) {
        isDirectory = NO;
        isFileExist = [self.fileManager fileExistsAtPath:self.configure.resumeSavePath isDirectory:&isDirectory];
        if (!(isFileExist && isDirectory)) {
            [self.fileManager createDirectoryAtPath:self.configure.resumeSavePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
    }
    
    if (self.configure.restoreFilePath.length) {
        isFileExist = [self.fileManager fileExistsAtPath:self.configure.restoreFilePath];
        if (!isFileExist) {
            [self.fileManager createFileAtPath:self.configure.restoreFilePath
                                      contents:nil
                                    attributes:nil];
        }
    }
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
                                             selector:@selector(saveTasks)
                                                 name:FKTaskErrorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restory)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fixProgressNotChanage)
                                                 name:UIApplicationDidBecomeActiveNotification
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

- (void)setupProgress {
    [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setupThread {
    self.timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(runTimerThread) object:nil];
    [self.timerThread start];
}

- (void)runTimerThread {
    @autoreleasepool {
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        if (self.progressBlock) {
            __weak typeof(self) weak = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                weak.progressBlock(weak.progress);
            });
        }
    }
}


#pragma mark - Operation
- (nullable FKTask *)acquire:(NSString *)url {
    FKLog(@"获取 FKTask: %@", url)
    checkURL(url);
    
    FKTask *task = [self.taskHub taskWithIdentifier:url.identifier];
    if (task) {
        return task;
    }
    
    task = [self.taskHub taskWithIdentifier:url.SHA256];
    if (task) {
        return task;
    }
    
    return task;
}

- (NSArray<FKTask *> *)acquireWithTag:(NSString *)tag {
    return [self.taskHub taskForTag:tag];
}

- (FKTask *)createPreserveTask:(NSString *)url {
    FKLog(@"创建并保存 FKTask:%@", url)
    FKTask *task = [[FKTask alloc] init];
    task.manager = self;
    task.url = url;
    if (task.isHasResumeData) {
        [task setValue:@(TaskStatusSuspend) forKey:@"status"];
    } else if (task.isFinish) {
        [task setValue:@(TaskStatusFinish) forKey:@"status"];
    } else {
        [task setValue:@(TaskStatusNone) forKey:@"status"];
    }
    // !!!: 提前进行预处理, 以防止任务延迟: https://forums.developer.apple.com/thread/14854
    // [task reday];
    
    return task;
}

- (void)executeTask:(FKTask *)task {
    FKLog(@"开始执行 FKTask: %@", task)
    // !!!: 会出现 kill app 后, 任务自动进行的情况, 暂时回退
    [task reday];
    if ([self filterTaskWithStatus:TaskStatusExecuting].count < self.configure.maximumExecutionTask) {
        FKLog(@"当前执行数量 %lu 小于 %ld", (unsigned long)[self filterTaskWithStatus:TaskStatusExecuting].count, (unsigned long)self.configure.maximumExecutionTask)
        [task execute];
    } else {
        FKLog(@"当前执行数量 %ld 已超过 %ld", (unsigned long)[self filterTaskWithStatus:TaskStatusExecuting].count, (unsigned long)self.configure.maximumExecutionTask)
        
        if (task.isFinish) {
            [task sendFinishInfo];
            [self startNextIdleTask];
        } else {
            switch (task.status) {
                case TaskStatusNone:
                    [task sendIdleInfo];
                    break;
                case TaskStatusPrepare:
                    [task sendIdleInfo];
                    break;
                case TaskStatusSuspend:
                    [task sendIdleInfo];
                    break;
                case TaskStatusCancelld:
                    [task sendIdleInfo];
                    break;
                default: break;
            }
        }
    }
}

- (void)addTaskWithArray:(NSArray *)array {
    NSArray *flatArray = [array flatten];
    dispatch_group_t group = dispatch_group_create();
    [flatArray forEach:^(id obj, NSUInteger idx) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if ([obj isKindOfClass:[NSString class]]) {
                [self add:obj];
            }
            if ([obj isKindOfClass:[NSURL class]]) {
                [self add:[(NSURL *)obj absoluteString]];
            }
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [self addInfo:obj];
            }
            dispatch_group_leave(group);
        });
    }];
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        [self saveTasks];
    });
}

- (FKTask *)add:(NSString *)url {
    FKLog(@"添加任务: %@", url)
    checkURL(url);
    
    FKTask *existedTask = [self acquire:url];
    if (existedTask) {
        // !!!: 手动添加以标记为归档加载的任务, 则重制标记为非归档加载
        existedTask.codingAdd = NO;
        return existedTask;
    }
    
    FKTask *task = [self createPreserveTask:url];
    [self.taskHub addTask:task withTag:nil];
    
//    [self saveTasks];
    return task;
}

- (FKTask *)addInfo:(NSDictionary *)info {
    if ([info.allKeys containsObject:FKTaskInfoURL]) {
        NSString *url = info[FKTaskInfoURL];
        FKLog(@"添加任务: %@", url)
        checkURL(url);
        
        FKTask *existedTask = [self acquire:url];
        if (existedTask) {
            existedTask.codingAdd = NO;
            [existedTask settingInfo:info];
            return existedTask;
        }
        
        FKTask *task = [self createPreserveTask:url];
        [task settingInfo:info];
        [self.taskHub addTask:task withTag:nil];
        
//        [self saveTasks];
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
    
    FKTask *existedTask = [self acquire:url];
    if (existedTask) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self executeTask:existedTask];
        });
        return existedTask;
    } else {
        return nil;
    }
    /*
    FKTask *task = [self createPreserveTask:url];
    [self.taskHub addTask:task withTag:nil];
     */
    
    /*
     因在返回 FKTask 后才设置代理, 所以部分代理和回调无法被调用
     设置一个 dispatch_after 表示延时执行, 先返回 FKTask, 延时时间设置为 0, 再执行预处理或执行
     */
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self executeTask:task];
    });
    return task;
    */
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
    
    FKTask *existedTask = [self acquire:url];
    if (!existedTask) { return; }
    if (existedTask.status == TaskStatusSuspend) { return; }
    
    [existedTask suspend];
}

- (void)resume:(NSString *)url {
    FKLog(@"恢复任务: %@", url)
    checkURL(url);
    
    FKTask *existedTask = [self acquire:url];
    if (!existedTask) { return; }
    if (existedTask.status == TaskStatusExecuting) { return; }
    
    [existedTask resume];
}

- (void)remove:(NSString *)url {
    FKLog(@"移除任务: %@", url)
    checkURL(url);
    
    FKTask *existedTask = [self acquire:url];
    if (!existedTask) { return; }
    
    if (existedTask.status == TaskStatusExecuting) { [existedTask cancel]; }
    [existedTask clear];
    
    if (self.configure.isDeleteFinishFile && existedTask.status == TaskStatusFinish) {
        NSString *filePath = existedTask.filePath;
        if ([self.fileManager fileExistsAtPath:filePath]) {
            NSError *error;
            [self.fileManager removeItemAtPath:filePath error:&error];
            if (error) {
                // !!!: 删除文件失败, 需要时手动删除
                NSError *taskError = [NSError errorWithDomain:FKErrorDomain
                                                     code:TaskErrorDeleteFileFaild
                                                 userInfo:@{FKErrorInfoTaskKey: existedTask,
                                                            FKErrorInfoDescriptKey: @"删除文件失败",
                                                            FKErrorInfoUnderlyingErrorKey: error }];
                [existedTask sendErrorInfo:taskError];
            }
        }
    }
    
    [existedTask sendWillRemoveInfo];
    [self.taskHub removeTask:existedTask];
    [existedTask sendRemoveInfo];
    
//    [self saveTasks];
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
        } else {
            // TODO: 没有归档时会来这里, 可以获取恢复数据后取消, 以便后期使用
            [downloadTask cancel];
        }
    }];
}

- (void)saveTasks {
    if (self.configure.isAutoCoding) {
        FKLog(@"归档所有任务")
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [FKTaskStorage saveObject:self.tasks toPath:self.configure.restoreFilePath];
        });
    }
}

- (void)loadTasks {
    if ([self.fileManager fileExistsAtPath:self.configure.restoreFilePath] && self.configure.isAutoCoding) {
        FKLog(@"解档所有任务")
        NSArray<FKTask *> *tasks = [FKTaskStorage loadData:self.configure.restoreFilePath];
        [tasks forEach:^(FKTask *task, NSUInteger idx) {
            if (![self acquire:task.url]) {
                task.manager = self;
                task.codingAdd = YES;
                [self.taskHub addTask:task withTag:nil];
                
                if (self.configure.isAutoStart) {
                    FKLog(@"自动开始任务: %@", task)
                    if (task.status == TaskStatusSuspend) {
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
    [self setupPath];
}

- (FKMapHub *)taskHub {
    if (!_taskHub) {
        _taskHub = [[FKMapHub alloc] init];
    }
    return _taskHub;
}

- (NSProgress *)progress {
    if (!_progress) {
        _progress = [[NSProgress alloc] init];
    }
    return _progress;
}

- (FKDownloadExecutor *)executor {
    if (!_executor) {
        _executor = [[FKDownloadExecutor alloc] init];
        _executor.manager = self;
    }
    return _executor;
}

- (NSArray<FKTask *> *)tasks {
    return [self.taskHub allTask];
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
