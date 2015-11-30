//
//  DGBListViewController.h
//  duangongbang
//
//  Created by Chen Haochuan on 15/7/20.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UITableViewListStates) {
    UITableViewListApply = 1,
    UITableViewListVideoResume,
    UITableViewListCollections,
    UITableViewListMyRelease,
};

@interface DGBListViewController : UIViewController

@property NSInteger listStates;

@end
