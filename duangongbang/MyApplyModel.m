//
//  MyApplyModel.m
//  duangongbang
//
//  Created by ljx on 15/10/22.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "MyApplyModel.h"

@implementation MyApplyModel
/**
 {
 "CompanyUserPhone": "",
 "Message": "您好，我的姓名是/%name/，刚在短工邦看到一条兼职信息/%title/，想问下还有位置吗？我想报名。",
 "OrderObjectUpdateTime": "2015-10-2017: 33: 41",
 "Static": "success",
 "Ticp1": "请直接联系商家",
 "Ticp2": "系统通知",
 "Ticp3": "该工作是电话报名或者发短信报名，请直接联系商家~",
 "Title": "【天猫商城】诚招双11客服兼职",
 "Value": "获取工作状态成功",
 "WorkOrderStatic": "TYPE_DIRECT"
 }
 */
+ (MyApplyModel *)initWithDic:(NSDictionary *)dic
{
    
    MyApplyModel *model = [[self alloc] init];
    
    if (model != nil) {
        model.ApplyWay              = [dic objectForKey:@"ApplyWay"];
        model.CompanyUserPhone      = [dic objectForKey:@"CompanyUserPhone"];
        model.Message               = [dic objectForKey:@"Message"];
        model.OrderObjectUpdateTime = [dic objectForKey:@"OrderObjectUpdateTime"];
        model.Static                = [dic objectForKey:@"Static"];
        model.Ticp1                 = [dic objectForKey:@"Ticp1"];
        model.Ticp2                 = [dic objectForKey:@"Ticp2"];
        model.Ticp3                 = [dic objectForKey:@"Ticp3"];
        model.Title                 = [dic objectForKey:@"Title"];
        model.Value                 = [dic objectForKey:@"Value"];
        model.WorkOrderStatic       = [dic objectForKey:@"WorkOrderStatic"];

    }
    
    return model;
}



@end
