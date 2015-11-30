//
//  MYViewController.h
//  duangongbang
//
//  Created by chen on 15/11/2.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *vImage;

/**
 *  Name Label.centerX = centerX
 
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelCenterCons;
@property (weak, nonatomic) IBOutlet UIImageView *blurImage;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;

@end



