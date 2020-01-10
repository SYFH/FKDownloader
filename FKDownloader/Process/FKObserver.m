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

/// 信息回调
/// 结构: {"SHA1(Request.URL)": InfoBlock}
@property (nonatomic, strong) NSMapTable<NSString *, InfoBlock> *blockMap;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUInteger count = self.infoMap.count;
        count = self.blockMap.count;
    }
    return self;
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
    
    FKObserverModel *info = [[FKObserverModel alloc] init];
    info.requestID = downloadTask.taskDescription;
    info.countOfBytesReceived = 0;
    info.countOfBytesExpectedToReceive = 0;
    info.state = FKStateAction;
    [self.infoMap setObject:info forKey:downloadTask.taskDescription];
    [FKLogger info:@"添加监听缓存"];
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
    
    [self.infoMap removeObjectForKey:downloadTask.taskDescription];
    [self.blockMap removeObjectForKey:downloadTask.taskDescription];
    [FKLogger info:@"删除监听缓存"];
}

- (void)addBlock:(InfoBlock)block requestID:(NSString *)requestID {
    [self.blockMap setObject:block forKey:requestID];
    [FKLogger info:@"添加信息回调到监听缓存"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSURLSessionDownloadTask *downloadTask = object;
    NSString *requestID = downloadTask.taskDescription;
    FKObserverModel *info = [self.infoMap objectForKey:requestID];
    
    if ([keyPath isEqualToString:@"countOfBytesReceived"]) {
        info.countOfBytesReceived = downloadTask.countOfBytesReceived;
    }
    
    if ([keyPath isEqualToString:@"countOfBytesExpectedToReceive"]) {
        info.countOfBytesExpectedToReceive = downloadTask.countOfBytesExpectedToReceive;
    }
}

- (void)execRequestInfoBlock {
    for (NSString *requestID in self.blockMap) {
        InfoBlock block = [self.blockMap objectForKey:requestID];
        FKObserverModel *model = [self.infoMap objectForKey:requestID];
        block(model.countOfBytesReceived, model.countOfBytesExpectedToReceive, model.state);
    }
}


#pragma mark - Getter/Setter
- (NSMapTable<NSString *,FKObserverModel *> *)infoMap {
    if (!_infoMap) {
        _infoMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                         valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _infoMap;
}

- (NSMapTable<NSString *,InfoBlock> *)blockMap {
    if (!_blockMap) {
        _blockMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                          valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _blockMap;
}

@end
