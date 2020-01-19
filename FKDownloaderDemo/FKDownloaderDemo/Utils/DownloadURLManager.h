//
//  DownloadURLManager.h
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadURLManager : NSObject

@property (nonatomic, strong, readonly) NSArray<InfoModel *> *infoModels;

+ (instancetype)manager;

- (void)loadData;

- (void)saveInfo:(InfoModel *)info;

- (void)deleteInfo:(InfoModel *)info;

@end

NS_ASSUME_NONNULL_END
