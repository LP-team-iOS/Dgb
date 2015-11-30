//
//  NotificationViewCell.m
//  duangongbang
//
//  Created by ljx on 15/10/15.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "NotificationViewCell.h"
@interface NotificationViewCell()



@end



@implementation NotificationViewCell


- (void)awakeFromNib {
    // Initialization code
    
    [_contact setTitle:@"联系\n方式" forState:UIControlStateNormal];
    _contact.titleLabel.textColor = [UIColor whiteColor];
    _contact.titleLabel.textAlignment = NSTextAlignmentCenter;
    _contact.titleLabel.font = [UIFont systemFontOfSize:11];
    _contact.titleLabel.numberOfLines = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
