//
//  DirectAcceptedDetailViewController.h
//  duangongbang
//
//  Created by Macist on 15/11/5.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectAcceptedDetailViewController : UIViewController

@property (nonatomic, strong) NSString *workTitle;
@property (nonatomic, strong) NSDictionary *selfWorkDic;
@property (nonatomic ,weak) NSString *workOrderObjectId;
@property (nonatomic ,weak) NSString *workObjectId;
@property (nonatomic ,weak) NSString *popTopush;
@end
