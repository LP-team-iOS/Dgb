//
//  UIButton+Extension.m
//  duangongbang
//
//  Created by ljx on 15/10/19.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)
+ (UIButton *)buttonWithTarget:(id)target Action:(SEL)action image:(NSString *)image
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    CGSize size = btn.currentBackgroundImage.size;
    btn.frame = CGRectMake(0, 0,size.width,size.height);
    return btn;
}
@end
