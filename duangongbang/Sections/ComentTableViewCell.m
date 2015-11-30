//
//  ComentTableViewCell.m
//  duangongbang
//
//  Created by ljx on 15/5/18.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "ComentTableViewCell.h"
#import "TimeCaculate.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+BezierPathCornerRadius.h"
#import "LabelPlacing.h"

static NSString * const kCommentKey = @"Comment";
static NSString * const kNickNameKey = @"NickName";
static NSString * const kObjectIdKey = @"objectId";
static NSString * const kTimeKey = @"Time";
static NSString * const kUserImgKey = @"UserImg";
static NSString * const kReCommentKey = @"ReComment";

@implementation ComentTableViewCell{
    
    __weak IBOutlet UIImageView *imgUserHead;
    __weak IBOutlet UIImageView *imgReplyUserHead;
    __weak IBOutlet UILabel *lbUserName;
    __weak IBOutlet UILabel *lbCommentDate;
    __weak IBOutlet UILabel *lbCommentContent;
    __weak IBOutlet UILabel *lbReplyUserName;
    __weak IBOutlet UILabel *lbReplyForUserName;
    __weak IBOutlet UILabel *lbReplyContent;
    __weak IBOutlet UILabel *lbReplyDate;
    
    __weak IBOutlet UIView *_recommentView;
    
    __weak IBOutlet UILabel *_lbIndex;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 {
	"Comment": "加微信的",
	"NickName": "LANQIAN",
	"objectId": "d38214360d",
	"Time": "08-06 19:26:04",
	"UserImg": "http://file.bmob.cn/M01/C7/24/oYYBAFXDRGiAU9JEAAFscTIXhtU151.jpg"
 }
 
 *  {
	"Comment"  : "打不通电话",
	"NickName" : "hero",
	"objectId" : "11d5507384",
	"ReComment": {
    "Comment"  : "电话不存在",
    "NickName" : "静静",
    "objectId" : "f649e918b0",
    "Time"     : "08-06 18:45:40",
    "UserImg"  : "http://file.bmob.cn/M01/C6/F6/oYYBAFXDOwKAD0sIAAEEWk3noBg956.jpg"
	},
    "Time"     : "08-06 18:36:29",
	"UserImg"  : "http://file.bmob.cn/M01/C5/90/oYYBAFXDA7-AH7DsAABXe0i-9Q0725.jpg"
 }
 */

- (void)showDataToViewWithDic:(NSDictionary *)dic {
    [imgUserHead sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:kUserImgKey]] placeholderImage:[UIImage imageNamed:@"Head_Image"]];
    lbUserName.text = [dic objectForKey:kNickNameKey];
    lbCommentDate.text = [dic objectForKey:kTimeKey];
    lbCommentContent.text = [dic objectForKey:kCommentKey];
    [LabelPlacing thtLabelPlacingWith:lbCommentContent];
    lbCommentContent.textColor = UIColorFromRGB(0x717171);
    [imgUserHead addBezierCornerRadiusWithImageView:imgUserHead];
    
    if ([dic objectForKey:kReCommentKey]) {
        _recommentView.layer.cornerRadius = 3.0;
        [imgReplyUserHead sd_setImageWithURL:[NSURL URLWithString:[[dic objectForKey:kReCommentKey] objectForKey:kUserImgKey]] placeholderImage:[UIImage imageNamed:@"Head_Image"]];
        [imgReplyUserHead addBezierCornerRadiusWithImageView:imgReplyUserHead];
        lbReplyUserName.text = [[dic objectForKey:kReCommentKey] objectForKey:kNickNameKey];
        lbReplyForUserName.text = [dic objectForKey:kNickNameKey];
        lbReplyDate.text = [[dic objectForKey:kReCommentKey] objectForKey:kTimeKey];
        lbReplyContent.text = [[dic objectForKey:kReCommentKey] objectForKey:kCommentKey];
        [LabelPlacing thtLabelPlacingWith:lbReplyContent];
        lbReplyContent.textColor = UIColorFromRGB(0x717171);
        
    }else {
        _recommentView.hidden = YES;
        _lbIndex.hidden = YES;
        [self updateConstraints];
    }
}

@end
