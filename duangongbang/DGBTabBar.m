//
//  DGBTabBar.m
//  duangongbang
//
//  Created by BoxingWoo on 15/11/14.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "DGBTabBar.h"

@interface DGBTabBar ()

@property (nonatomic, weak) UIImageView *tabbarBackgroundImageView;

@end

@implementation DGBTabBar

- (void)drawRect:(CGRect)rect
{
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"_UITabBarBackgroundView")]) {
            [subView removeFromSuperview];
        }
    }
    CGFloat offset = 5.0;
    for (UITabBarItem *item in self.items) {
        item.imageInsets = UIEdgeInsetsMake(offset, 0, -offset, 0);
    }

    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = UIColorFromRGB(xMainBlackColor);
    [self insertSubview:backgroundView atIndex:0];
    
//    UIGraphicsBeginImageContext(self.bounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, RGB(0, 96, 116, 1.0).CGColor);
//    CGContextFillRect(context, self.bounds);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGFloat width = Width / self.items.count;
//    NSUInteger index = [self.items indexOfObject:self.selectedItem];
//    UIImageView *tabbarBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * width, 0, width, width)];
//    _tabbarBackgroundImageView = tabbarBackgroundImageView;
//    tabbarBackgroundImageView.image = image;
//    [backgroundView addSubview:tabbarBackgroundImageView];
}

//- (void)setSelectedItem:(UITabBarItem *)selectedItem
//{
//    [super setSelectedItem:selectedItem];
//    CGFloat width = Width / self.items.count;
//    NSUInteger index = [self.items indexOfObject:selectedItem];
//    [UIView animateWithDuration:0.25 animations:^{
//        self.tabbarBackgroundImageView.frame = CGRectMake(index * width, 0, width, width);
//    }];
//}

@end
