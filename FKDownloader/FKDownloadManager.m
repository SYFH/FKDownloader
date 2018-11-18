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
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, DeviceModel) {
    DeviceModelAirPods,
    DeviceModelAppleTV,
    DeviceModelAppleWatch,
    DeviceModelHomePod,
    DeviceModeliPad,
    DeviceModeliPadMini,
    DeviceModeliPhone,
    DeviceModeliPodTouch,
};

@interface FKDownloadManager ()

@property (nonatomic, strong) NSURLSession          *session;
@property (nonatomic, strong) FKDownloadExecutor    *executor;
@property (nonatomic, copy  ) NSMutableArray<FKTask *> *tasks;
@property (nonatomic, copy  ) NSMutableDictionary   *tasksMap;

@property (nonatomic, strong) NSProgress            *progress;

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
        [self setupProperty];
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
    FKLog(@"配置文件路径")
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


#pragma mark - Operation
- (FKTask *)acquire:(NSString *)url {
    FKLog(@"获取 FKTask: %@", url)
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    NSString *identifier = [url SHA256];
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
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if ([self acquire:url]) {
        return [self acquire:url];
    }
    
    FKTask *task = [self createPreserveTask:url];
    [self saveTasks];
    return task;
}

- (FKTask *)start:(NSString *)url {
    FKLog(@"开始任务: %@", url)
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
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
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    FKTask *task = [self acquire:url];
    if (!task) { return; }
    if (task.status == TaskStatusCancelld) { return; }
    [task cancel];
}

- (void)suspend:(NSString *)url {
    FKLog(@"暂停任务: %@", url)
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if (![self acquire:url]) { return; }
    if ([self acquire:url].status == TaskStatusSuspend) { return; }
    
    FKTask *task = [self acquire:url];
    [task suspend];
}

- (void)resume:(NSString *)url {
    FKLog(@"恢复任务: %@", url)
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
    if (![self acquire:url]) { return; }
    if ([self acquire:url].status == TaskStatusExecuting) { return; }
    
    FKTask *task = [self acquire:url];
    [task resume];
}

- (void)remove:(NSString *)url {
    FKLog(@"移除任务: %@", url)
    NSAssert([NSURL URLWithString:url] != nil, @"URL 地址不合法, 请填写正确的 URL!");
    
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
    [tasks forEach:^(NSURLSessionDownloadTask *downloadTask) {
        NSString *url = downloadTask.currentRequest.URL.absoluteString;
        FKTask *task = [self acquire:url];
        if (task) {
            [task restore:downloadTask];
        }
    }];
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
        [tasks forEach:^(NSString *url) {
            if (![self acquire:url]) {
                FKTask *task = [self createPreserveTask:url];
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
    if (([[[UIDevice currentDevice] systemVersion] isEqualToString:@"12.0"] ||
         [[[UIDevice currentDevice] systemVersion] isEqualToString:@"12.1"]) &&
        [self currentDeviceModelVersion:DeviceModeliPhone] < 10) {
        
        FKLog(@"开始解决进度监听失效")
        [self.tasks forEach:^(FKTask *task) {
            if (task.status == TaskStatusExecuting) {
                [task suspendWithComplete:^{
                    [task resume];
                }];
            }
        }];
    }
}


#pragma mark - Filter
- (NSArray<FKTask *> *)filterTaskWithStatus:(NSUInteger)status {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %d", status];
    return [self.tasks filteredArrayUsingPredicate:predicate];
}


#pragma mark - Private Methode
// !!!: https://www.theiphonewiki.com/wiki/Models 可根据版本号和子版本号确定设备, NSNotFound 为暂时无法识别
- (NSInteger)currentDeviceModelVersion:(DeviceModel)model {
    NSInteger version = NSNotFound;
    if ([self currentDeviceSimulator]) {
        return version;
    }
    
    switch (model) {
        case DeviceModelAirPods: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"AirPods".length, 1)] integerValue];
        } break;
            
        case DeviceModelAppleTV: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"AppleTV".length, 1)] integerValue];
        } break;
            
        case DeviceModelAppleWatch: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"Watch".length, 1)] integerValue];
        } break;
            
        case DeviceModelHomePod: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"AudioAccessory".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPad: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPad".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPadMini: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPad".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPhone: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPhone".length, 1)] integerValue];
        } break;
            
        case DeviceModeliPodTouch: {
            version = [[[self currentDeviceName] substringWithRange:NSMakeRange(@"iPod".length, 1)] integerValue];
        } break;
    }
    return version;
}

- (NSInteger)currentDeviceModelSubversion:(DeviceModel)model {
    NSInteger version = NSNotFound;
    if ([self currentDeviceSimulator]) {
        return version;
    }
    
    version = [[[self currentDeviceName] substringWithRange:NSMakeRange([self currentDeviceName].length - 1, 1)] integerValue];
    return version;
}

- (BOOL)currentDeviceSimulator {
    if ([[self currentDeviceName] isEqualToString:@"i386"] ||
        [[self currentDeviceName] isEqualToString:@"x86_64"]) {
        
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)currentDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
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
