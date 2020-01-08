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
    FKBuilder *builder = [FKBuilder buildWithURL:@"https://images.unsplash.com/photo-1556742095-adaf2611556c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9"];
    [builder prepare];
}

@end
