//
//  JobTableViewCell.h
//  NewDGCell
//
//  Created by 123 on 15/4/23.
//  Copyright (c) 2015年 123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/BmobObject.h>

@interface JobTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mainView;


@property (weak, nonatomic) IBOutlet UILabel *lbWorkTitle;

@property (weak, nonatomic) IBOutlet UILabel *lbWorkPlace;
@property (weak, nonatomic) IBOutlet UILabel *lbReleaseTime;
@property (weak, nonatomic) IBOutlet UILabel *lbLikeNum;
@property (strong, nonatomic) IBOutlet UIImageView *imgBigV;

@property (weak, nonatomic) IBOutlet UILabel *lbPayUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbWorkType;
@property (weak, nonatomic) IBOutlet UILabel *lbNum;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;

@property (weak, nonatomic) NSDictionary *data;
- (void)setAllFrameWithWork:(NSDictionary *)dic;
- (void)setAllFrameWithWorkList:(NSDictionary *)dic;
- (void)setAllFrameWithBmobObject:(BmobObject *)obj;
- (void)setSearchModelWithWork:(NSDictionary *)dic;
@end
