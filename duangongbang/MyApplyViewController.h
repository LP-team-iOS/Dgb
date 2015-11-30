//
//  MyApplyViewController.h
//  duangongbang
//
//  Created by ljx on 15/9/29.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentNewsViewController.h"

@interface MyApplyViewController : UIViewController<RemoveRed>
@property (nonatomic,copy) NSString *page;
@property (nonatomic,assign)BOOL isRefresh;
@property (nonatomic, retain) id <RemoveRed> delegate;
@end
