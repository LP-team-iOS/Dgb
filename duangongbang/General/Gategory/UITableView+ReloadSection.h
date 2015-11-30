//
//  UITableView+ReloadSection.h
//  duangongbang
//
//  Created by ljx on 15/7/2.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ReloadSection)
- (void)reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation;
@end
