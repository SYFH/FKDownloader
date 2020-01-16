//
//  ViewController.m
//  FKDownloaderDemo
//
//  Created by norld on 2019/12/28.
//  Copyright © 2019 norld. All rights reserved.
//

#import "ViewController.h"
#import <FKDownloader/FKDownloader.h>

#import "CustomRequestMiddleware.h"
#import "CustomResponseMiddleware.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *downloadURL;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"begin");
    self.downloadURL = @"https://github.com/ET-Team/EnigTech2/releases/download/v1.2.12/EnigTech2-1.2.12.zip";
    
    [[FKConfigure configure] take];
    
    [[FKMiddleware shared] registeRequestMiddleware:[CustomRequestMiddleware new]];
    [[FKMiddleware shared] registeResponseMiddleware:[CustomResponseMiddleware new]];
}

- (IBAction)prepare:(UIButton *)sender {
    FKBuilder *builder = [FKBuilder buildWithURL:self.downloadURL];
    [builder prepare];
    
    __weak typeof(self) weak = self;
    [FKMessager messagerWithURL:self.downloadURL info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive, FKState state) {
        __strong typeof(weak) self = weak;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.stateLabel.text = [NSString stringWithFormat:@"已下载: %lld\n总大小: %lld\n状态: %@", countOfBytesReceived, countOfBytesExpectedToReceive, [self state:state]];
        });
    }];
}

- (IBAction)action:(UIButton *)sender {
    [FKControl actionRequestWithURL:self.downloadURL];
}

- (IBAction)suspend:(UIButton *)sender {
    [FKControl suspendRequestWithURL:self.downloadURL];
}

- (IBAction)resume:(UIButton *)sender {
    [FKControl resumeRequestWithURL:self.downloadURL];
}

- (IBAction)cancel:(UIButton *)sender {
    [FKControl cancelRequestWithURL:self.downloadURL];
}

- (NSString *)state:(FKState)state {
    NSString *des = @"";
    switch (state) {
        case FKStatePrepare:
            des = @"预处理";
            break;
        case FKStateIdel:
            des = @"等待";
            break;
        case FKStateAction:
            des = @"下载中";
            break;
        case FKStateSuspend:
            des = @"暂停中";
            break;
        case FKStateCancel:
            des = @"已取消";
            break;
        case FKStateError:
            des = @"错误";
            break;
        case FKStateComplete:
            des = @"完成";
            break;
    }
    return des;
}

@end
