//
//  MYTableViewCell.h
//  duangongbang
//
//  Created by chen on 15/10/30.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface MYTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@property (weak, nonatomic) IBOutlet UILabel *myTextLabel;

- (void)setRoundingCornersByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
@property (weak, nonatomic) IBOutlet UIButton *myButton;

@end