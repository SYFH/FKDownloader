//
//  FKConfigure.h
//  FKDownloader
//
//  Created by Norld on 2018/11/1.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^handler)(void);

@interface FKConfigure : NSObject

@property (nonatomic, assign) BOOL isBackgroudExecute;
@property (nonatomic, assign) BOOL isAutoStart;
@property (nonatomic, assign) BOOL isAutoClearTask;
@property (nonatomic, assign) NSInteger maximumExecutionTask;
@property (nonatomic, strong) NSString  *rootPath;
@property (nonatomic, strong) NSString  *savePath;
@property (nonatomic, strong) NSString  *resumePath;
@property (nonatomic, strong) NSString  *restorePath;
@property (nonatomic, copy  ) handler   backgroundHandler;
@property (nonatomic, assign) NSInteger timeoutInterval;
@property (nonatomic, strong) NSString  *sessionIdentifier;

+ (instancetype)defaultConfigure;

@end
