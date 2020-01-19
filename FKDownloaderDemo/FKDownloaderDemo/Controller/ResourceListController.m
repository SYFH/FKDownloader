//
//  ResourceListController.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import "ResourceListController.h"

#import <Masonry/Masonry.h>

@interface ResourceListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) NSArray<NSString *> *urls;

@end

@implementation ResourceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"资源列表";
    
    [self.listView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Getter/Setter
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _listView;
}

- (NSArray<NSString *> *)urls {
    if (!_urls) {
        _urls = @[];
    }
    return _urls;
}

@end
