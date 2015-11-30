//
//  DirectSupportAcceptedViewController.h
//  duangongbang
//
//  Created by Macist on 15/11/5.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentNewsViewController.h"
@interface DirectSupportAcceptedViewController : UIViewController<RemoveRed>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) id <RemoveRed> delegate;

@end