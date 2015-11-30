//
//  NotificationViewCell.h
//  duangongbang
//
//  Created by ljx on 15/10/15.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotificationBoardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *labelView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *ticp2Label;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UITextView *noticeTextView;
@end
