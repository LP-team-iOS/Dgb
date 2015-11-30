//
//  CustomizedTableViewCell.h
//  NewDGCell
//
//  Created by 123 on 15/4/23.
//  Copyright (c) 2015年 123. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomizedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UILabel *lbRules;

@property (weak, nonatomic) IBOutlet UIButton *btnCustomized;

@end
