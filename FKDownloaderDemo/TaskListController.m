//
//  TaskListController.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/10.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "TaskListController.h"
#import "FKDownloader.h"
#import "TaskViewCell.h"

@interface TaskListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSString *> *urls;
@property (nonatomic, strong) UITableView *listView;

@end

@implementation TaskListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.urls forEach:^(NSString *url) {
        [[FKDownloadManager manager] add:url];
    }];
    
    self.listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.listView registerClass:[TaskViewCell class] forCellReuseIdentifier:NSStringFromClass([TaskViewCell class])];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.listView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.listView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style: UIBarButtonItemStyleDone target:self action:@selector(rightDidTap:)];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.listView.frame = self.view.bounds;
}

- (void)dealloc {
    NSLog(@"下载列表释放");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightDidTap:(UIBarButtonItem *)sender {
    [[FKDownloadManager manager].tasks forEach:^(FKTask *task) {
        [[FKDownloadManager manager] start:task.url];
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.urls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TaskViewCell class]) forIndexPath:indexPath];
    cell.url = self.urls[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Getter/Setter
- (NSArray<NSString *> *)urls {
    return @[@"http://m4.pc6.com/cjh3/Remotix.dmg",
             @"http://m4.pc6.com/cjh3/deliver259.dmg",
             @"http://m4.pc6.com/cjh3/LogMeInInstaller7009.zip",
             @"http://m4.pc6.com/cjh3/VicomsoftFTPClient.dmg",
             @"http://dl1sw.baidu.com/client/20150922/Xcode_7.1_beta.dmg",
             @"http://m5.pc6.com/xuh5/hype363.zip"];
}

@end
