//
//  UserModel.h
//  duangongbangUser
//
//  Created by ljx on 15/4/5.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/BmobObject.h>
#import <BmobSDK/BmobUser.h>

@interface UserModel : NSObject

@property (nonatomic,strong) NSString *objectId;
@property (nonatomic,strong) NSString *userName;

@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSNumber *age;
@property (nonatomic,strong) NSNumber *height;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) BmobObject *area;
@property (nonatomic,strong) NSString *areaName;
@property (nonatomic,strong) NSString *intro;

+ (UserModel*)initIntroWithBmobUser:(BmobObject *)bmobUser;

@end
