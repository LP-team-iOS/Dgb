
#import "WorkModel.h"
#import <BmobSDK/BmobObject.h>

@implementation WorkModel

+(WorkModel*)initWithBmobObject:(BmobObject *)workListModelDic
{
    
    WorkModel *model=[[self alloc]init];
    
    if(model!=nil)
    {
        model.objectId=workListModelDic.objectId;
        model.title=[workListModelDic objectForKey:@"Title"];
        model.companyUser = [workListModelDic objectForKey:@"CompanyUser"];
        model.companyUserId = model.companyUser.objectId;
        model.classify = [workListModelDic objectForKey:@"Classify"];
        model.classifyId = model.classify.objectId;
        model.classifyName = [model.classify objectForKey:@"ClassifyName"];
        model.sex=[workListModelDic objectForKey:@"Sex"];
        model.payMethod=[workListModelDic objectForKey:@"PayMethod"];
        model.area = [workListModelDic objectForKey:@"Area"];
        model.areaId = model.area.objectId;
        model.areaName = [model.area objectForKey:@"AreaName"];
        model.place=[workListModelDic objectForKey:@"Place"];
        model.price=[workListModelDic objectForKey:@"Price"];
        model.priceUnit=[workListModelDic objectForKey:@"PriceUnit"];
        model.needNum=[workListModelDic objectForKey:@"NeedNum"];
        model.passNum=[workListModelDic objectForKey:@"PassNum"];
        model.progress=[workListModelDic objectForKey:@"Progress"];
        model.skill=[workListModelDic objectForKey:@"Skill"];
        model.pay=[workListModelDic objectForKey:@"Pay"];
        model.viewedTimes=[workListModelDic objectForKey:@"ViewedTimes"];
        model.street=[workListModelDic objectForKey:@"Street"];
        model.streetObjectId = model.street.objectId;
        model.workDate=[workListModelDic objectForKey:@"WorkDate"];
        
        model.message = [workListModelDic objectForKey:@"Message"];
        model.content = [workListModelDic objectForKey:@"Content"];
        model.deal = [workListModelDic objectForKey:@"Deal"];
        model.applyWay = [workListModelDic objectForKey:@"ApplyWay"];
        
        model.applyNumber = [workListModelDic objectForKey:@"ApplyNum"];
        model.isDeleted =[[workListModelDic objectForKey:@"IsDeleted"]boolValue];
        
        
        model.createdAt =[NSString stringWithFormat:@"%@",[workListModelDic objectForKey:@"createdAt"]];
        model.updatedAt = workListModelDic.updatedAt;
    }
    return model;
}

+ (WorkModel *)initWithDic:(NSDictionary *)dic{
    WorkModel *model=[[self alloc]init];
    if (model!=nil) {
        model.applyKnowNormal  = [dic objectForKey:@"ApplyKnowNormal"];
        model.applyKnowRed     = [dic objectForKey:@"ApplyKnowRed"];
        model.applyWay         = [dic objectForKey:@"ApplyWay"];
        model.classifyName     = [dic objectForKey:@"ClassifyName"];
        model.commentList      = [dic objectForKey:@"CommentList"];
        model.companyUserName  = [dic objectForKey:@"CompanyUserName"];
        model.companyUserId    = [dic objectForKey:@"CompanyUserObjectId"];
        model.companyUserPhone = [dic objectForKey:@"CompanyUserPhone"];
        model.content          = [dic objectForKey:@"Content"];
        model.createdAt        = [dic objectForKey:@"createdAt"];
        model.headImgUrl       = [dic objectForKey:@"HeadImg"];
        model.message          = [dic objectForKey:@"Message"];
        model.needNum          = [dic objectForKey:@"NeedNum"];
        model.passNum          = [dic objectForKey:@"PassNum"];
        model.payMethod        = [dic objectForKey:@"PayMethod"];
        model.praiseCount      = [dic objectForKey:@"PraiseCount"];
        model.price            = [dic objectForKey:@"Price"];
        model.priceAndUnit     = [dic objectForKey:@"PriceAndUnit"];
        model.progress         = [dic objectForKey:@"Progress"];
        model.sex              = [dic objectForKey:@"Sex"];
        model.showWorkDate     = [[dic objectForKey:@"ShowWorkDate"] boolValue];
        model.streetName       = [dic objectForKey:@"StreetName"];
        model.textClickNotic   = [dic objectForKey:@"TextClickNotic"];
        model.textPersonNumStr = [dic objectForKey:@"TextPersonNumStr"];
        model.title            = [dic objectForKey:@"Title"];
        model.viewedTimes      = [dic objectForKey:@"ViewedTimes"];
        model.vip              = [dic objectForKey:@"Vip"];
        model.workDate         = [dic objectForKey:@"WorkDate"];
        model.workDateStr      = [dic objectForKey:@"WorkDateStr"];
        model.workObjectId     = [dic objectForKey:@"WorkObjectId"];
        model.hot              = [dic objectForKey:@"Hot"];
        model.objectId         = [dic objectForKey:@"objectId"];
        model.workOrderId      = [dic objectForKey:@"WorkOrderObjectId"];
    }
    
    
    return  model;
}

@end
