//
//  HeadViewCell.h
//  duangongbang
//
//  Created by ljx on 15/10/22.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgVer;
@property (weak, nonatomic) IBOutlet UILabel *lbCompanyUserName;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *lbClickNotic;
@property (weak, nonatomic) IBOutlet UIButton *btnCompanyDetail;
@property (weak, nonatomic) IBOutlet UILabel *lbClickPersonNum;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@end
