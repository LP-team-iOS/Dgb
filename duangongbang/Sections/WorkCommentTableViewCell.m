//
//  WorkCommentTableViewCell.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/13.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "WorkCommentTableViewCell.h"
#import "TimeCaculate.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "UIImageView+BezierPathCornerRadius.h"
#import "LabelPlacing.h"

static NSString * const kCommentKey = @"Comment";
static NSString * const kNickNameKey = @"NickName";
static NSString * const kObjectIdKey = @"objectId";
static NSString * const kTimeKey = @"Time";
static NSString * const kUserImgKey = @"UserImg";
static NSString * const kReCommentKey = @"ReComment";

@implementation WorkCommentTableViewCell {
    
    __weak IBOutlet UILabel *_lbComment;
    __weak IBOutlet UILabel *_lbTime;
    __weak IBOutlet UILabel *_lbUserName;
    __weak IBOutlet UIImageView *_headImg;
    __weak IBOutlet NSLayoutConstraint *_bottomConstraint;
    UIImageView *_headImgRe;
    UILabel *_lbReComment;
    UILabel *_lbReUserName;
    UILabel *_lbReForUserName;
    UILabel *_lbReTime;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showDataToViewWithDic:(NSDictionary *)dic {
    
    [_headImg sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:kUserImgKey]] placeholderImage:[UIImage imageNamed:@"Head_Image"]];
    _lbUserName.text = [dic objectForKey:kNickNameKey];
    _lbTime.text = [dic objectForKey:kTimeKey];
    _lbComment.text = [dic objectForKey:kCommentKey];
    [LabelPlacing thtLabelPlacingWith:_lbComment];
    _lbComment.textColor = UIColorFromRGB(0x717171);
    [_headImg addBezierCornerRadiusWithImageView:_headImg];
//    if ([dic objectForKey:kReCommentKey]) {
//        [_lbComment removeConstraint:_bottomConstraint];
//        UIView *reView = [[UIView alloc] init];
//        reView.backgroundColor = UIColorFromRGB(0xEEEEEE);
//        [self.contentView addSubview:reView];
//        [reView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.contentView.mas_left);
//            make.top.equalTo(_lbComment.mas_bottom).with.offset(8.0);
//            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(1.0);
//            make.right.equalTo(self.contentView.mas_right);
//            make.height.greaterThanOrEqualTo(56.0);
//        }];
//        
//        _headImgRe = [[UIImageView alloc] init];
//        [reView addSubview:_headImgRe];
//        [_headImgRe mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(reView.mas_left).with.offset(16.0);
//            make.top.equalTo(reView.mas_top).with.offset(8.0);
//            make.size.equalTo(CGSizeMake(56, 56));
//        }];
//        [_headImgRe sd_setImageWithURL:[NSURL URLWithString:[[dic objectForKey:kReCommentKey] objectForKey:kUserImgKey]] placeholderImage:[UIImage imageNamed:@"Head_Image"]];
//        [_headImgRe addBezierCornerRadiusWithImageView:_headImgRe];
//        
//        _lbReUserName = [[UILabel alloc] init];
//        _lbReUserName.font = [UIFont fontWithName:kFontName size:12.0];
//        _lbReUserName.textColor = UIColorFromRGB(0x717171);
//        [reView addSubview:_lbReUserName];
//        [_lbReUserName mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_headImgRe.mas_right).with.offset(8.0);
//            make.top.equalTo(reView.mas_top).with.offset(8.0);
//            make.width.greaterThanOrEqualTo(0.0);
//            make.height.equalTo(16.0);
//        }];
//        _lbReUserName.text = [[dic objectForKey:kReCommentKey] objectForKey:kNickNameKey];
//        
//        UILabel *lbRe = [[UILabel alloc] init];
//        lbRe.text = @"回复";
//        lbRe.font = [UIFont fontWithName:kFontName size:8.0];
//        lbRe.textColor = UIColorFromRGB(0x717171);
//        [reView addSubview:lbRe];
//        [lbRe mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(_lbReUserName.mas_right).with.offset(4.0);
//            make.bottom.equalTo(_lbReUserName.mas_bottom);
//            make.size.equalTo(CGSizeMake(18, 10));
//        }];
//        
//        _lbReForUserName = [[UILabel alloc] init];
//        _lbReForUserName.textColor = UIColorFromRGB(0x717171);
//        _lbReForUserName.font = [UIFont fontWithName:kFontName size:12.0];
//        [reView addSubview:_lbReForUserName];
//        [_lbReForUserName mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(lbRe.mas_right).with.offset(4.0);
//            make.bottom.equalTo(_lbReUserName.mas_bottom);
//            make.width.greaterThanOrEqualTo(0);
//            make.height.equalTo(16.0);
//        }];
//        _lbReForUserName.text = [dic objectForKey:kNickNameKey];
//        
//        _lbReComment = [[UILabel alloc] init];
//        _lbReComment.textColor = UIColorFromRGB(0xcccccc);
//        _lbReComment.font = [UIFont fontWithName:kFontName size:12.0];
//        _lbReComment.numberOfLines = 0;
//        [reView addSubview:_lbReComment];
//        [reView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_lbReUserName.mas_bottom).with.offset(4.0);
//            make.left.equalTo(_headImgRe.mas_right).with.offset(4.0);
//            make.right.equalTo(reView.mas_right).with.offset(4.0);
//            make.bottom.equalTo(reView.mas_bottom).with.offset(4.0);
//            make.height.greaterThanOrEqualTo(0);
//        }];
//        _lbReComment.text = [[dic objectForKey:kReCommentKey] objectForKey:kCommentKey];
//    }
}

@end
