//
//  NSTimer+Control.m
//  duangongbang
//
//  Created by ljx on 15/6/6.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "NSTimer+Control.h"

@implementation NSTimer (Control)
-(void)pauseTimer{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate distantFuture]];
}


-(void)resumeTimer{
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
}

@end
