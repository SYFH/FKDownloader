//
//  TaskViewCell.h
//  FKDownloaderDemo
//
//  Created by Norld on 2018/11/10.
//  Copyright © 2018 Norld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FKTask;

@interface TaskViewCell : UITableViewCell

@property (nonatomic, strong) FKTask *task;
@property (nonatomic, strong) NSString *url;

@end
