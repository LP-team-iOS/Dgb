//
//  UserCenterInfo.h
//  duangongbang
//
//  Created by Chen Haochuan on 15/7/28.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kResumeSchoolName @"SchoolName"
#define kResumeSchoolObjectId @"SchoolObjectId"
#define kResumeEmail @"Email"
#define kResumeAdddress @"Address"
#define kResumeHeadImgUrl @"HeadImgURL"
#define kResumeIntro @"Intro"
#define kResumeWorkExp @"WorkExp"
#define kResumeAreaName @"AreaName"
#define kResumeAreaObjectId @"AreaObjectId"
#define kResumeVIP @"VIP"
#define kResumeSex @"Sex"
#define kResumeAge @"Age"
#define kResumeHeight @"Height"
#define kResumePhone @"Phone"
#define kResumeNickName @"Nickname"
#define kResumeName @"Name"
#define kResumeLv @"Lv"
#define kResumeUserStatic @"UserStatic"
#define kResumeCityObjectId @"CityObjectId"
#define kResumeCityName @"CityName"
#define kResumeCustom @"Custom"
#define kResumeFreeDays @"FreeDays"

@interface UserCenterInfo : NSObject <NSCoding>

@property (nonatomic, weak) NSString *schoolName;
@property (nonatomic, weak) NSString *schoolObjectId;
@property (nonatomic, weak) NSString *email;
@property (nonatomic, weak) NSString *address;
@property (nonatomic, weak) NSString *headImgUrl;
@property (nonatomic, weak) NSString *intro;
@property (nonatomic, weak) NSString *workExp;
@property (nonatomic, weak) NSString *areaName;
@property (nonatomic, weak) NSString *areaObjectId;
@property (nonatomic, weak) NSString *VIP;
@property (nonatomic, weak) NSString *sex;
@property (nonatomic, weak) NSString *age;
@property (nonatomic, weak) NSString *height;
@property (nonatomic, weak) NSString *phone;
@property (nonatomic, weak) NSString *nickName;
@property (nonatomic, weak) NSString *name;
@property (nonatomic, weak) NSString *lv;
@property (nonatomic, weak) NSArray *userStatic;
@property (nonatomic, weak) NSString *cityName;
@property (nonatomic, weak) NSString *cityObjectId;
@property (nonatomic, weak) NSString *custom;
@property (nonatomic, weak) NSArray *freeDays;

+ (UserCenterInfo *)initWithObject:(id)object;

@end
