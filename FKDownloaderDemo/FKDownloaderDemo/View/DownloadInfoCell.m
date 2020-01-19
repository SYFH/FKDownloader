//
//  DownloadInfoCell.m
//  FKDownloaderDemo
//
//  Created by norld on 2020/1/19.
//  Copyright © 2020 norld. All rights reserved.
//

#import "DownloadInfoCell.h"

#import <Masonry/Masonry.h>
#import <FKDownloader/FKDownloader.h>

@interface DownloadInfoCell ()

@property (nonatomic, strong) UILabel *urlLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressInfoLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIButton *controlButton;
@property (nonatomic, assign) FKState state;

@end

@implementation DownloadInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.urlLabel = [[UILabel alloc] init];
        self.urlLabel.font = [UIFont systemFontOfSize:15];
        self.urlLabel.text = @"下载链接";
        [self.contentView addSubview:self.urlLabel];
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [self.contentView addSubview:self.progressView];
        
        self.progressInfoLabel = [[UILabel alloc] init];
        self.progressInfoLabel.font = [UIFont systemFontOfSize:15];
        self.progressInfoLabel.textAlignment = NSTextAlignmentLeft;
        self.progressInfoLabel.text = @"进度信息";
        [self.contentView addSubview:self.progressInfoLabel];
        
        self.stateLabel = [[UILabel alloc] init];
        self.stateLabel.font = [UIFont systemFontOfSize:15];
        self.stateLabel.textAlignment = NSTextAlignmentRight;
        self.stateLabel.text = @"状态信息";
        [self.contentView addSubview:self.stateLabel];
        
        self.controlButton = [[UIButton alloc] init];
        [self.controlButton setTitle:@"处理中" forState:UIControlStateNormal];
        [self.controlButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [self.controlButton addTarget:self action:@selector(controlDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.controlButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.contentView);
        make.width.mas_equalTo(80);
    }];
    
    [self.urlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).mas_offset(8);
        make.left.equalTo(self.contentView.mas_left).mas_offset(4);
        make.right.equalTo(self.controlButton.mas_left).mas_offset(8);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.urlLabel.mas_bottom).mas_offset(8);
        make.left.equalTo(self.contentView.mas_left).mas_offset(4);
        make.right.equalTo(self.controlButton.mas_left).mas_offset(8);
        make.height.mas_equalTo(2);
    }];
    
    [self.progressInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).mas_offset(8);
        make.left.equalTo(self.contentView.mas_left).mas_offset(4);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).mas_offset(8);
        make.right.equalTo(self.controlButton.mas_left).mas_offset(4);
        make.left.equalTo(self.progressInfoLabel.mas_right);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)infoMessage {
    self.urlLabel.text = self.url;
    
    __weak typeof(self) weak = self;
    [FKMessager messagerWithURL:self.url info:^(int64_t countOfBytesReceived,
                                                int64_t countOfBytesExpectedToReceive,
                                                FKState state) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weak) self = weak;
            CGFloat progress = countOfBytesReceived * 1.0 / countOfBytesExpectedToReceive;
            self.progressView.progress = progress;
            self.progressInfoLabel.text = [NSString stringWithFormat:@"%lld/%lld",countOfBytesReceived, countOfBytesExpectedToReceive];
            self.stateLabel.text = [self stateTransform:state];
            [self controlTitleWithState:state];
        });
    }];
    [self controlTitleWithState:[FKControl stateWithURL:self.url]];
}

- (void)controlTitleWithState:(FKState)state {
    self.state = state;
    switch (state) {
        case FKStatePrepare: {
            [self.controlButton setTitle:@"处理中" forState:UIControlStateNormal];
            self.controlButton.enabled = NO;
        } break;
        case FKStateIdel: {
            [self.controlButton setTitle:@"取消" forState:UIControlStateNormal];
            self.controlButton.enabled = YES;
        } break;
        case FKStateAction: {
            [self.controlButton setTitle:@"暂停" forState:UIControlStateNormal];
            self.controlButton.enabled = YES;
        } break;
        case FKStateSuspend: {
            [self.controlButton setTitle:@"继续" forState:UIControlStateNormal];
            self.controlButton.enabled = YES;
        } break;
        case FKStateCancel: {
            [self.controlButton setTitle:@"开始" forState:UIControlStateNormal];
            self.controlButton.enabled = YES;
        } break;
        case FKStateError: {
            [self.controlButton setTitle:@"开始" forState:UIControlStateNormal];
            self.controlButton.enabled = YES;
        } break;
        case FKStateComplete: {
            [self.controlButton setTitle:@"已完成" forState:UIControlStateNormal];
            self.controlButton.enabled = NO;
        } break;
    }
}

- (NSString *)stateTransform:(FKState)state {
    switch (state) {
        case FKStatePrepare:
            return @"状态: 预处理";
        case FKStateIdel:
            return @"状态: 等待";
        case FKStateAction:
            return @"状态: 进行";
        case FKStateSuspend:
            return @"状态: 暂停";
        case FKStateCancel:
            return @"状态: 取消";
        case FKStateError:
            return @"状态: 错误";
        case FKStateComplete:
            return @"状态: 已完成";
    }
}


#pragma mark - Action
- (void)controlDidTap:(UIButton *)sender {
    switch (self.state) {
        case FKStatePrepare: {
            
        } break;
        case FKStateIdel: {
            [FKControl cancelRequestWithURL:self.url];
        } break;
        case FKStateAction: {
            [FKControl suspendRequestWithURL:self.url];
        } break;
        case FKStateSuspend: {
            [FKControl resumeRequestWithURL:self.url];
        } break;
        case FKStateCancel: {
            [FKControl actionRequestWithURL:self.url];
        } break;
        case FKStateError: {
            [FKControl actionRequestWithURL:self.url];
        } break;
        case FKStateComplete: {
            
        } break;
    }
}


#pragma mark - Getter/Setter
- (void)setUrl:(NSString *)url {
    _url = url;
    
    [self infoMessage];
}

@end
