//
//  CommonServers.m
//  duangongbang
//
//  Created by ljx on 15/7/3.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "CommonServers.h"
#import <BmobSDK/BmobCloud.h>

@implementation CommonServers

#pragma mark - servers
+ (void)callAccountWithDict:(NSDictionary *)dict success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    NSDictionary *inputData = [NSDictionary dictionaryWithObject:dict forKey:@"inputData"];

    [BmobCloud callFunctionInBackground:kCloudAccount withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            success(object);
        }else{
            fail(kNetworkWarning);
            LOG(@"callAccounterror = %@",err);
        }
    }];
    
}
+ (void)callInitDataWithDict:(NSDictionary *)dict success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    NSDictionary *inputData = [NSDictionary dictionaryWithObject:dict forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:kCloudInit withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                success(object);
            }else{
                fail(kDataErrorWarning);
            }
        }else{
            fail(kNetworkWarning);
            LOG(@"getmaindataerror%@",err);
        }
    }];
    
}

+ (void)callCloudWithAPIName:(NSString *)apiName andDic:(NSDictionary *)dic success:(void (^)(id object))success fail:(void (^)(NSString *error))fail{

    NSDictionary *inputData = [NSDictionary dictionaryWithObject:dic forKey:@"inputData"];
    LOG(@"我的消息 = %@",inputData);
    [BmobCloud callFunctionInBackground:apiName withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                success(object);
            }else{
                fail(kDataErrorWarning);
            }
        }else{
            fail(kNetworkWarning);
            LOG(@"getListDataError%@",err);
        }
    }];
    


}

@end
