//
//  DGBToolBar.h
//  TestAll
//
//  Created by Chen Haochuan on 15/8/15.
//  Copyright (c) 2015年 Chen Haochuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BUTTON_HEIGHT 40.0
#define BUTTON_WIDTH 40.0
#define BUTTON_ORIGIN_Y 5.0

#define ANIMATION_TIME .6
#define SPRING_DAMPING .7
#define SPRING_VELOCITY .9


@class DGBToolBar;
@protocol DGBToolBarDataSource <NSObject>
@required
/**
 *  Bar 的Button的数量
 *
 *  @param toolBar 对应的toolbar
 *
 *  @return 个数
 */
- (NSInteger)numberOfToolBar:(DGBToolBar *)toolBar;
/**
 *  设置barButton的image
 *
 *  @param indexPath 索引
 *
 *  @return UIImage
 */
- (UIImage *)imageOfToolBar:(NSInteger )indexPath;
@optional
/**
 *  Button的标题
 *
 *  @param toolBar Bar
 *
 *  @return 标题的数组
 */
- (NSArray *)titlesOfToolBar:(DGBToolBar *)toolBar;


/**
 *  根据索引设置颜色
 *
 *  @param indexPath 对应的button
 *
 *  @return 颜色UIColor
 */
- (UIColor *)colorOfToolBar:(NSInteger )indexPath;

@end

@protocol DGBToolBarDelegate <NSObject>

- (void)toolBar:(DGBToolBar *)toolBar didSelectAtIndexPath:(NSInteger)indexPath;

@end

 

@interface DGBToolBar : UIView

@property (nonatomic, weak) IBOutlet id<DGBToolBarDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<DGBToolBarDelegate> delegate;

@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;
@property (nonatomic, weak) UIColor *textColor;
@property (nonatomic, weak) UIColor *bgColor;
@property (nonatomic, weak) UIFont *font;

@property (nonatomic, assign, readonly) CGFloat labelWidth;

- (instancetype)initWithRect:(CGRect)rect;

- (void)reloadData;

@end
