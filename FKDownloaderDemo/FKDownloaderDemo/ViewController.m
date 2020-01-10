//
//  ViewController.m
//  FKDownloaderDemo
//
//  Created by norld on 2019/12/28.
//  Copyright © 2019 norld. All rights reserved.
//

#import "ViewController.h"
#import <FKDownloader/FKDownloader.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"begin");
    [FKConfigure configure].maxAction = 3;
    [[FKConfigure configure] take];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *url = @"https://images.unsplash.com/photo-1556742095-adaf2611556c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9";
    FKBuilder *builder = [FKBuilder buildWithURL:url];
    [builder prepare];
    
    [FKMessager addMessagerWithURLs:@[url] barrel:@"test"];
    [FKMessager messagerWithBarrel:@"test" info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive) {
        printf("%lld, %lld\n", countOfBytesReceived, countOfBytesExpectedToReceive);
    }];
}

@end
