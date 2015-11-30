//
//  UIImageView+BezierPathCornerRadius.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/13.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UIImageView+BezierPathCornerRadius.h"

@implementation UIImageView (BezierPathCornerRadius)

- (void)addBezierCornerRadiusWithImageView:(UIImageView *)imgView {
    //创建圆形遮罩，把用户头像变成圆形
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(imgView.bounds.size.width / 2, imgView.bounds.size.width / 2) radius:imgView.bounds.size.width / 2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.path = path.CGPath;
    imgView.layer.mask = shape;
}
@end
