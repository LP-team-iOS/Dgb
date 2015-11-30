//
//  WorkNewsViewController.h
//  duangongbang
//
//  Created by ljx on 15/11/2.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentNewsViewController.h"

@interface WorkNewsViewController : UIViewController<RemoveRed>
@property (nonatomic, retain) id <RemoveRed> delegate;
@end
