//
//  CommentNewsViewController.h
//  duangongbang
//
//  Created by ljx on 15/11/2.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RemoveRed <NSObject>
- (void)Remove_Red:(NSString *)str andRemove_red:(NSString *)NoticeObjectId andType:(NSString *)Type;
- (void)Remove_Red2:(NSString *)str andRemove_red:(NSString *)WorkOrderObjectId andType:(NSString *)Type;
- (void)RemovelocalRed:(NSString *)str;
@end

@interface CommentNewsViewController : UIViewController

@property (nonatomic, retain) id <RemoveRed> delegate;

@end

