//
//  MyRefreshFooter.m
//  duangongbang
//
//  Created by ljx on 15/9/18.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "MyRefreshFooter.h"

@implementation MyRefreshFooter

- (void)prepare
{
    [super prepare];
    
    //设置即将刷新状态的动画图片 （一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Refresh%zd", i]];
        [refreshingImages addObject:image];
    }
    //设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}

@end
