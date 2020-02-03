//
//  FKDownloaderTests.m
//  FKDownloaderTests
//
//  Created by norld on 2020/1/5.
//  Copyright © 2020 norld. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreServices/CoreServices.h>

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
#import "FKFileManager.h"
#import "FKMIMEType.h"

#import "TestMiddleware.h"

@interface FKDownloaderTests : XCTestCase

@property (nonatomic, strong) TestMiddleware *middleware;

@end

@implementation FKDownloaderTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.middleware = [[TestMiddleware alloc] init];
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

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [FKControl cancelAllRequest];
}

- (void)testCodingURL {
    NSString *URL = @"https://www.百度.com/◆/あい/🀆🀄︎🀅/家/🏠?ch=👌🍺&name=你好啊#第一章";
    NSString *contrast = @"https://www.%E7%99%BE%E5%BA%A6.com/%E2%97%86/%E3%81%82%E3%81%84/%F0%9F%80%86%F0%9F%80%84%EF%B8%8E%F0%9F%80%85/%E5%AE%B6/%F0%9F%8F%A0?ch=%F0%9F%91%8C%F0%9F%8D%BA&name=%E4%BD%A0%E5%A5%BD%E5%95%8A#%E7%AC%AC%E4%B8%80%E7%AB%A0";
    
    NSString *encodeURL = [FKCoder encode:URL];
    NSString *decodeURL = [FKCoder decode:contrast];
    
    XCTAssertTrue([encodeURL isEqualToString:contrast]);
    XCTAssertTrue([URL isEqualToString:decodeURL]);
}

- (void)testMIMETypeConvertFileExtension {
    NSString *MIMEType = @"application/vnd.android.package-archive";
    CFStringRef mimeType = (__bridge CFStringRef)MIMEType;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    NSString *fileExtension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    XCTAssertNil(fileExtension);
    XCTAssertTrue([[FKMIMEType extensionWithMIMEType:MIMEType] isEqualToString:@"apk"]);
    
    MIMEType = @"application/octet-stream";
    mimeType = (__bridge CFStringRef)MIMEType;
    uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    fileExtension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    XCTAssertNil(fileExtension);
    XCTAssertTrue([[FKMIMEType extensionWithMIMEType:MIMEType] isEqualToString:@"bin"]);
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
    NSString *time = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970 * 1000];
    NSString *URL = [NSString stringWithFormat:@"https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2020.exe?d=%@", time];
    
    [[FKBuilder buildWithURL:URL] prepare];
    
    unsigned long long signleNumber = [[FKFileManager manager] loadSingleNumber];
    [FKLogger debug:@"%llu", signleNumber];
    
    NSString *requestFilePath = [[FKFileManager manager] requestFilePath:URL.SHA256 extension:@".rqi"];
    NSString *requestFileName = [NSString stringWithFormat:@"%@.rqi", URL.SHA256];
    XCTAssertTrue([requestFilePath hasSuffix:requestFileName]);
    
    // 检查是否存在内存缓存
    FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:URL.SHA256];
    XCTAssertNotNil(info);
    
    // 检查是否存在本地缓存
    FKCacheRequestModel *localInfo = [[FKFileManager manager] loadLocalRequestWithRequestID:URL.SHA256];
    XCTAssertNotNil(localInfo);
    
    // 检查请求是否生成
    XCTAssertNotNil(info.request);
    XCTAssertTrue([info.request.URL.absoluteString isEqualToString:URL]);
    
    // 检查信息是否正确
    XCTAssertTrue([info.requestID isEqualToString:URL.SHA256]);
    XCTAssertTrue([info.url isEqualToString:URL]);
    
    info.extension = @".exe";
    [[FKCache cache] updateRequestWithModel:info];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@%@", [FKFileManager manager].workFinder, URL.SHA256, URL.SHA256, info.extension];
    NSString *expectedFilePath = [[FKCache cache] requestExpectedFilePathWithRequestID:info.requestID];
    XCTAssertTrue([filePath isEqualToString:expectedFilePath]);
    
    // 重复预处理
    [[FKBuilder buildWithURL:URL] prepare];
    
    // 删除
    [FKControl trashRequestWithURL:URL];
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
                    [FKControl trashRequestWithURL:URL];
                    [expectation fulfill];
                }
            }
        }
    }];
    [self waitForExpectations:@[expectation]
                      timeout:[FKConfigure configure].templateBackgroundConfiguration.timeoutIntervalForRequest];
}

- (void)testDownloadURL {
    NSString *URL = @"https://wx2.sinaimg.cn/mw600/5c583da1gy1gbi07pq10ej20dw0eiwit.jpg";
    
    [[FKConfigure configure] takeSession];
    [[FKConfigure configure] activateQueue];
    
    [[FKBuilder buildWithURL:URL] prepare];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"testActivateDownloadURL"];
    [FKMessager messagerWithURL:URL info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive, FKState state, NSError * _Nullable error) {
        
        if (error) {
            // 直接停止测试
            [expectation fulfill];
        } else {
            if (state == FKStateComplete) {
                NSString *filePath = [[FKCache cache] requestExpectedFilePathWithRequestID:URL.SHA256];
                NSDictionary<NSFileAttributeKey, id> *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                unsigned long long fileSize = [[attributes objectForKey:NSFileSize] unsignedLongLongValue];
                
                FKCacheRequestModel *info = [[FKCache cache] requestWithRequestID:URL.SHA256];
                XCTAssertTrue([[FKFileManager manager] fileSizeWithPath:filePath] == fileSize);
                XCTAssertTrue(info.dataLength == fileSize);
                
                [FKControl trashRequestWithURL:URL];
                [expectation fulfill];
            }
        }
    }];
    [self waitForExpectations:@[expectation]
                      timeout:[FKConfigure configure].templateBackgroundConfiguration.timeoutIntervalForRequest];
}

- (void)testControlDownloadURL {
    __block BOOL onceSuspend = NO;
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
                int64_t maxSize = 1000 * 1000 * 6;
                if (countOfBytesExpectedToReceive > 0 && onceSuspend == NO) {
                    [FKControl suspendRequestWithURL:URL];
                    onceSuspend = YES;
                    // 暂停后状态不会立即改变, 而是视断点续传数据返回情况改变
                }
                else if (countOfBytesReceived > maxSize) {
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
                [FKControl trashRequestWithURL:URL];
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
