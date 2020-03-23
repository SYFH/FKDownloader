//
//  ResourceListController.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import "ResourceListController.h"

#import <Masonry/Masonry.h>
#import <FKDownloader/FKDownloader.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "InfoModel.h"
#import "DownloadURLManager.h"

@interface ResourceListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) NSArray<InfoModel *> *infoModels;

@end

@implementation ResourceListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"资源列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
    
    [self.listView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    self.listView.tableFooterView = [UIView new];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    [self.view addSubview:self.listView];
}

- (void)loadData {
    self.infoModels = @[
    [InfoModel modelWithURL:@"https://images.unsplash.com/photo-1579277056526-3e93e09a4161?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9"],
    [InfoModel modelWithURL:@"https://github.com/ET-Team/EnigTech2/releases/download/v1.2.12/EnigTech2-1.2.12.zip"],
    [InfoModel modelWithURL:@"https://github.com/agalwood/Motrix/releases/download/v1.4.1/Motrix-1.4.1.dmg"],
    [InfoModel modelWithURL:@"https://images.unsplash.com/photo-1579288521976-bd9d5c9bd7e6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9"],
    [InfoModel modelWithURL:@"https://qd.myapp.com/myapp/qqteam/pcqq/PCQQ2020.exe"],
    [InfoModel modelWithURL:@"https://qd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk?r=1"],
    [InfoModel modelWithURL:@"https://images.unsplash.com/photo-1579267466317-e2aca9b8d62b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9"],
    [InfoModel modelWithURL:@"http://qq.pinyin.cn/download_pc.php?t=py"],
    [InfoModel modelWithURL:@"https://images.unsplash.com/photo-1579256308218-d162fd41c801?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9"],
    [InfoModel modelWithURL:@"http://cdn2.ime.sogou.com/c3a8f7086201f3ac9cc7fa00309c399b/5e240483/dl/index/1578890652/sogou_pinyin_96a.exe"],
    [InfoModel modelWithURL:@"http://cdn2.ime.sogou.com/8829b78d77d7b66f1af17f9bd5f54139/5e240479/dl/index/1574950329/sogou_mac_56b.zip"],
    [InfoModel modelWithURL:@"https://www.xmind.cn/xmind/downloads/XMind-ZEN-for-Windows-64bit-10.0.1-202001022330.exe"],
    [InfoModel modelWithURL:@"https://adl.netease.com/d/g/a11/c/mac"],
    [InfoModel modelWithURL:@"https://dl.iina.io/IINA.v1.0.6.dmg"],
    [InfoModel modelWithURL:@"https://dl.softmgr.qq.com/original/Audio/2019112318441_cloudmusicsetup2.7.1.198242.exe"],
    [InfoModel modelWithURL:@"https://download.alicdn.com/wangwang/AliIM_taobao_(9.12.10C).exe?spm=a21e4.8038711.0.0.3d16297dkPKX4B&file=AliIM_taobao_(9.12.10C).exe"],
    [InfoModel modelWithURL:@"http://issuecdn.baidupcs.com/issue/netdisk/yunguanjia/BaiduNetdisk_6.8.9.1.exe"],
    [InfoModel modelWithURL:@"https://dl.softmgr.qq.com/original/Browser/79.0.3945.88_chrome_installer_32.exe"],
    [InfoModel modelWithURL:@"https://dl.softmgr.qq.com/original/Browser/QQBrowser_Setup_Qqpcmgr_10.5.3863.400.exe"],
    [InfoModel modelWithURL:@"https://dl.softmgr.qq.com/original/im/YYSetup-8.56.0.2-zh-CN.exe"]];
    
    [self.listView reloadData];
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
    return self.infoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    InfoModel *info = [self.infoModels objectAtIndex:indexPath.row];
    cell.textLabel.text = info.url;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"已添加到下载队列";
    [hud hideAnimated:YES afterDelay:1];
    
    InfoModel *info = [self.infoModels objectAtIndex:indexPath.row];
    FKBuilder *builder = [FKBuilder buildWithURL:info.url];
//    builder.downloadType = FKDownloadTypeForeground;
    [builder prepare];
    [[DownloadURLManager manager] saveInfo:info];
}


#pragma mark - Getter/Setter
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    }
    return _listView;
}

@end
