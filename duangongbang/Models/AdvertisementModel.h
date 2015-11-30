//
//  AdvertisementModel.h
//  duangongbangUser
//
//  Created by ljx on 15/3/17.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobObject.h>
#import <BmobSDK/BmobFile.h>

@interface AdvertisementModel : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) BmobUser *companyUser;
@property (strong, nonatomic) NSString *companyUserId;
@property (strong, nonatomic) NSString *brief;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) BmobFile *img;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSNumber *remainScore;
@property (strong, nonatomic) NSNumber *clickScore;
@property (strong, nonatomic) NSNumber *transmitNum;
@property (strong, nonatomic) NSNumber *isConfirmed;
@property (strong, nonatomic) NSNumber *isDeleted;
@property (strong, nonatomic) NSString *link;
@property (strong, nonatomic) NSNumber *otherShowTimes;
@property (strong, nonatomic) NSDate   *creatAt;
@property (strong, nonatomic) NSDate   *updatedAt;

@property (strong, nonatomic) NSArray *advertisementArray;

+ (AdvertisementModel *)initWithBmobObject:(BmobObject *)adModelDic;

@end
