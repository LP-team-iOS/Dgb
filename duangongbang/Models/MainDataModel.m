//
//  MainDataModel.m
//  duangongbang
//
//  Created by ljx on 15/5/22.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "MainDataModel.h"
#import "MJExtension.h"

#define kArea @"Area"
#define kClassify @"Classify"
#define kHi @"Hi"
#define kIndexBackgroup @"IndexBackground"
#define kIndexBackgroupCount @"IndexBackgroundCount"
#define kPPTCount @"PPTCount"
#define kPPTList @"PPTList"
#define kPPTType @"PPTType"
#define kStateStatic @"Static"
#define kName @"Name"
#define kValue @"Value"
#define kWorkList @"WorkList"
#define kCustomRule @"CustomRule"

@implementation MainDataModel

+ (MainDataModel *)initMainDataWithDic:(NSDictionary *)dic{
    MainDataModel *mainDataModel = [[MainDataModel alloc] init];
    
    if (mainDataModel != nil) {
        mainDataModel.area = [dic objectForKey:kArea];
        mainDataModel.classify = [dic objectForKey:kClassify];
        mainDataModel.hi = [dic objectForKey:kHi];
        mainDataModel.indexBackgroup = [dic objectForKey:kIndexBackgroup];
        mainDataModel.indexBackgroupCount = [dic objectForKey:kIndexBackgroupCount];
        mainDataModel.pptCount = [dic objectForKey:kPPTCount];
        mainDataModel.pptList = [dic objectForKey:kPPTList];
        mainDataModel.pptType = [dic objectForKey:kPPTType];
        mainDataModel.stateStatic = [dic objectForKey:kStateStatic];
        mainDataModel.name = [dic objectForKey:kName];
        mainDataModel.value = [dic objectForKey:kValue];
        mainDataModel.workList = [dic objectForKey:kWorkList];
        mainDataModel.customRule = [dic objectForKey:kCustomRule];
    }
    
    return mainDataModel;
}

MJCodingImplementation

//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self.area = [aDecoder decodeObjectForKey:kArea];
//    self.classify = [aDecoder decodeObjectForKey:kClassify];
//    self.hi = [aDecoder decodeObjectForKey:kHi];
//    self.indexBackgroup = [aDecoder decodeObjectForKey:kIndexBackgroup];
//    self.indexBackgroupCount = [aDecoder decodeObjectForKey:kIndexBackgroupCount];
//    self.pptCount = [aDecoder decodeObjectForKey:kPPTCount];
//    self.pptList = [aDecoder decodeObjectForKey:kPPTList];
//    self.pptType = [aDecoder decodeObjectForKey:kPPTType];
//    self.stateStatic = [aDecoder decodeObjectForKey:kStateStatic];
//    self.name = [aDecoder decodeObjectForKey:kName];
//    self.value = [aDecoder decodeObjectForKey:kValue];
//    self.workList = [aDecoder decodeObjectForKey:kWorkList];
//    self.customRule = [aDecoder decodeObjectForKey:kCustomRule];
//    return self;
//    
//}
//
//-(void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeObject:self.area forKey:kArea];
//    [aCoder encodeObject:self.classify forKey:kClassify];
//    [aCoder encodeObject:self.hi forKey:kHi];
//    [aCoder encodeObject:self.indexBackgroup forKey:kIndexBackgroup];
//    [aCoder encodeObject:self.indexBackgroupCount forKey:kIndexBackgroupCount];
//    [aCoder encodeObject:self.pptCount forKey:kPPTCount];
//    [aCoder encodeObject:self.pptList forKey:kPPTList];
//    [aCoder encodeObject:self.pptType forKey:kPPTType];
//    [aCoder encodeObject:self.stateStatic forKey:kStateStatic];
//    [aCoder encodeObject:self.name forKey:kName];
//    [aCoder encodeObject:self.value forKey:kValue];
//    [aCoder encodeObject:self.workList forKey:kWorkList];
//    [aCoder encodeObject:self.customRule forKey:kCustomRule];
//}
@end
