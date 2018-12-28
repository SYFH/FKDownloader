//
//  FKDownloadManager.h
//  FKDownloader
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FKDefine.h"
@class FKConfigure;
@class FKTask;
@class FKMapHub;
@class FKReachability;

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_subclassing_restricted))
NS_SWIFT_NAME(Downloader)
@interface FKDownloadManager : NSObject

/**
 配置实例. 每次被赋值时都会设置 Session
 */
@property (nonatomic, strong) FKConfigure *configure;

/**
 NSURLSession 实例
 */
@property (nonatomic, strong, readonly) NSURLSession *session;

/**
 文件管理
 */
@property (nonatomic, strong, readonly) NSFileManager *fileManager;

/**
 保存 Task/Tag 相关的集合, 可以更快的更方便的添加与查找 Task/Tag 信息
 可使用 -[FKMapHub allTask] 获取所有任务
 */
@property (nonatomic, strong, readonly) FKMapHub *taskHub;

/**
 总任务进度
 */
@property (nonatomic, strong, readonly) NSProgress *progress;

/**
 运行 NSTimer 的子线程, 避免造成主线程卡顿
 */
@property (nonatomic, strong, readonly) dispatch_queue_t timerQueue;
/**
 总任务进度 Block, 可能会在子线程内执行
 */
@property (nonatomic, copy  ) FKTotalProgress progressBlock;

/**
 添加任务组完成后事件 Block, 可能会在子线程内执行, 注意线程的切换
 当在主线程上添加大量(>500)任务时, 可在子线程上添加避免 UI 卡顿, 这时可以使用该 Block 执行 UI 相关的操作
 */
@property (nonatomic, copy  ) FKVoidDone addedBlock;

/**
 网络状态检测
 */
@property (nonatomic, strong, readonly) FKReachability *reachability;

/**
 初始化下载管理器

 @return 单例模式
 */
+ (instancetype)manager NS_SWIFT_NAME(shared());

/**
 配置基础路径, 以防止文件夹不存在
 */
- (void)setupPath;

// TODO: 带有返回值的操作, 可添加 Block 操作方法, 在异步队列中执行
#pragma mark - Operation
/**
 获取已有任务

 @param url 下载地址
 @return 任务实例
 */
- (nullable FKTask *)acquire:(NSString *)url;

/**
 根据标签获取任务组

 @param tag 标签
 @return 任务组, 可能为空数组
 */
- (NSArray<FKTask *> *)acquireWithTag:(NSString *)tag;

/**
 通过数组批量添加任务, 元素限定: NSString, NSURL, NSDictionary, NSMutableDictionary
 可接受多维数组, 但元素限定不变
 
 @param array 数组
 */
- (void)addTasksWithArray:(NSArray *)array;
- (void)addTasksWithArray:(NSArray *)array added:(FKVoidDone)added;

/**
 通过数组批量添加任务, 元素限定: NSString, NSURL, NSDictionary, NSMutableDictionary
 可接受多维数组, 但元素限定不变

 @param array 数组
 @param tag 标签
 */
- (void)addTasksWithArray:(NSArray *)array tag:(nullable NSString *)tag;
- (void)addTasksWithArray:(NSArray *)array tag:(nullable NSString *)tag added:(FKVoidDone)added;;

/**
 开始任务, 如果下载链接对应的任务不存在, 则返回的 task 为 nil
 任务状态变动为 TaskStatusNone -> TaskStatusPrepare -> TaskStatusExecuting

 @param url 下载地址
 */
- (void)start:(NSString *)url;
- (void)startWithAll;
- (void)startWithTag:(NSString *)tag;

/**
 取消任务

 @param url 下载链接
 */
- (void)cancel:(NSString *)url;
- (void)cancelWithAll;
- (void)cancelWithTag:(NSString *)tag;

/**
 暂停任务

 @param url 下载链接
 */
- (void)suspend:(NSString *)url;
- (void)suspendWithAll;
- (void)suspendWithTag:(NSString *)tag;

/**
 恢复任务

 @param url 下载链接
 */
- (void)resume:(NSString *)url;
- (void)resumeWithAll;
- (void)resumeWithTag:(NSString *)tag;

/**
 移除任务

 @param url 下载链接
 */
- (void)remove:(NSString *)url;
- (void)removeWithAll;
- (void)removeWithTag:(NSString *)tag;

/**
 更新任务的下载链接

 @param expire 已过期地址
 @param url 替换地址
 */
- (void)update:(NSString *)expire to:(NSString *)url UNAVAILABLE_ATTRIBUTE;


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

NS_ASSUME_NONNULL_END
