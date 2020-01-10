//
//  FKObserver.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKObserver.h"

#import "FKObserverModel.h"
#import "FKLogger.h"

@interface FKObserver ()

/// 请求信息
/// 结构: {"SHA1(Request.URL)": Observer.Model}
@property (nonatomic, strong) NSMapTable<NSString *, FKObserverModel *> *infoMap;

@end

@implementation FKObserver

+ (instancetype)observer {
    static FKObserver *instance = nil;
    static dispatch_once_t FKObserverOnceToken;
    dispatch_once(&FKObserverOnceToken, ^{
        instance = [[FKObserver alloc] init];
    });
    return instance;
}

- (void)observerDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [downloadTask addObserver:self
                   forKeyPath:@"countOfBytesReceived"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 已接收字节
    [FKLogger info:@"监听下载任务属性: countOfBytesReceived"];
    
    [downloadTask addObserver:self
                   forKeyPath:@"countOfBytesExpectedToReceive"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 总大小
    [FKLogger info:@"监听下载任务属性: countOfBytesExpectedToReceive"];
}

- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [downloadTask removeObserver:self
                      forKeyPath:@"countOfBytesReceived"
                         context:nil];
    [FKLogger info:@"移除监听下载任务属性: countOfBytesReceived"];
    
    [downloadTask removeObserver:self
                      forKeyPath:@"countOfBytesExpectedToReceive"
                         context:nil];
    [FKLogger info:@"移除监听下载任务属性: countOfBytesExpectedToReceive"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSURLSessionDownloadTask *downloadTask = object;
    
    if ([keyPath isEqualToString:@"countOfBytesReceived"]) {
        NSLog(@"%lld", downloadTask.countOfBytesReceived);
    }
    
    if ([keyPath isEqualToString:@"countOfBytesExpectedToReceive"]) {
        NSLog(@"%lld", downloadTask.countOfBytesExpectedToReceive);
    }
}


#pragma mark - Getter/Setter

@end
