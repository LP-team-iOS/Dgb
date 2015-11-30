//
//  AdvertisementModel.m
//  duangongbangUser
//
//  Created by ljx on 15/3/17.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "AdvertisementModel.h"

@implementation AdvertisementModel

+ (AdvertisementModel *)initWithBmobObject:(BmobObject *)adModelDic{
    AdvertisementModel *model = [[self alloc] init];
    
    if (model != nil) {
        
        model.objectId = adModelDic.objectId;
        model.title = [adModelDic objectForKey:@"Title"];
        model.type = [adModelDic objectForKey:@"Type"];
        model.companyUser = [adModelDic objectForKey:@"CompanyUser"];
        model.companyUserId = model.companyUser.objectId;
        model.brief = [adModelDic objectForKey:@"Brief"];
        model.detail = [adModelDic objectForKey:@"Detail"];
        model.img = [adModelDic objectForKey:@"Img"];
        model.score = [adModelDic objectForKey:@"Score"];
        model.remainScore = [adModelDic objectForKey:@"RemainScore"];
        model.clickScore = [adModelDic objectForKey:@"ClickScore"];
        model.transmitNum = [adModelDic objectForKey:@"TransmitNum"];
        model.isConfirmed = [adModelDic objectForKey:@"IsConfirmed"];
        model.isDeleted = [adModelDic objectForKey:@"IsDeleted"];
        model.link = [adModelDic objectForKey:@"Link"];
        model.otherShowTimes = [adModelDic objectForKey:@"OtherShowTimes"];
        model.creatAt = adModelDic.createdAt
        ;
        model.updatedAt = adModelDic.updatedAt;
        
    }
    return model;
}

@end
