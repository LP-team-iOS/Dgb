//
//  DGListViewController.h
//  duangongbang
//
//  Created by ljx on 15/5/13.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end
