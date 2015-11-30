//
//  UINavigationController+MoveBottomBlackLine.m
//  duangongbang
//
//  Created by ljx on 15/6/18.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UINavigationController+MoveBottomBlackLine.h"

@implementation UINavigationController (MoveBottomBlackLine)
- (void)moveBottomBlackLine{
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
}
@end
