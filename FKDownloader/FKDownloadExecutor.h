//
//  FKDownloadExecutor.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FKDownloadManager;

@interface FKDownloadExecutor : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak  ) FKDownloadManager *manager;

@end
