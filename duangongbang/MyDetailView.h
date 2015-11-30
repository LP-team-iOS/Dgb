//
//  MyDetailView.h
//  duangongbang
//
//  Created by ljx on 15/10/20.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDetailView : UIView
/**
 *  topView
 */
@property (weak, nonatomic) IBOutlet UILabel *lbLikeNum;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
/**
 *  headView
 */
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgVer;
@property (weak, nonatomic) IBOutlet UILabel *lbCompanyUserName;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *lbClickNotic;
@property (weak, nonatomic) IBOutlet UIButton *btnCompanyDetail;
@property (weak, nonatomic) IBOutlet UILabel *lbClickPersonNum;
/**
 *  detailView
 */
@property (weak, nonatomic) IBOutlet UILabel *lbClassifyName;
@property (weak, nonatomic) IBOutlet UILabel *lbPriceUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbSex;
@property (weak, nonatomic) IBOutlet UILabel *lbPayMethod;
@property (weak, nonatomic) IBOutlet UILabel *lbWorkDate;
@property (weak, nonatomic) IBOutlet UILabel *lbStreetName;
/**
 *  workDetailView
 */
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
/**
 *  needKnownView
 */
@property (weak, nonatomic) IBOutlet UILabel *lbApplyKnown;
@property (weak, nonatomic) IBOutlet UILabel *lbApplyKnowWarning;
/**
 *  commentView
 */
@property (weak, nonatomic) IBOutlet UIButton *btnCommentShow;



@end
