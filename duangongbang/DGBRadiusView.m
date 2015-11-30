//
//  DGBRadiusView.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/20.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "DGBRadiusView.h"

@interface DGBRadiusView ()
@property (weak, nonatomic) UIColor *bgColor;
@end

@implementation DGBRadiusView

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    _bgColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(_bottomLeftRadius?UIRectCornerBottomLeft:0)|(_bottomRightRadius?UIRectCornerBottomRight:0)|(_topLeftRadius?UIRectCornerTopLeft:0)|(_topRightRadius?UIRectCornerTopRight:0) cornerRadii:CGSizeMake(_cornerRadius, 0.f)];
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextAddPath(c, p.CGPath);
    CGContextClosePath(c);
    CGContextClip(c);
    CGContextAddRect(c, rect);
    CGContextSetFillColorWithColor(c, _bgColor.CGColor);
    CGContextFillPath(c);
}

@end
