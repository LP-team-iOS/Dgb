//
//  UIView+Border.h
//  duangongbang
//
//  Created by Chen Haochuan on 15/6/3.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Border)
- (void)addBottomBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addLeftBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addRightBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addTopBorderWithColor: (UIColor *) color andWidth:(CGFloat) borderWidth;

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andHeight:(CGFloat)borderHeight;
- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andHeight:(CGFloat)borderHeight;

- (void)addBorderWithColor:(UIColor *)color andWidth:(CGFloat )borderWidth;

@end
