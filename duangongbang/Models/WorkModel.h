
#import <Foundation/Foundation.h>
#import <BmobSDK/BmobObject.h>
#import <BmobSDK/BmobUser.h>
//WorkList表的Key
#define kWorkTitle  @"WorkTitle"

@interface WorkModel : NSObject
@property (nonatomic,strong) NSString    *workOrderId;
@property (nonatomic,strong) NSString    *objectId;
@property (nonatomic,strong) NSString    *title;
@property (nonatomic,strong) BmobUser    *companyUser;
@property (nonatomic,strong) NSString    *companyUserId;
@property (nonatomic,strong) NSString    *companyUserName;
@property (nonatomic,strong) NSString    *companyUserPhone;
@property (nonatomic,strong) NSString    *message;
@property (nonatomic,strong) NSString    *applyKnowNormal;
@property (nonatomic,strong) NSString    *applyKnowRed;
@property (nonatomic,strong) BmobObject  *classify;
@property (nonatomic,strong) NSString    *classifyId;
@property (nonatomic,strong) NSString    *classifyName;
@property (nonatomic,strong) NSString    *sex;
@property (nonatomic,strong) NSString    *payMethod;
@property (nonatomic,strong) NSNumber    *praiseCount;
@property (nonatomic,strong) NSString    *headImgUrl;
@property (nonatomic,strong) UIImage     *headImg;
@property (nonatomic,strong) BmobObject  *area;
@property (nonatomic,strong) NSString    *areaId;
@property (nonatomic,strong) NSString    *areaName;
@property (nonatomic,strong) NSString    *place;
@property (nonatomic,strong) NSNumber    *price;
@property (nonatomic,strong) NSString    *priceAndUnit;
@property (nonatomic,strong) NSString    *priceUnit;
@property (nonatomic,strong) NSNumber    *needNum;
@property (nonatomic,strong) NSNumber    *passNum;
@property (nonatomic,strong) NSString    *progress;
@property (nonatomic,strong) NSArray     *skill;
@property (nonatomic,strong) NSArray     *pay;
@property (nonatomic,strong) NSNumber    *viewedTimes;
@property (nonatomic,strong) BmobObject  *street;
@property (nonatomic,strong) NSString    *streetObjectId;
@property (nonatomic,strong) NSString    *streetName;
@property (nonatomic,strong) NSArray     *workDate;
@property (nonatomic,assign) BOOL         isDeleted;
@property (nonatomic,assign) BOOL         showWorkDate;
@property (nonatomic,strong) NSString    *deal;
@property (nonatomic,strong) NSString    *applyWay;
@property (nonatomic,strong) NSNumber    *applyNumber;
@property (nonatomic,strong) id          content;
@property (nonatomic,strong) NSArray     *commentList;
@property (nonatomic,strong) NSString    *textClickNotic;
@property (nonatomic,strong) NSString    *textPersonNumStr;
@property (nonatomic,strong) NSString    *vip;
@property (nonatomic,strong) NSString    *workObjectId;
@property (nonatomic,strong) NSString    *workDateStr;
@property (nonatomic,strong) NSString    *createdAt;
@property (nonatomic,strong) NSDate      *updatedAt;
@property (nonatomic,strong) NSString    *hot;
//对应的所以workNotice
@property (nonatomic,strong) NSArray     *workNoticeArray;
+(WorkModel*)initWithBmobObject:(BmobObject *)workListModelDic;

+(WorkModel *)initWithDic:(NSDictionary *)dic;
@end
