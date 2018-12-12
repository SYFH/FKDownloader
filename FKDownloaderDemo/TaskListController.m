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

@property (nonatomic, strong) UIProgressView *totalProgressView;
@property (nonatomic, strong) NSArray<NSString *> *urls;
@property (nonatomic, strong) UITableView *listView;

@end

@implementation TaskListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:self.urls.count];
    [self.urls forEach:^(NSString *url, NSUInteger idx) {
        if (idx == 0) {
            [tasks addObject:@{FKTaskInfoURL: url,
                               FKTaskInfoFileName: @"123",
                               FKTaskInfoVerificationType: @(VerifyTypeMD5),
                               FKTaskInfoVerification: @"5f75fe52c15566a12b012db21808ad8c",
                               FKTaskInfoRequestHeader: @{},
                               FKTaskInfoTags: @[@"group_task_01"],
                               FKTaskInfoResumeSavePath: [FKDownloadManager manager].configure.resumeSavePath,
                               FKTaskInfoSavePath: [FKDownloadManager manager].configure.savePath}];
        } else {
            [tasks addObject:@{FKTaskInfoURL: url,
                               FKTaskInfoTags: @[@"group_task_02"]}];
        }
    }];
    /* 直接使用 url 数组添加任务
     [[FKDownloadManager manager] addTaskWithArray:self.urls];
     */
    [[FKDownloadManager manager] addTaskWithArray:tasks.copy];
    
    self.totalProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:self.totalProgressView];
    __weak typeof(self) weak = self;
    [FKDownloadManager manager].progressBlock = ^(NSProgress * _Nonnull progress) {
        __strong typeof(weak) strong = weak;
        FKLog(@"%@", progress);
        strong.totalProgressView.progress = progress.fractionCompleted;
        [[[FKDownloadManager manager] acquireWithTag:@"group_task_01"] groupProgress:^(NSProgress * _Nonnull progress) {
            FKLog(@"group_task_01 progress: %.4f", progress.fractionCompleted);
        }];
        [[[FKDownloadManager manager] acquireWithTag:@"group_task_02"] groupProgress:^(NSProgress * _Nonnull progress) {
            FKLog(@"group_task_02 progress: %.4f", progress.fractionCompleted);
        }];
    };
    
    self.listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.listView registerClass:[TaskViewCell class] forCellReuseIdentifier:NSStringFromClass([TaskViewCell class])];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.listView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.listView];
    
    UIBarButtonItem *startItem = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style: UIBarButtonItemStyleDone target:self action:@selector(startDidTap:)];
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithTitle:@"全部停止" style: UIBarButtonItemStyleDone target:self action:@selector(stopDidTap:)];
    UIBarButtonItem *suspendItem = [[UIBarButtonItem alloc] initWithTitle:@"全部暂停" style: UIBarButtonItemStyleDone target:self action:@selector(suspendDidTap:)];
    self.navigationItem.rightBarButtonItems = @[ startItem, stopItem, suspendItem ];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize size = self.view.frame.size;
    self.totalProgressView.frame = CGRectMake(0, 64, size.width, 4);
    self.listView.frame = CGRectMake(0, 68, size.width, size.height - 68);
}

- (void)dealloc {
    NSLog(@"下载列表释放");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startDidTap:(UIBarButtonItem *)sender {
    [[FKDownloadManager manager].taskHub.allTask orderEach:^(FKTask *task, NSUInteger idx) {
        [[FKDownloadManager manager] start:task.url];
    }];
    /*
    [[FKDownloadManager manager].taskHub.allTask disorderEach:^(FKTask *task, NSUInteger idx) {
        [[FKDownloadManager manager] start:task.url];
    }];
     */
}

- (void)stopDidTap:(UIBarButtonItem *)sender {
    [[FKDownloadManager manager].taskHub.allTask forEach:^(FKTask *task, NSUInteger idx) {
        [[FKDownloadManager manager] cancel:task.url];
    }];
}

- (void)suspendDidTap:(UIBarButtonItem *)sender {
    [[FKDownloadManager manager].taskHub.allTask forEach:^(FKTask *task, NSUInteger idx) {
        [[FKDownloadManager manager] suspend:task.url];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *url = self.urls[indexPath.row];
    [[FKDownloadManager manager] remove:url];
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.urls];
    [temp removeObjectAtIndex:indexPath.row];
    self.urls = [NSArray arrayWithArray:temp];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - Getter/Setter
- (NSArray<NSString *> *)urls {
    if (!_urls) {
        _urls = @[@"http://m4.pc6.com/cjh3/Remotix.dmg",
                  @"http://m4.pc6.com/cjh3/deliver259.dmg",
                  @"http://m4.pc6.com/cjh3/LogMeInInstaller7009.zip",
                  @"http://m4.pc6.com/cjh3/VicomsoftFTPClient.dmg",
                  @"http://m5.pc6.com/xuh5/hype363.zip",
                  @"http://dl1sw.baidu.com/client/20150922/Xcode_7.1_beta.dmg",];
    }
    return _urls;
}

@end
