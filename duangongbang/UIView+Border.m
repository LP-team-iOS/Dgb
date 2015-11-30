//
//  UIView+Border.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/6/3.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView (Border)
- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}
- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andHeight:(CGFloat)borderHeight{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderHeight, borderWidth);
    [self.layer addSublayer:border];
}
- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}
- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andHeight:(CGFloat)borderHeight{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, borderHeight, borderWidth);
    [self.layer addSublayer:border];
}
- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

- (void)addBorderWithColor:(UIColor *)color andWidth:(CGFloat )borderWidth{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = borderWidth;
    self.layer.masksToBounds = YES;
}
@end
