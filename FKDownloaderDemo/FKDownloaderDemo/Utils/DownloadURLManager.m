//
//  DownloadURLManager.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import "DownloadURLManager.h"

@interface DownloadURLManager ()

@property (nonatomic, strong) NSString *archivePath;
@property (nonatomic, strong) NSArray<InfoModel *> *infoModels;

@end

@implementation DownloadURLManager

+ (instancetype)manager {
    static DownloadURLManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DownloadURLManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.archivePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"data.db"];
    }
    return self;
}

- (void)loadData {
    self.infoModels = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archivePath];
}

- (void)saveInfo:(InfoModel *)info {
    if ([self existInfo:info]) { return; }
    self.infoModels = [self.infoModels arrayByAddingObject:info];
    [NSKeyedArchiver archiveRootObject:self.infoModels toFile:self.archivePath];
}

- (void)deleteInfo:(InfoModel *)info {
    if ([self.infoModels containsObject:info]) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.infoModels];
        [temp removeObject:info];
        self.infoModels = [NSArray arrayWithArray:temp];
        [NSKeyedArchiver archiveRootObject:self.infoModels toFile:self.archivePath];
    }
}

- (BOOL)existInfo:(InfoModel *)info {
    __block BOOL isExist = NO;
    [self.infoModels enumerateObjectsUsingBlock:^(InfoModel *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.url isEqualToString:info.url]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    return isExist;
}


#pragma mark - Getter/Setter
- (NSArray<InfoModel *> *)infoModels {
    if (!_infoModels) {
        _infoModels = [NSArray array];
    }
    return _infoModels;
}

@end
