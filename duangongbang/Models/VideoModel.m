//
//  VideoModel.m
//  duangongbang
//
//  Created by ljx on 15/6/15.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "VideoModel.h"
#import "MJExtension.h"

#define kObjectId       @"objectId";
#define kVideoObjectId  @"VideoObjectId"
#define kUser           @"User"
#define kUserName       @"username"
#define kNickname       @"Nickname"
#define kUserHeadImg    @"HeadImg"
#define kUserHeadImgUrl @"UserHeadImg"
#define kUserLevel      @"Level"
#define kLevel          @"LV"
#define kTitle          @"Title"
#define kContent        @"Content"
#define kVideoURL       @"VideoUrl"
#define kImgUrl         @"ImgUrl"
#define kPraiseNum      @"PraiseNum"
#define kPraiseCount    @"PraiseCount"
#define kIsDeleted      @"IsDeleted"
#define kStatic         @"Static"
#define kViewedTimes    @"ViewedTimes"
#define kRewardNum      @"RewardNum"
#define kCommentList    @"CommentList"
#define kVip            @"Vip"
#define kCreatedAt      @"createdAt"
#define kUpdatedAt      @"updatedAt"

@implementation VideoModel

+ (VideoModel *)initWithBmobObject:(BmobObject *)bmobObject{
    
    VideoModel *model        = [[self alloc] init];
    if (model) {
        model.objectId       = bmobObject.objectId;
        model.user           = [bmobObject objectForKey:kUser];
        model.userObjectId   = model.user.objectId;
        model.userName       = [model.user objectForKey:kUserName];
        model.userHeadImg    = [model.user objectForKey:kUserHeadImg];
        model.userHeadImgURL = model.userHeadImg.url;
        model.levelObject    = [model.user objectForKey:kUserLevel];
        model.level          = [model.levelObject objectForKey:kLevel];
        model.title          = [bmobObject objectForKey:kTitle];
        model.content        = [bmobObject objectForKey:kContent];
        model.videoURL       = [bmobObject objectForKey:kVideoURL];
        model.imgURL         = [bmobObject objectForKey:kImgUrl];
        model.praiseNum      = [bmobObject objectForKey:kPraiseNum];
        model.isDeleted      = [[bmobObject objectForKey:kIsDeleted] boolValue];
        model.staticArray    = [bmobObject objectForKey:kStatic];
        model.viewedTimes    = [bmobObject objectForKey:kViewedTimes];
        model.createdAt      = [bmobObject objectForKey:kCreatedAt];
        model.updatedAt      = [bmobObject objectForKey:kUpdatedAt];
    }
    return model;
}

+ (VideoModel *)initWithDic:(NSDictionary *)dic{
    VideoModel *model        = [[self alloc] init];
    if (model) {
        model.objectId = [dic objectForKey:kVideoObjectId];
        model.imgURL = [dic objectForKey:kImgUrl];
        model.content = [dic objectForKey:kContent];
        model.praiseNum = [dic objectForKey:kPraiseCount];
        model.viewedTimes = [dic objectForKey:kViewedTimes];
        model.userHeadImgURL = [dic objectForKey:kUserHeadImgUrl];
        model.commentList = [dic objectForKey:kCommentList];
        model.userName = [dic objectForKey:kNickname];
        model.level = [dic objectForKey:kLevel];
        model.title = [dic objectForKey:kTitle];
        model.videoURL = [dic objectForKey:kVideoURL];
        model.createdAt = [dic objectForKey:kCreatedAt];
        model.rewardNum = [dic objectForKey:kRewardNum];
        model.VIP = [dic objectForKey:kVip];
    }
    return model;
}

MJCodingImplementation

//- (id)initWithCoder:(NSCoder *)aDecoder{
//    self.objectId =[aDecoder decodeObjectForKey:kVideoObjectId];
//    self.imgURL = [aDecoder decodeObjectForKey:kImgUrl];
//    self.content = [aDecoder decodeObjectForKey:kContent];
//    self.praiseNum = [aDecoder decodeObjectForKey:kPraiseCount];
//    self.viewedTimes = [aDecoder decodeObjectForKey:kViewedTimes];
//    self.userHeadImgURL = [aDecoder decodeObjectForKey:kUserHeadImgUrl];
//    self.commentList = [aDecoder decodeObjectForKey:kCommentList];
//    self.userName = [aDecoder decodeObjectForKey:kNickname];
//    self.level = [aDecoder decodeObjectForKey:kLevel];
//    self.title = [aDecoder decodeObjectForKey:kTitle];
//    self.videoURL = [aDecoder decodeObjectForKey:kVideoURL];
//    self.createdAt = [aDecoder decodeObjectForKey:kCreatedAt];
//    self.rewardNum = [aDecoder decodeObjectForKey:kRewardNum];
//    self.VIP = [aDecoder decodeObjectForKey:kVip];
//    return self;
//}
//- (void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeObject:self.objectId forKey:kVideoObjectId];
//    [aCoder encodeObject:self.imgURL forKey:kImgUrl];
//    [aCoder encodeObject:self.content forKey:kContent];
//    [aCoder encodeObject:self.praiseNum forKey:kPraiseCount];
//    [aCoder encodeObject:self.viewedTimes forKey:kViewedTimes];
//    [aCoder encodeObject:self.userHeadImgURL forKey:kUserHeadImgUrl];
//    [aCoder encodeObject:self.commentList forKey:kCommentList];
//    [aCoder encodeObject:self.userName forKey:kNickname];
//    [aCoder encodeObject:self.level forKey:kLevel];
//    [aCoder encodeObject:self.title forKey:kTitle];
//    [aCoder encodeObject:self.videoURL forKey:kVideoURL];
//    [aCoder encodeObject:self.createdAt forKey:kCreatedAt];
//    [aCoder encodeObject:self.rewardNum forKey:kRewardNum];
//    [aCoder encodeObject:self.VIP forKey:kVip];
//}

@end
