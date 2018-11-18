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

/**
 配置实例. 每次被赋值时都会设置 Session
 */
@property (nonatomic, strong) FKConfigure               *configure;

/**
 NSURLSession 实例
 */
@property (nonatomic, strong, readonly) NSURLSession    *session;

/**
 文件管理
 */
@property (nonatomic, strong, readonly) NSFileManager   *fileManager;

/**
 所有任务集合, 可通过 -[NSArray forEach:] 遍历任务, 执行自定义处理
 */
@property (nonatomic, copy  , readonly) NSMutableArray<FKTask *> *tasks;

/**
 总任务进度
 */
@property (nonatomic, strong, readonly) NSProgress *progress;

/**
 初始化下载管理器

 @return 单例模式
 */
+ (instancetype)manager;

/**
 配置基础路径, 以防止文件夹不存在
 */
- (void)setupPath;

#pragma mark - Operation
/**
 获取已有任务

 @param url 下载地址
 @return 任务实例
 */
- (FKTask *)acquire:(NSString *)url;


/**
 添加任务, 但不执行, 任务状态为 TaskStatusNone

 @param url 下载地址
 @return 任务实例
 */
- (FKTask *)add:(NSString *)url;

/**
 添加任务, 可附带指定参数, 但不执行, 任务状态为 TaskStatusNone
 可添加参数请查看 `FKTaskInfoName` 相关的信息

 @param info 包含附加参数的url
 @return 任务实例
 */
- (FKTask *)addInfo:(NSDictionary *)info;

/**
 开始任务, 如果下载链接对应的任务不存在, 就会创建任务
 任务状态变动为 TaskStatusNone -> TaskStatusPrepare -> TaskStatusExecuting

 @param url 下载地址
 @return 任务实例
 */
- (FKTask *)start:(NSString *)url;

/**
 取消任务

 @param url 下载链接
 */
- (void)cancel:(NSString *)url;

/**
 暂停任务

 @param url 下载链接
 */
- (void)suspend:(NSString *)url;

/**
 恢复任务

 @param url 下载链接
 */
- (void)resume:(NSString *)url;

/**
 移除任务

 @param url 下载链接
 */
- (void)remove:(NSString *)url;


/**
 开始下一个等待中的任务
 */
- (void)startNextIdleTask;


#pragma mark - Restore
/**
 恢复任务, 需要在 -[AppDelegate didFinishLaunchingWithOptions] 中设置完配置实例后调用
 以加载并恢复被持久化的任务
 */
- (void)restory;

/**
 修复在 iOS 12/12.1 iPhone 8以下出现前后台切换后进度无法正确获取的问题
 必须在 -[AppDelegate applicationDidBecomeActive] 内执行
 */
- (void)fixProgressNotChanage;


#pragma mark - Filter
/**
 筛选出指定状态的任务集合

 @param status 状态
 @return 任务集合
 */
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
