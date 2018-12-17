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

@property (nonatomic, strong) dispatch_source_t groupTimer;

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
                               FKTaskInfoTags: @[@"group_task_01"] }];
        } else {
            [tasks addObject:@{FKTaskInfoURL: url,
                               FKTaskInfoTags: @[@"group_task_02"]}];
        }
    }];
    /* 直接使用 url 数组添加任务
     [[FKDownloadManager manager] addTasksWithArray:self.urls tag:@"group_task_01"];
     */
    /** 当一次性添加任务过多时(>1000)会造成主线程卡顿, 可以将添加方法放入子线程, 然后使用 [FKDownloadManager manager].addedBlock 监听添加完成事件
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[FKDownloadManager manager] addTasksWithArray:tasks.copy];
     });
    */
    [[FKDownloadManager manager] addTasksWithArray:tasks.copy];
    
    self.totalProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.view addSubview:self.totalProgressView];
    __weak typeof(self) weak = self;
    [FKDownloadManager manager].progressBlock = ^(NSProgress * _Nonnull progress) {
        __strong typeof(weak) strong = weak;
        dispatch_async(dispatch_get_main_queue(), ^{
            strong.totalProgressView.progress = progress.fractionCompleted;
        });
    };
    
    self.groupTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [FKDownloadManager manager].timerQueue);
    dispatch_source_set_timer(self.groupTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.groupTimer, ^{
        [self groupProgressChange];
    });
    dispatch_resume(self.groupTimer);
    
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
    
    /** 监听添加任务组完成事件
    [FKDownloadManager manager].addedBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weak) strong = weak;
            [strong.listView reloadData];
        });
    };
     */
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_source_cancel(self.groupTimer);
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

- (void)groupProgressChange {
    // 注意: 当任务过多时(>1000), 频繁调用控制台打印语句会造成 CPU 占用过高(>110%), 请直接使用进度值
    [[[FKDownloadManager manager] acquireWithTag:@"group_task_01"] groupProgress:^(double progress) {
        FKLog(@"group_task_01 progress: %.6f", progress);
    }];
    [[[FKDownloadManager manager] acquireWithTag:@"group_task_02"] groupProgress:^(double progress) {
        FKLog(@"group_task_02 progress: %.6f", progress);
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
        // 可以将测试数量增大, 如 500, 1000, 5000...
        NSUInteger count = 1;
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:count];
        
        [urls addObjectsFromArray:@[@"http://m4.pc6.com/cjh3/deliver259.dmg",
                                    @"http://m4.pc6.com/cjh3/LogMeInInstaller7009.zip",
                                    @"http://m4.pc6.com/cjh3/VicomsoftFTPClient.dmg",
                                    @"http://m5.pc6.com/xuh5/hype363.zip",
                                    @"http://dl1sw.baidu.com/client/20150922/Xcode_7.1_beta.dmg"]];
        
        for (int i = 0; i < count; i ++) {
            [urls addObject:[NSString stringWithFormat:@"http://m4.pc6.com/cjh3/Remotix.dmg?p=%d", i]];
        }
        _urls = [NSArray arrayWithArray:urls];
    }
    return _urls;
}

@end
