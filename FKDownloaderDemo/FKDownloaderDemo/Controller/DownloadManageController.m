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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottomMargin);
    }];
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


#pragma mark - Getter/Setter
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _listView;
}

@end
