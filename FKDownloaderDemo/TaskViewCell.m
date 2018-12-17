//
//  TaskViewCell.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/10.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "TaskViewCell.h"
#import "FKDownloader.h"

@interface TaskViewCell ()<FKTaskDelegate>

@property (nonatomic, strong) UILabel *nameLable;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, strong) UILabel *speedLable;
@property (nonatomic, strong) UILabel *remainingLable;
@property (nonatomic, strong) UIButton *operationButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation TaskViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLable = [[UILabel alloc] init];
        self.nameLable.text = @"文件名";
        [self.contentView addSubview:self.nameLable];
        
        self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        self.progress.progressTintColor = [UIColor orangeColor];
        self.progress.trackTintColor = [UIColor colorWithWhite:0.95 alpha:1];
        [self.contentView addSubview:self.progress];
        
        self.speedLable = [[UILabel alloc] init];
        self.speedLable.text = @"速度";
        [self.contentView addSubview:self.speedLable];
        
        self.remainingLable = [[UILabel alloc] init];
        self.remainingLable.text = @"剩余时间";
        [self.contentView addSubview:self.remainingLable];
        
        self.operationButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.operationButton setTitle:@"开始" forState:UIControlStateNormal];
        [self.operationButton addTarget:self action:@selector(operationDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.operationButton];
        
        self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.stopButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.stopButton addTarget:self action:@selector(stopDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.stopButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // 重用时设置初始状态
    [self.operationButton setTitle:@"开始" forState:UIControlStateNormal];
    self.operationButton.enabled = YES;
    
    [self.stopButton setTitle:@"取消" forState:UIControlStateNormal];
    self.stopButton.enabled = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentView.bounds.size;
    
    self.nameLable.frame = CGRectMake(10, 4, size.width - 110, 30);
    self.progress.frame = CGRectMake(10, 38, size.width - 110, 10);
    self.speedLable.frame = CGRectMake(10, 50, (size.width - 110 - 10) / 2, 30);
    self.remainingLable.frame = CGRectMake(10 + (size.width - 110 - 10) / 2, 50, (size.width - 110 - 10) / 2, 30);
    self.operationButton.frame = CGRectMake(size.width - 110, 5, 100, (size.height - 15) / 2);
    self.stopButton.frame = CGRectMake(size.width - 110, (size.height - 15) / 2 + 5, 100, (size.height - 15) / 2);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Operation
- (void)operationDidTap:(UIButton *)sender {
    if ([[FKDownloadManager manager] acquire:self.url].status != TaskStatusExecuting) {
        [[FKDownloadManager manager] start:self.url];
    } else if ([[FKDownloadManager manager] acquire:self.url].status == TaskStatusSuspend) {
        [[FKDownloadManager manager] resume:self.url];
    } else if ([[FKDownloadManager manager] acquire:self.url].status == TaskStatusExecuting) {
        [[FKDownloadManager manager] suspend:self.url];
    }
}

- (void)stopDidTap:(UIButton *)sender {
    [[FKDownloadManager manager] cancel:self.url];
}

#pragma mark - FKTaskDelegate
- (void)downloader:(FKDownloadManager *)downloader prepareTask:(FKTask *)task {
    NSLog(@"预处理: %@", task.url);
    // 在这里可以最后一次处理任务信息
}

- (void)downloader:(FKDownloadManager *)downloader willExecuteTask:(FKTask *)task {
    NSLog(@"准备开始: %@", task.url);
    self.nameLable.text = [NSURL URLWithString:task.url].lastPathComponent;
}

- (void)downloader:(FKDownloadManager *)downloader didExecuteTask:(FKTask *)task {
    NSLog(@"已开始: %@", task.url);
    [self.operationButton setTitle:@"暂停" forState:UIControlStateNormal];
}

- (void)downloader:(FKDownloadManager *)downloader didIdleTask:(FKTask *)task {
    NSLog(@"开始等待: %@", task.url);
    [self.operationButton setTitle:@"等待中" forState:UIControlStateNormal];
}

- (void)downloader:(FKDownloadManager *)downloader progressingTask:(FKTask *)task {
    self.progress.progress = task.progress.fractionCompleted;
}

- (void)downloader:(FKDownloadManager *)downloader didFinishTask:(FKTask *)task {
    NSLog(@"已完成: %@", task.url);
    self.progress.progress = 1;
    [self.operationButton setTitle:@"完成" forState:UIControlStateNormal];
    self.operationButton.enabled = NO;
}

- (void)downloader:(FKDownloadManager *)downloader willSuspendTask:(FKTask *)task {
    NSLog(@"将暂停: %@", task.url);
}

- (void)downloader:(FKDownloadManager *)downloader didSuspendTask:(FKTask *)task {
    NSLog(@"已暂停: %@", task.url);
    [self.operationButton setTitle:@"继续" forState:UIControlStateNormal];
}

- (void)downloader:(FKDownloadManager *)downloader willCanceldTask:(FKTask *)task {
    NSLog(@"将取消: %@", task.url);
}

- (void)downloader:(FKDownloadManager *)downloader didCancelldTask:(FKTask *)task {
    NSLog(@"已取消: %@", task.url);
    self.progress.progress = 0;
    self.speedLable.text = [task bytesPerSecondSpeedDescription];
    self.remainingLable.text = [task estimatedTimeRemainingDescription];
    [self.operationButton setTitle:@"开始" forState:UIControlStateNormal];
}

- (void)downloader:(FKDownloadManager *)downloader willChecksumTask:(FKTask *)task {
    NSLog(@"开始校验文件");
}

- (void)downloader:(FKDownloadManager *)downloader didChecksumTask:(FKTask *)task {
    NSLog(@"校验文件结束: %d", task.isPassChecksum);
}

- (void)downloader:(FKDownloadManager *)downloader errorTask:(FKTask *)task {
    NSLog(@"下载出错: %@", task.error);
    [self.operationButton setTitle:@"开始" forState:UIControlStateNormal];
}

- (void)downloader:(FKDownloadManager *)downloader speedInfo:(FKTask *)task {
    self.speedLable.text = [task bytesPerSecondSpeedDescription];
    self.remainingLable.text = [task estimatedTimeRemainingDescription];
}


#pragma mark - Getter/Setter
- (void)setTask:(FKTask *)task {
    _task = task;
    
    task.delegate = self;
    self.nameLable.text = [NSURL URLWithString:task.url].lastPathComponent;
}

- (void)setUrl:(NSString *)url {
    _url = url;
    
    [[FKDownloadManager manager] acquire:url].delegate = self;
    self.nameLable.text = [NSURL URLWithString:url].lastPathComponent;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return _dateFormatter;
}

@end
