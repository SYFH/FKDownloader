//
//  FKCommonHeader.h
//  FKDownloader
//
//  Created by norld on 2020/1/4.
//  Copyright © 2020 norld. All rights reserved.
//

#ifndef FKCommonHeader_h
#define FKCommonHeader_h

typedef NS_ENUM(NSInteger, FKState) {
    FKStatePrepare  = 0, // 准备
    FKStateIdel     = 1, // 等待
    FKStateAction   = 2, // 执行
    FKStateSuspend  = 3, // 暂停
    FKStateCancel   = 4, // 取消
    FKStateError    = 5, // 错误
};

#endif /* FKCommonHeader_h */
