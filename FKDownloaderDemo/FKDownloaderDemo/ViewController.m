//
//  ViewController.m
//  FKDownloaderDemo
//
//  Created by norld on 2019/12/28.
//  Copyright © 2019 norld. All rights reserved.
//

#import "ViewController.h"

#import "DownloadURLManager.h"
#import "ResourceListController.h"
#import "DownloadManageController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[DownloadURLManager manager] loadData];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
}

- (IBAction)resourceListDidTap:(UIButton *)sender {
    ResourceListController *resourceListController = [[ResourceListController alloc] init];
    [self.navigationController pushViewController:resourceListController animated:YES];
}

- (IBAction)downloadManageDidTap:(UIButton *)sender {
    DownloadManageController *downloadManageController = [[DownloadManageController alloc] init];
    [self.navigationController pushViewController:downloadManageController animated:YES];
}

- (IBAction)exitDidTap:(UIButton *)sender {
    exit(0);
}

@end
