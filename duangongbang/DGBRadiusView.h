//
//  DGBRadiusView.h
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/20.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface DGBRadiusView : UIView
@property (assign, nonatomic) IBInspectable BOOL topRightRadius;
@property (assign, nonatomic) IBInspectable BOOL topLeftRadius;
@property (assign, nonatomic) IBInspectable BOOL bottomRightRadius;
@property (assign, nonatomic) IBInspectable BOOL bottomLeftRadius;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;
@end
