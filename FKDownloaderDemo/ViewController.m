//
//  ViewController.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/2.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "ViewController.h"
#import "FKDownloader.h"

@interface ViewController ()<FKTaskDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 进入界面后初始化代理, 以防止重启 app 后无法获取进度与状态
    [[FKDownloadManager manager] acquire:@"http://dl1sw.baidu.com/client/20150922/Xcode_7.1_beta.dmg"].delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSString *url = @"http://dl1sw.baidu.com/client/20150922/Xcode_7.1_beta.dmg";
    FKConfigure *config = [FKConfigure defaultConfigure];
    config.isBackgroudExecute = YES;
    config.isAutoClearTask = YES;
    [FKDownloadManager manager].configure = config;
    
    if ([[FKDownloadManager manager] acquire:url].status == TaskStatusExecuting) {
        [[FKDownloadManager manager] suspend:url];
        return;
    }
    
    [[FKDownloadManager manager] start:url].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloader:(FKDownloadManager *)downloader willExecuteTask:(FKTask *)task {
    NSLog(@"准备执行");
}

- (void)downloader:(FKDownloadManager *)downloader didExecuteTask:(FKTask *)task {
    NSLog(@"开始执行");
}

- (void)downloader:(FKDownloadManager *)downloader progressingTask:(FKTask *)task {
    NSLog(@"进度: %.6f", task.progress.fractionCompleted);
}

- (void)downloader:(FKDownloadManager *)downloader didFinishTask:(FKTask *)task {
    NSLog(@"执行完成");
}

- (void)downloader:(FKDownloadManager *)downloader willSuspendTask:(FKTask *)task {
    NSLog(@"准备暂停");
}

- (void)downloader:(FKDownloadManager *)downloader didSuspendTask:(FKTask *)task {
    NSLog(@"暂停完成");
}

- (void)downloader:(FKDownloadManager *)downloader willCanceldTask:(FKTask *)task {
    NSLog(@"准备停止");
}

- (void)downloader:(FKDownloadManager *)downloader didCancelldTask:(FKTask *)task {
    NSLog(@"停止完成");
}

- (void)downloader:(FKDownloadManager *)downloader errorTask:(FKTask *)task {
    NSLog(@"执行出错: %@", task.error);
}



@end
