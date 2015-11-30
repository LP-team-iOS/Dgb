//
//  MainDataModel.h
//  duangongbang
//
//  Created by ljx on 15/5/22.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainDataModel : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *area;
@property (nonatomic, strong) NSArray *classify;
@property (nonatomic, strong) NSString *hi;
@property (nonatomic, strong) NSString *indexBackgroup;
@property (nonatomic, strong) NSNumber *indexBackgroupCount;
@property (nonatomic, strong) NSNumber *pptCount;
@property (nonatomic, strong) NSArray *pptList;
@property (nonatomic, strong) NSNumber *pptType;
@property (nonatomic, strong) NSString *stateStatic;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSArray *workList;
@property (nonatomic, strong) NSString *customRule;

+ (MainDataModel *)initMainDataWithDic:(NSDictionary *)dic;

@end
