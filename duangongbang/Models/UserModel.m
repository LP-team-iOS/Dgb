//
//  UserModel.m
//  duangongbangUser
//
//  Created by ljx on 15/4/5.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UserModel.h"

#define kUserName    @"username"
#define kNickName    @"Nickname"
#define kName        @"Name"
#define kAge         @"Age"
#define kHeight      @"Height"
#define kSex         @"Sex"
#define kPhone       @"Phone"
#define kMail        @"Email"
#define kAddress     @"Address"
#define kArea        @"Area"
#define kAreaName    @"AreaName"
#define kIntro       @"Intro"

@implementation UserModel

+ (UserModel *)initIntroWithBmobUser:(BmobObject *)bmobUser{
    
    UserModel *model = [[self alloc] init];
    
    if (model != nil) {
        model.userName = [bmobUser objectForKey:kUserName];
        model.nickName = [bmobUser objectForKey:kNickName];
        model.name = [bmobUser objectForKey:kName];
        model.age = [bmobUser objectForKey:kAge];
        model.height = [bmobUser objectForKey:kHeight];
        model.sex = [bmobUser objectForKey:kSex];
        model.phone = [bmobUser objectForKey:kPhone];
        model.email = [bmobUser objectForKey:kMail];
        model.address = [bmobUser objectForKey:kAddress];
        model.area = [bmobUser objectForKey:kArea];
            model.areaName = [model.area objectForKey:kAreaName];
        
        model.intro = [bmobUser objectForKey:kIntro];
    }
    
    return model;
}

@end
