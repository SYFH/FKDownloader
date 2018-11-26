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

/**
 是否设置为后台下载. 默认为 Yes
 */
@property (nonatomic, assign) BOOL isBackgroudExecute;

/**
 是否自动开始, 当载入本地归档任务时起效. 默认为 No
 */
@property (nonatomic, assign) BOOL isAutoStart;

/**
 是否自动清理, 当任务失败或完成时起效. 默认为 No
 */
@property (nonatomic, assign) BOOL isAutoClearTask;

/**
 是否进行文件校验, 默认为 No
 */
@property (nonatomic, assign) BOOL isFileChecksum;

/**
 是否允许蜂窝网络进行下载, 默认为 NO
 */
@property (nonatomic, assign) BOOL isAllowCellular;

/**
 最大并行任务数量. 默认为 3
 */
@property (nonatomic, assign) NSInteger maximumExecutionTask;

/**
 FKDownloadManager 的根目录. 默认为 Library/Caches/com.fk.downloader/
 */
@property (nonatomic, strong) NSString  *rootPath;

/**
 文件保存路径. 默认为 Library/Caches/com.fk.downloader/file/
 */
@property (nonatomic, strong) NSString  *savePath;

/**
 任务恢复数据保存路径. 默认为 Library/Caches/com.fk.downloader/resume/
 */
@property (nonatomic, strong) NSString  *resumePath;

/**
 持久化任务文档路径. 默认为 Library/Caches/com.fk.downloader/downloader.restore
 */
@property (nonatomic, strong) NSString  *restorePath;

/**
 后台下载句柄
 */
@property (nonatomic, copy  , nullable) handler   backgroundHandler;

/**
 任务超时时间. 默认为 30s
 */
@property (nonatomic, assign) NSInteger timeoutInterval;

/**
 Session 标识. 默认为 com.fk.downloader
 */
@property (nonatomic, strong) NSString  *sessionIdentifier;

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
