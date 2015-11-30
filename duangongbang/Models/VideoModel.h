//
//  VideoModel.h
//  duangongbang
//
//  Created by ljx on 15/6/15.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/BmobObject.h>
#import <BmobSDK/BmobFile.h>

@interface VideoModel : NSObject <NSCoding>

@property (nonatomic,strong) NSString    *objectId;
@property (nonatomic,strong) BmobObject  *user;
@property (nonatomic,strong) NSString    *userObjectId;
@property (nonatomic,strong) NSString    *userName;
@property (nonatomic,strong) NSString    *userHeadImgURL;
@property (nonatomic,strong) BmobFile    *userHeadImg;
@property (nonatomic,strong) BmobObject  *levelObject;
@property (nonatomic,strong) NSNumber    *level;
@property (nonatomic,strong) NSString    *title;
@property (nonatomic,strong) NSString    *content;
@property (nonatomic,strong) NSString    *videoURL;
@property (nonatomic,strong) NSString    *VIP;
@property (nonatomic,strong) NSString    *imgURL;
@property (nonatomic,strong) NSNumber    *praiseNum;
@property (nonatomic,strong) NSNumber    *rewardNum;
@property (nonatomic,assign) BOOL         isDeleted;
@property (nonatomic,strong) NSArray     *staticArray;
@property (nonatomic,strong) NSNumber    *viewedTimes;
@property (nonatomic,strong) NSArray     *commentList;
@property (nonatomic,strong) NSString    *createdAt;
@property (nonatomic,strong) NSString    *updatedAt;

+ (VideoModel *)initWithBmobObject:(BmobObject *)bmobObject;
+ (VideoModel *)initWithDic:(NSDictionary *)dic;
@end
