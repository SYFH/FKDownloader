//
//  FKDownloaderTests.m
//  FKDownloaderTests
//
//  Created by norld on 2020/1/5.
//  Copyright © 2020 norld. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FKCoder.h"

@interface FKDownloaderTests : XCTestCase

@end

@implementation FKDownloaderTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCodingURL {
    NSString *URL = @"https://www.百度.com/◆/あい/🀆🀄︎🀅/家/🏠?ch=👌🍺&name=你好啊#第一章";
    NSString *contrast = @"https://www.%E7%99%BE%E5%BA%A6.com/%E2%97%86/%E3%81%82%E3%81%84/%F0%9F%80%86%F0%9F%80%84%EF%B8%8E%F0%9F%80%85/%E5%AE%B6/%F0%9F%8F%A0?ch=%F0%9F%91%8C%F0%9F%8D%BA&name=%E4%BD%A0%E5%A5%BD%E5%95%8A#%E7%AC%AC%E4%B8%80%E7%AB%A0";
    
    NSString *encodeURL = [FKCoder encode:URL];
    NSString *decodeURL = [FKCoder decode:contrast];
    
    XCTAssertTrue([encodeURL isEqualToString:contrast]);
    XCTAssertTrue([URL isEqualToString:decodeURL]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
