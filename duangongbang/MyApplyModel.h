//
//  MyApplyModel.h
//  duangongbang
//
//  Created by ljx on 15/10/22.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyApplyModel : NSObject
@property (nonatomic,copy) NSString *ApplyWay;
@property (nonatomic,copy) NSString *CompanyUserPhone;
@property (nonatomic,copy) NSString *Message;
@property (nonatomic,copy) NSString *OrderObjectUpdateTime;
@property (nonatomic,copy) NSString *Static;
@property (nonatomic,copy) NSNumber *Ticp1;
@property (nonatomic,copy) NSNumber *Ticp2;
@property (nonatomic,copy) NSString *Ticp3;
@property (nonatomic,copy) NSString *Title;
@property (nonatomic,copy) NSString *Value;
@property (nonatomic,copy) NSString *WorkOrderStatic;

+(MyApplyModel *)initWithDic:(NSDictionary *)dic;
@end
