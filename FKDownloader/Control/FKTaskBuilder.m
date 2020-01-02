//
//  FKTasker.m
//  FKDownloader
//
//  Created by norld on 2019/12/31.
//  Copyright © 2019 norld. All rights reserved.
//

#import "FKTaskBuilder.h"

#import "NSURLSessionDownloadTask+FKCategory.h"

#import "FKSingleNumber.h"
#import "FKEngine.h"
#import "FKCache.h"

@interface FKTaskBuilder ()

@property (nonatomic, strong) NSArray<NSString *> *urls;
@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, strong) NSString *taskIdentifier;
@property (nonatomic, strong) NSArray<NSMutableURLRequest *> *requests;
@property (nonatomic, assign, getter=isPrepapred) BOOL prepapred;

@end

@implementation FKTaskBuilder

- (instancetype)initWithURLs:(NSArray<NSString *> *)urls header:(NSDictionary *)header {
    self = [super init];
    if (self) {
        self.urls = [NSArray arrayWithArray:urls];
        self.header = [NSDictionary dictionaryWithDictionary:header];
    }
    return self;
}

+ (instancetype)builderWithURLs:(NSArray<NSString *> *)urls header:(nonnull NSDictionary *)header {
    return [[self alloc] initWithURLs:urls header:header];
}

- (NSString *)taskID {
    return self.taskIdentifier;
}

- (void)prepare {
    if (self.prepapred) { return; }
    [[FKCache cache] addPrepareTaskID:self.taskID requests:self.requests];
    self.prepapred = YES;
}


#pragma mark - Getter/Setter
- (NSString *)taskIdentifier {
    @synchronized (self) {
        if (!_taskIdentifier) {
            NSTimeInterval date = [NSDate date].timeIntervalSince1970;
            unsigned long long singleNumber = [FKSingleNumber shared].number;
            _taskIdentifier = [NSString stringWithFormat:@"%.0f_%llu", date * 1000, singleNumber];
        }
        return _taskIdentifier;
    }
}

- (NSArray<NSMutableURLRequest *> *)downloadTasks {
    @synchronized (self) {
        if (self.urls.count == 0) { return [NSArray array]; }
        
        NSMutableArray<NSMutableURLRequest *> *temp = [NSMutableArray arrayWithCapacity:self.urls.count];
        for (NSString *url in self.urls) {
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            if (self.header.count > 0) {
                [self.header enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                    [request addValue:obj forHTTPHeaderField:key];
                }];
            }
            [temp addObject:request];
        }
        _requests = [NSArray arrayWithArray:temp];
        return _requests;
    }
}

@end
