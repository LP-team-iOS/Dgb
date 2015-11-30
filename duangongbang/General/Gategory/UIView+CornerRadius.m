//
//  UIView+CornerRadius.m
//  duangongbang
//
//  Created by ljx on 15/6/18.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UIView+CornerRadius.h"

@implementation UIView (CornerRadius)

- (void)setViewCornerWithRadius:(CGFloat)radius{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

@end
