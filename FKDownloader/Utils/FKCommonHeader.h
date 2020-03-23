//
//  FKCommonHeader.h
//  FKDownloader
//
//  Created by norld on 2020/1/4.
//  Copyright © 2020 norld. All rights reserved.
//

#ifndef FKCommonHeader_h
#define FKCommonHeader_h

/// 任务状态
typedef NS_ENUM(NSInteger, FKState) {
    FKStateUnknown  = -1,// 未知
    FKStatePrepare  = 0, // 准备
    FKStateIdel     = 1, // 等待
    FKStateAction   = 2, // 执行
    FKStateSuspend  = 3, // 暂停
    FKStateCancel   = 4, // 取消
    FKStateError    = 5, // 错误
    FKStateComplete = 6, // 完成
};


// 下载类型
typedef NS_ENUM(NSInteger, FKDownloadType) {
    FKDownloadTypeBackground = 0,   // 后台下载
    FKDownloadTypeForeground,       // 前台下载
};

#endif /* FKCommonHeader_h */
