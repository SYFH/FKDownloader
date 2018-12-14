//
//  FKConfigure.h
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^handler)(void);

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Configure)
@interface FKConfigure : NSObject
// TODO: 可选自行保护 tmp 文件
/**
 是否设置为后台下载. 默认为 Yes
 */
@property (nonatomic, assign, getter=isBackgroudExecute) BOOL backgroudExecute;

/**
 是否自动开始, 当载入本地归档任务时起效. 默认为 No
 此值只作用于暂停中归档任务
 */
@property (nonatomic, assign, getter=isAutoStart) BOOL autoStart;

/**
 是否自动清理, 当任务失败或完成时起效. 默认为 No
 注意, 此值仅清除 FKTask, 相关 UI 操作请自行更改
 */
@property (nonatomic, assign, getter=isAutoClearTask) BOOL autoClearTask;

/**
 是否进行文件校验, 默认为 No
 注意, 大文件(1GB~)计算 Hash 值会严重消耗 CPU, 请谨慎开启
 */
@property (nonatomic, assign, getter=isFileChecksum) BOOL fileChecksum;

/**
 是否允许蜂窝网络进行下载, 默认为 NO
 注意, 为了保证上层的 FKTask 能保证此选项可用, 根 NSURLSeesion 初始化时会直接标记可使用蜂窝网络, 所以此值仅
 作用于上层的 FKTask 是否可以使用蜂窝网络, 不代表 NSURLSessionDownloadTask 是否可以使用蜂窝网络
 */
@property (nonatomic, assign, getter=isAllowCellular) BOOL allowCellular;

/**
 是否自动归档任务, 默认为 Yes
 注意, 一旦确定是否开启, 则不要轻易变更, 否则归档任务会和手动添加任务起冲突, 如 `全部开始` 操作, 会造成 UI 上
 显示的任务为等待中, 而下载中任务为非 UI 显示的归档任务.
 可以根据 FKTask.isCodingAdd 判断, 也可直接清除 restorePath, 但可能会出现其他一些问题
 */
@property (nonatomic, assign, getter=isAutoCoding) BOOL autoCoding;

/**
 是否在删除已完成任务时删除原文件, 默认为 No
 注意: 该操作属于破坏性操作, 请小心操作, 如有必要, 可以手动使用 `-[FKTask filePath]` 获取文件保存路径后自行删除
 */
@property (nonatomic, assign, getter=isDeleteFinishFile) BOOL deleteFinishFile;

/**
 是否计算任务的下载速度和预计时间, 默认为 Yes
 */
@property (nonatomic, assign, getter=isCalculateSpeedWithEstimated) BOOL calculateSpeedWithEstimated;

/**
 最大并行任务数量. 默认为 3, 最大为 3
 最大并行数量受限于 NSURLSession 的 HTTPMaximumConnectionsPerHost 属性, 系统默认 macOS 为 6, iOS 为 4
 */
@property (nonatomic, assign) NSInteger maximumExecutionTask;

/**
 文件保存路径. 默认为 Library/Caches/com.fk.downloader/file/
 */
@property (nonatomic, strong) NSString *savePath;

/**
 任务恢复数据保存路径. 默认为 Library/Caches/com.fk.downloader/resume/
 */
@property (nonatomic, strong) NSString *resumeSavePath;

/**
 持久化任务文档路径. 默认为 Library/Caches/com.fk.downloader/downloader.restore
 */
@property (nonatomic, strong) NSString *restoreFilePath;

/**
 后台下载句柄
 */
@property (nonatomic, copy  , nullable) handler backgroundHandler;

/**
 任务超时时间. 默认为 30s
 */
@property (nonatomic, assign) NSInteger timeoutInterval;

/**
 Session 标识. 默认为 com.fk.downloader
 */
@property (nonatomic, strong) NSString *sessionIdentifier;

/**
 任务速度/预计完成时间更新间隔, 默认为 1s, 其值必须大于 0
 */
@property (nonatomic, assign) NSTimeInterval speedRefreshInterval;

/**
 默认配置

 @return 默认配置实例
 */
+ (nonnull instancetype)defaultConfigure;

@end

NS_ASSUME_NONNULL_END
