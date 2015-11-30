//
//  UITextField+HeaderView.m
//  duangongbang
//
//  Created by ljx on 15/6/6.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UITextField+HeaderView.h"

@implementation UITextField (HeaderView)

- (void)addHeaderViewWithSpacing:(CGFloat )spacing{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, spacing, self.frame.size.height)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
