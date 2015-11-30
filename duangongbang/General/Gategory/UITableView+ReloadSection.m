//
//  UITableView+ReloadSection.m
//  duangongbang
//
//  Created by ljx on 15/7/2.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UITableView+ReloadSection.h"

@implementation UITableView (ReloadSection)
- (void)reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    
    [self beginUpdates];
    [self deleteSections:indexSet withRowAnimation:rowAnimation];
    [self insertSections:indexSet withRowAnimation:rowAnimation];
    [self endUpdates];
}
@end
