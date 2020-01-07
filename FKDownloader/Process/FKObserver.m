//
//  FKObserver.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKObserver.h"


@interface FKObserver ()

/// 请求信息
/// 结构: {"SHA1(Request.URL)":{"progress":0, "state":0}}
@property (nonatomic, strong) NSMapTable *infoMap;

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
    [downloadTask addObserver:[FKObserver observer]
                   forKeyPath:@"countOfBytesReceived"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 已接收字节
    
    [downloadTask addObserver:[FKObserver observer]
                   forKeyPath:@"countOfBytesExpectedToReceive"
                      options:NSKeyValueObservingOptionNew
                      context:nil]; // 总大小
}

- (void)removeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    [downloadTask removeObserver:[FKObserver observer]
                      forKeyPath:@"countOfBytesReceived"
                         context:nil];
    
    [downloadTask removeObserver:[FKObserver observer]
                      forKeyPath:@"countOfBytesExpectedToReceive"
                         context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSURLSessionDownloadTask *downloadTask = object;
    NSString *requestID = downloadTask.taskDescription;
}


#pragma mark - Getter/Setter

@end
