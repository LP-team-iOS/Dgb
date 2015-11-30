//
//  UserCenterInfo.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/7/28.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UserCenterInfo.h"
#import "MJExtension.h"

@implementation UserCenterInfo

+ (UserCenterInfo *)initWithObject:(id)object{
    UserCenterInfo *userCenterInfo = [[UserCenterInfo alloc] init];
    if (userCenterInfo) {
        userCenterInfo.name = [object objectForKey:kResumeName];
        userCenterInfo.nickName = [object objectForKey:kResumeNickName];
        userCenterInfo.sex = [object objectForKey:kResumeSex];
        userCenterInfo.headImgUrl = [object objectForKey:kResumeHeadImgUrl];
        userCenterInfo.age = [NSString stringWithFormat:@"%@",[object objectForKey:kResumeAge]];
        userCenterInfo.height = [NSString stringWithFormat:@"%@",[object objectForKey:kResumeHeight]];
        userCenterInfo.schoolName = [object objectForKey:kResumeSchoolName];
        userCenterInfo.schoolObjectId = [object objectForKey:kResumeSchoolObjectId];
        userCenterInfo.intro = [object objectForKey:kResumeIntro];
        userCenterInfo.workExp = [object objectForKey:kResumeWorkExp];
        userCenterInfo.phone = [object objectForKey:kResumePhone];
        userCenterInfo.email = [object objectForKey:kResumeEmail];
        userCenterInfo.address = [object objectForKey:kResumeAdddress];
        userCenterInfo.areaName = [object objectForKey:kResumeAreaName];
        userCenterInfo.areaObjectId = [object objectForKey:kResumeAreaObjectId];
        userCenterInfo.VIP = [object objectForKey:kResumeVIP];
        userCenterInfo.userStatic = [object objectForKey:kResumeUserStatic];
        userCenterInfo.cityName = [object objectForKey:kResumeCityName];
        userCenterInfo.cityObjectId = [object objectForKey:kResumeAreaObjectId];
        userCenterInfo.freeDays = [object objectForKey:kResumeFreeDays];
        userCenterInfo.lv = [object objectForKey:kResumeLv];
    }
    return  userCenterInfo;
}

MJCodingImplementation

@end
