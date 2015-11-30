//
//  MYTableViewCell.m
//  duangongbang
//
//  Created by chen on 15/10/30.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "MYTableViewCell.h"

@implementation MYTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setRoundingCornersByRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
//    self.layer.masksToBounds = YES;
    self.layer.mask = maskLayer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
