//
//  DownloadManageController.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import "DownloadManageController.h"

#import <Masonry/Masonry.h>
#import <FKDownloader/FKDownloader.h>

#import "DownloadURLManager.h"
#import "DownloadInfoCell.h"

@interface DownloadManageController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, assign, getter=isAllSuspended) BOOL allSuspended;

@end

@implementation DownloadManageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"下载管理";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.listView registerClass:[DownloadInfoCell class] forCellReuseIdentifier:NSStringFromClass([DownloadInfoCell class])];
    self.listView.tableFooterView = [UIView new];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    [self.view addSubview:self.listView];
    
    self.allSuspended = YES;
    [self settingRightItem];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
}

- (void)settingRightItem {
    if (self.isAllSuspended) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidTap:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全部暂停" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemDidTap:)];
    }
}

- (void)rightItemDidTap:(UIBarButtonItem *)sender {
    if (self.isAllSuspended) {
        [FKDownloader resumeAllTask];
    } else {
        [FKDownloader suspendAllTask];
    }
    
    self.allSuspended = !self.allSuspended;
    [self settingRightItem];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DownloadURLManager manager].infoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DownloadInfoCell class]) forIndexPath:indexPath];
    InfoModel *infoModel = [[DownloadURLManager manager].infoModels objectAtIndex:indexPath.row];
    cell.url = infoModel.url;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InfoModel *infoModel = [[DownloadURLManager manager].infoModels objectAtIndex:indexPath.row];
    [FKControl cancelRequestWithURL:infoModel.url];
    [FKControl trashRequestWithURL:infoModel.url];
    [[DownloadURLManager manager] deleteInfo:infoModel];
    [tableView reloadData];
}


#pragma mark - Getter/Setter
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _listView;
}

@end
