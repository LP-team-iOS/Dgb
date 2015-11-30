//
//  DGDetailViewController.h
//  duangongbang
//
//  Created by ljx on 15/5/16.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagingScrollView.h"

@interface DGDetailViewController : UIViewController<UIScrollViewDelegate>

@property (assign, nonatomic) BOOL mainViewPush;

@property (weak, nonatomic) IBOutlet UIImageView *imgReturnDissmiss;

@property (weak, nonatomic) NSString *workObjectId;

@end
