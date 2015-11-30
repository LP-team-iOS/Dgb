//
//  JobTableViewCell.m
//  NewDGCell
//
//  Created by 123 on 15/4/23.
//  Copyright (c) 2015年 123. All rights reserved.
//

#import "JobTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+Extension.h"
#import "Masonry/Masonry.h"
#import "pop/pop.h"
@interface JobTableViewCell()
{
    NSMutableArray *VipArray;
    UIView *vipView;
}
@end

@implementation JobTableViewCell

- (void)awakeFromNib {

    vipView = [[UIView alloc]init];
    [self.contentView addSubview:vipView];
    [vipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_lbPayUnit.mas_right).with.offset(16);
        make.top.equalTo(self.contentView.mas_top).with.offset(40);
        make.size.equalTo(CGSizeMake(120, 9));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdbdbdb);

}

- (void)setAllFrameWithWork:(id)dic {

    NSNumber *pass = [dic objectForKey:@"PassNum"];
    NSNumber *need = [dic objectForKey:@"NeedNum"];
    
    _lbWorkTitle.text = [dic objectForKey:@"Title"];
    _lbWorkPlace.text =[dic objectForKey:@"StreetName"];
    _lbReleaseTime.text =[self getUTCFormateDate:[[dic objectForKey:@"createdAt"] substringToIndex:16]];
    
    if ([[dic objectForKey:@"ViewedTimes"] intValue] > 999) {
        _lbLikeNum.text = @"999+";
    }else {
        _lbLikeNum.text =[NSString stringWithFormat:@"%@",[dic objectForKey:@"ViewedTimes"]];
    }
    _lbWorkType.text =[dic objectForKey:@"ClassifyName"];
    _lbNum.text = [dic objectForKey:@"PersonNumStr"];
    _lbPayUnit.text =[dic objectForKey:@"Price"];
    
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop){
        prop.writeBlock = ^(id obj, const CGFloat value[]) {
            _progress.progress = (float)value[0] / [need floatValue];
        };
    }];
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];   //秒表当然必须是线性的时间函数
    anBasic.property = prop;    //自定义属性
    anBasic.fromValue = @(0);   //从0开始
    anBasic.toValue = @([pass floatValue]);  //
    anBasic.duration = kProgressTime;    //持续1.2s
    //anBasic.beginTime = CACurrentMediaTime() + 1.0f;    //延迟1秒开始
    [_progress pop_addAnimation:anBasic forKey:@"progress"];
    /**vip接口
     *  TagList=({
            Color="#ffa800";
            ImgUrl="http://file.bmob.cn/M02/9C/21/oYYBAFZJVW2AWg0lAABHodgi-00371.png";
            Name="\U8ba4\U8bc1";
            });
     */

    VipArray = [[NSMutableArray alloc]initWithArray:[dic objectForKey:@"TagList"]];
    for (UIView *views in vipView.subviews) {
        [views removeFromSuperview];
    }
    
    if (VipArray.count != 0) {
        for (int i = 0; i < VipArray.count ; i ++) {
            
            UIImageView *iconImg = [[UIImageView alloc]init];
            [vipView addSubview:iconImg];
            NSDictionary *dictionary = [[NSDictionary alloc]initWithDictionary:[VipArray objectAtIndex:i]];
            NSURL *url = [NSURL URLWithString:[dictionary objectForKey:@"ImgUrl"]];
            [iconImg sd_setImageWithURL:url];
            [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vipView.mas_left).with.offset(40*i);
                make.top.equalTo(vipView.mas_top).with.offset(0);
                make.size.equalTo(CGSizeMake(9, 9));
            }];
            
            UILabel *iconLabel = [[UILabel alloc]init];
            [vipView addSubview:iconLabel];
            UIColor *color = [UIColor colorWithHexString:[VipArray[i]objectForKey:@"Color"]];
            iconLabel.text = [VipArray[i]objectForKey:@"Name"];
            iconLabel.textColor = color;
            iconLabel.font = [UIFont systemFontOfSize:10];
            [iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vipView.mas_left).with.offset(12 + 40*i);
                make.top.equalTo(vipView.mas_top).with.offset(0);
                make.size.equalTo(CGSizeMake(20, 9));
            }];

            }
    }

}

//传入bmobObject或者dic
- (void)setAllFrameWithWorkList:(id)dic{
    
    NSNumber *pass = [dic objectForKey:@"PassNum"];
    NSNumber *need = [dic objectForKey:@"NeedNum"];
    
    _lbWorkTitle.text = [dic objectForKey:@"Title"];//
    _lbWorkPlace.text =[dic objectForKey:@"StreetName"];//
    _lbReleaseTime.text =[self getUTCFormateDate:[[dic objectForKey:@"createdAt"] substringToIndex:16]];
    
    if ([[dic objectForKey:@"ViewedTimes"] intValue] > 999) {
        _lbLikeNum.text = @"999+";
    }else {
        _lbLikeNum.text =[NSString stringWithFormat:@"%@",[dic objectForKey:@"ViewedTimes"]];
    }
    
    _lbWorkType.text =[dic objectForKey:@"ClassifyName"];
    _lbNum.text = [dic objectForKey:@"PersonNumStr"];
    _lbPayUnit.text =[dic objectForKey:@"PriceAndUnit"];
    
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop){
        prop.writeBlock = ^(id obj, const CGFloat value[]) {
            _progress.progress = (float)value[0] / [need floatValue];
        };
    }];
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];   //秒表当然必须是线性的时间函数
    anBasic.property = prop;    //自定义属性
    anBasic.fromValue = @(0);   //从0开始
    anBasic.toValue = @([pass floatValue]);  //
    anBasic.duration = kProgressTime;    //持续1.2s
    //anBasic.beginTime = CACurrentMediaTime() + 1.0f;    //延迟1秒开始
    [_progress pop_addAnimation:anBasic forKey:@"progress"];
    
    VipArray = [[NSMutableArray alloc]initWithArray:[dic objectForKey:@"TagList"]];
    for (UIView *views in vipView.subviews) {
        [views removeFromSuperview];
    }
    
    if (VipArray.count != 0) {
        for (int i = 0; i < VipArray.count ; i ++) {
            
            UIImageView *iconImg = [[UIImageView alloc]init];
            [vipView addSubview:iconImg];
            NSDictionary *dictionary = [[NSDictionary alloc]initWithDictionary:[VipArray objectAtIndex:i]];
            NSURL *url = [NSURL URLWithString:[dictionary objectForKey:@"ImgUrl"]];
            [iconImg sd_setImageWithURL:url];
            [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vipView.mas_left).with.offset(40*i);
                make.top.equalTo(vipView.mas_top).with.offset(0);
                make.size.equalTo(CGSizeMake(10, 10));
            }];
            
            UILabel *iconLabel = [[UILabel alloc]init];
            [vipView addSubview:iconLabel];
            UIColor *color = [UIColor colorWithHexString:[VipArray[i]objectForKey:@"Color"]];
            iconLabel.text = [VipArray[i]objectForKey:@"Name"];
            iconLabel.textColor = color;
            iconLabel.font = [UIFont systemFontOfSize:10];
            [iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vipView.mas_left).with.offset(12 + 40*i);
                make.top.equalTo(vipView.mas_top).with.offset(0);
                make.size.equalTo(CGSizeMake(20, 10));
            }];
        }
    }

}

- (void)setAllFrameWithBmobObject:(BmobObject *)obj{
    
    NSNumber *pass = (NSNumber *)[obj objectForKey:@"PassNum"];
    NSNumber *need = (NSNumber *)[obj objectForKey:@"NeedNum"];
    
    _lbWorkTitle.text = [obj objectForKey:@"Title"];
    _lbWorkPlace.text =[[obj objectForKey:@"Street"] objectForKey:@"StreetName"];
    
    _lbReleaseTime.text =[self getUTCFormateDate:[[NSString stringWithFormat:@"%@",obj.createdAt] substringToIndex:16]];
    
    if ([[obj objectForKey:@"ViewedTimes"] intValue] > 999) {
        _lbLikeNum.text = @"999+";
    }else {
        _lbLikeNum.text =[NSString stringWithFormat:@"%@",[obj objectForKey:@"ViewedTimes"]];
    }
    _lbWorkType.text =[[obj objectForKey:@"Classify"] objectForKey:@"ClassifyName"];
    _lbNum.text =[NSString stringWithFormat:@"已联系%d/名额%d",[pass intValue],[need intValue]];
    _lbPayUnit.text =[NSString stringWithFormat:@"%@ %@",[obj objectForKey:@"Price"],[obj objectForKey:@"PriceUnit"]];
    
    if ([(NSArray *)[[[obj objectForKey:@"Work"] objectForKey:@"CompanyUser"] objectForKey:@"Static"] containsObject:@"VIP"]){
        _imgBigV.image = [UIImage imageNamed:@"黄色V"];
    }else{
        _imgBigV.image = nil;
    }

}

- (void)setSearchModelWithWork:(NSDictionary *)dic
{
    
    NSNumber *pass = [dic objectForKey:@"PassNum"];
    NSNumber *need = [dic objectForKey:@"NeedNum"];
    
    _lbWorkTitle.text = [dic objectForKey:@"Title"];//
    _lbWorkPlace.text =[dic objectForKey:@"StreetName"];//
    _lbReleaseTime.text =[self getUTCFormateDate:[[dic objectForKey:@"createdAt"] substringToIndex:16]];
    
    if ([[dic objectForKey:@"ViewedTimes"] intValue] > 999) {
        _lbLikeNum.text = @"999+";
    }else {
        _lbLikeNum.text =[NSString stringWithFormat:@"%@",[dic objectForKey:@"ViewedTimes"]];
    }
    
    _lbWorkType.text =[dic objectForKey:@"ClassifyName"];
    _lbNum.text = [dic objectForKey:@"PersonNumStr"];
    _lbPayUnit.text =[dic objectForKey:@"PriceAndUnit"];
    
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop){
        prop.writeBlock = ^(id obj, const CGFloat value[]) {
            _progress.progress = (float)value[0] / [need floatValue];
        };
    }];
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];   //秒表当然必须是线性的时间函数
    anBasic.property = prop;    //自定义属性
    anBasic.fromValue = @(0);   //从0开始
    anBasic.toValue = @([pass floatValue]);  //
    anBasic.duration = kProgressTime;    //持续1.2s
    //anBasic.beginTime = CACurrentMediaTime() + 1.0f;    //延迟1秒开始
    [_progress pop_addAnimation:anBasic forKey:@"progress"];
    
    VipArray = [[NSMutableArray alloc]initWithArray:[dic objectForKey:@"TagList"]];
    for (UIView *views in vipView.subviews) {
        [views removeFromSuperview];
    }
    if (VipArray.count != 0) {
        for (int i = 0; i < VipArray.count ; i ++) {
            
            UIImageView *iconImg = [[UIImageView alloc]init];
            [vipView addSubview:iconImg];
            NSDictionary *dictionary = [[NSDictionary alloc]initWithDictionary:[VipArray objectAtIndex:i]];
            NSURL *url = [NSURL URLWithString:[dictionary objectForKey:@"ImgUrl"]];
            [iconImg sd_setImageWithURL:url];
            [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vipView.mas_left).with.offset(40*i);
                make.top.equalTo(vipView.mas_top).with.offset(0);
                make.size.equalTo(CGSizeMake(10, 10));
            }];
            
            UILabel *iconLabel = [[UILabel alloc]init];
            [vipView addSubview:iconLabel];
            UIColor *color = [UIColor colorWithHexString:[VipArray[i]objectForKey:@"Color"]];
            iconLabel.text = [VipArray[i]objectForKey:@"Name"];
            iconLabel.textColor = color;
            iconLabel.font = [UIFont systemFontOfSize:10];
            [iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(vipView.mas_left).with.offset(12 + 40*i);
                make.top.equalTo(vipView.mas_top).with.offset(0);
                make.size.equalTo(CGSizeMake(20, 10));
            }];
        }
    }

}

- (NSString *)getUTCFormateDate:(NSString *)newsDate
{

    //    newsDate = @"2013-08-09 17:01";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *newsDateFormatted = [dateFormatter dateFromString:newsDate];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate* current_date = [NSDate date];
    
    NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数

    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    
    NSString *dateContent;
    
    if(month!=0){
        if (hours < 0) {
            dateContent = [NSString stringWithFormat:@"%@30%@",@"",@"秒前"];
        }else {
            dateContent = [NSString stringWithFormat:@"%@%i%@",@"",month,@"个月前"];
        }
//        dateContent = [NSString stringWithFormat:@"%@%i%@",@"",month,@"个月前"];
        
    }else if(days!=0){
        if (hours < 0) {
            dateContent = [NSString stringWithFormat:@"%@30%@",@"",@"秒前"];
        }else {
            dateContent = [NSString stringWithFormat:@"%@%i%@",@"",days,@"天前"];
        }
//        dateContent = [NSString stringWithFormat:@"%@%i%@",@"",days,@"天前"];
    }else if(hours!=0){
        if (hours < 0) {
            dateContent = [NSString stringWithFormat:@"%@30%@",@"",@"秒前"];
        }else {
            dateContent = [NSString stringWithFormat:@"%@%i%@",@"",hours,@"小时前"];
        }
    }else {
        if (minute < 0) {
            dateContent = [NSString stringWithFormat:@"%@30%@",@"",@"秒前"];
        }else {
            dateContent = [NSString stringWithFormat:@"%@%i%@",@"",minute,@"分钟前"];
        }
    }
    
    return dateContent;
}

@end
