//
//  FKDownloaderTests.m
//  FKDownloaderTests
//
//  Created by norld on 2020/1/5.
//  Copyright © 2020 norld. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSString+FKCategory.h"

#import "FKCoder.h"
#import "FKBuilder.h"
#import "FKCache.h"
#import "FKCacheModel.h"
#import "FKConfigure.h"
#import "FKMessager.h"
#import "FKControl.h"
#import "FKEngine.h"
#import "FKLogger.h"

#import "TestMiddleware.h"

@interface FKDownloaderTests : XCTestCase

@property (nonatomic, strong) TestMiddleware *middleware;
@property (nonatomic, assign) BOOL onceSuspend;

@end

@implementation FKDownloaderTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.middleware = [[TestMiddleware alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    // 清理请求产生的文件
    NSString *URL = @"https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2020.exe";
    [FKControl trashRequestWithURL:URL];
    
    URL = @"https://qd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk?r=1";
    [FKControl trashRequestWithURL:URL];
    
    URL = @"https://dl.softmgr.qq.com/original/Browser/QQBrowser_Setup_Qqpcmgr_10.5.3863.400.exe";
    [FKControl trashRequestWithURL:URL];
}

- (void)testCodingURL {
    NSString *URL = @"https://www.百度.com/◆/あい/🀆🀄︎🀅/家/🏠?ch=👌🍺&name=你好啊#第一章";
    NSString *contrast = @"https://www.%E7%99%BE%E5%BA%A6.com/%E2%97%86/%E3%81%82%E3%81%84/%F0%9F%80%86%F0%9F%80%84%EF%B8%8E%F0%9F%80%85/%E5%AE%B6/%F0%9F%8F%A0?ch=%F0%9F%91%8C%F0%9F%8D%BA&name=%E4%BD%A0%E5%A5%BD%E5%95%8A#%E7%AC%AC%E4%B8%80%E7%AB%A0";
    
    NSString *encodeURL = [FKCoder encode:URL];
    NSString *decodeURL = [FKCoder decode:contrast];
    
    XCTAssertTrue([encodeURL isEqualToString:contrast]);
    XCTAssertTrue([URL isEqualToString:decodeURL]);
}

- (void)testMiddleware {
    __weak typeof(self) weak = self;
    self.middleware.requestMiddlewareHandle = ^NSMutableURLRequest * _Nonnull(NSMutableURLRequest * _Nonnull request) {
        [FKLogger debug:@"自定义请求中间件被调用"];
        __strong typeof(weak) self = weak;
        XCTAssertTrue(YES);
        return request;
    };
    self.middleware.responseMiddlewareHandle = ^(FKResponse * _Nonnull response) {
        [FKLogger debug:@"自定义响应中间件被调用"];
        __strong typeof(weak) self = weak;
        XCTAssertTrue(YES);
    };
    
    [[FKMiddleware shared] registeRequestMiddleware:self.middleware];
    [[FKMiddleware shared] registeResponseMiddleware:self.middleware];
}

- (void)testTakeConfigture {
    // 无法输入附属
    [FKConfigure configure].maxAction = -1;
    XCTAssertTrue([FKConfigure configure].maxAction == 6);
    
    [FKConfigure configure].maxAction = 7;
    XCTAssertTrue([FKConfigure configure].maxAction == 6);
    
    [FKConfigure configure].maxAction = 3;
    XCTAssertTrue([FKConfigure configure].maxAction == 3);
    
    [[FKConfigure configure] takeSession];
    
    XCTAssertTrue([[FKEngine engine].backgroundSession.configuration.identifier isEqualToString:[FKConfigure configure].backgroundSessionIdentifier]);
}

- (void)testPrepareURL {
    NSString *URL = @"https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2020.exe";
    
    [[FKBuilder buildWithURL:URL] prepare];
    
    // 检查是否存在内存缓存
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:URL.SHA256];
    XCTAssertNotNil(info);
    
    // 检查请求是否生成
    XCTAssertNotNil(info.request);
    XCTAssertTrue([info.request.URL.absoluteString isEqualToString:URL]);
    
    // 检查信息是否正确
    XCTAssertTrue([info.requestID isEqualToString:URL.SHA256]);
    XCTAssertTrue([info.url isEqualToString:URL]);
}

- (void)testSimpleDownloadURL {
    NSString *URL = @"https://qd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk?r=1";
    
    [[FKConfigure configure] takeSession];
    [[FKConfigure configure] activateQueue];
    
    [[FKBuilder buildWithURL:URL] prepare];
    
    [FKMessager addMessagerWithURLs:@[URL] barrel:@"test"];
    [FKMessager messagerWithBarrel:@"test" info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive) {
        
    }];
    
    // 注意: Unit Test 在不依附于 App 时创建的 Background Session 是无效的
    // 错误信息: Code=4099 "The connection to service on pid 0 named com.apple.nsurlsessiond was invalidated from this process."
    // 相关信息请查看 [Testing Background Session Code](https://forums.developer.apple.com/thread/14855)
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testActivateDownloadURL"];
    [FKMessager messagerWithURL:URL info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive, FKState state, NSError * _Nullable error) {
        
        if (error) {
            // 直接停止测试
            [expectation fulfill];
        } else {
            if (countOfBytesExpectedToReceive > 0) {
                if (state != FKStateCancel) {
                    [FKControl cancelRequestWithURL:URL];
                } else {
                    // 取消下载后停止测试
                    [FKMessager removeMessagerBarrel:@"test"];
                    [expectation fulfill];
                }
            }
        }
    }];
    [self waitForExpectations:@[expectation]
                      timeout:[FKConfigure configure].templateBackgroundConfiguration.timeoutIntervalForRequest];
}

- (void)testControlDownloadURL {
    NSString *URL = @"https://dl.softmgr.qq.com/original/Browser/QQBrowser_Setup_Qqpcmgr_10.5.3863.400.exe";
    
    [[FKConfigure configure] takeSession];
    [[FKConfigure configure] activateQueue];
    
    [[FKBuilder buildWithURL:URL] prepare];
    
    [FKControl actionRequestWithURL:URL];
    FKState state = [FKControl stateWithURL:URL];
    XCTAssertTrue(state == FKStateIdel || state == FKStateAction || state == FKStatePrepare);
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testControlDownloadURL"];
    [FKMessager messagerWithURL:URL info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive, FKState state, NSError * _Nullable error) {
        
        switch (state) {
            case FKStatePrepare: {
                
            } break;
                
            case FKStateIdel: {
                
            } break;
                           
            case FKStateAction: {
                if (countOfBytesExpectedToReceive > 0 && self.onceSuspend == NO) {
                    [FKControl suspendRequestWithURL:URL];
                    self.onceSuspend = YES;
                    // 暂停后状态不会立即改变, 而是视断点续传数据返回情况改变
                }
                
                int64_t maxSize = 1000 * 1000 * 8; // 8 mb
                if (countOfBytesReceived > maxSize) {
                    [FKControl cancelRequestWithURL:URL];
                    FKState state = [FKControl stateWithURL:URL];
                    XCTAssertTrue(state == FKStateCancel);
                }
            } break;
                           
            case FKStateSuspend: {
                [FKControl resumeRequestWithURL:URL];
                FKState state = [FKControl stateWithURL:URL];
                XCTAssertTrue(state == FKStateAction);
            } break;
                           
            case FKStateCancel: {
                NSError *error = [FKControl errorWithURL:URL];
                [FKLogger debug:@"contrl test, download error: %@", error];
                
                // 最后取消时, 完成测试
                [expectation fulfill];
            } break;
                           
            case FKStateError: {
                
            } break;
                           
            case FKStateComplete: {
                
            } break;
        }
    }];
    [self waitForExpectations:@[expectation]
                      timeout:[FKConfigure configure].templateBackgroundConfiguration.timeoutIntervalForRequest];
}

@end
