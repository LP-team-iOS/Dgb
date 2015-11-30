//
//  MessageViewController.m
//  duangongbang
//
//  Created by ljx on 15/10/28.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "MessageViewController.h"
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "WorkNewsViewController.h"
#import "CommentNewsViewController.h"
#import "ConsultingViewController.h"
#import "LoginViewController.h"
#import "DirectSupportAcceptedViewController.h"
#import "MyApplyViewController.h"

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,IChatManagerDelegate,RemoveRed>
{
    
    UITableView * Messagetabview;
    NSMutableDictionary *inputDataDic;
    NSMutableDictionary * data;
    BmobUser *bUser;
    NSDictionary *inputData;
    UIButton * yuan1;
    UIButton * yuan2;
    UIButton * yuan3;
    UIButton * yuan4;
    UIView * SuccessRed;
    //    UIView * ApplyingRed;
    UIView * CheckedRed;
    UIView * RejectRed;
    UIImageView * line;
    UIView * views;
    UIView * viewx;
    
    
    UIImageView *img2;
    UILabel * labtitle2;
    UILabel * labetext2;
    UILabel * time2;
    UIView * red2;
    
    UIImageView *img1;
    UILabel * labtitle1;
    UILabel * labetext1;
    UILabel * time1;
    UIView * red1;
    
    UIView * lineview3;
    UIImageView *img3;
    UILabel * labtitle3;
    UILabel * labetext3;
    UILabel * time3;
    UIView * red3;
    
    
    UIImageView *img4;
    UILabel * labtitle4;
    UILabel * labetext4;
    UILabel * time4;
    UIView * red4;
    
    UIImageView * nodataimage;
    
}

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    //导航栏的配置
    self.navigationItem.title = @"消息中心";
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //tabview的初始化
    Messagetabview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,Width, Height - 49)];
    Messagetabview.dataSource = self;
    Messagetabview.delegate  = self;
    Messagetabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    Messagetabview.backgroundColor = RGB(243, 243, 243, 1.0);
    [self.view addSubview:Messagetabview];
    
    //上白条
    UIView * v = [[UIView alloc] initWithFrame:CGRectMake(0, - 300, Width, 300)];
    v.backgroundColor = [UIColor whiteColor];
    [Messagetabview addSubview:v];
    
    //下拉刷新
    MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    Messagetabview.mj_header = header;
    
    //菊花转也转
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];
    
    //数据数组的初始化
    data = [NSMutableDictionary dictionary];
    
    //inputData:{"inputData":{"Version":"324","UserType":"User","ToUserObjectId":"61acc57699","Type":"MessageCenter"}}
    //    NSLog(@"--%@",[[[bUser objectForKey:@"date"] objectAtIndex:0] objectForKey:@"UserType"]);
    
    inputDataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    kUser,kUserType,
                    bUser ? bUser.objectId : @"" ,kToUserObjectId,
                    kMessageCenter,kType,
                    kCloudVersion,kVersion,
                    @"0",kskip,
                    nil];
    
    nodataimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data"]];
    nodataimage.frame = CGRectMake(Width/2 - 62.5, Height/2 - 62.5 - 65, 125, 125);
    [self.view addSubview:nodataimage];
    //    nodataimage.hidden = YES;
    
    //防止网络卡，菊花一直转
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    //请求数据
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        [timer invalidate];
        if (obj) {
//            [data addEntriesFromDictionary:obj];
//            
//            if(data.count > 2){
//                nodataimage.hidden = YES;
//            }else
//            {
//                nodataimage.hidden = NO;
//            }
            [SVProgressHUD dismiss];
            [Messagetabview reloadData];
        }
    }fail:^(NSString *err){
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark - 数据刷新

- (void)loadNewData
{
    
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    [inputDataDic setObject:bUser ? bUser.objectId : @"" forKey:kToUserObjectId];
    
    
    [Messagetabview.mj_header beginRefreshing];
    
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        
        //取消计时器
        [timer invalidate];
        
        if (obj) {
            
            if (data) {
                [data removeAllObjects];
            }
            
            [data addEntriesFromDictionary:obj];
            [SVProgressHUD showSuccessWithStatus:@"刷新成功啦!"];
            if(data.count != 0){
                nodataimage.hidden = YES;
            }else
            {
                nodataimage.hidden = NO;
            }
            
            [Messagetabview reloadData];
            [Messagetabview.mj_header endRefreshing];
        }
    }fail:^(NSString *err){
        [SVProgressHUD showErrorWithStatus:@"刷新失败,请检测下网络吧"];
        [Messagetabview.mj_header endRefreshing];
        [SVProgressHUD dismiss];
        
    }];
}

#pragma mark - 刷新或者上拉加载超时
//刷新或者上拉加载超时
- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [Messagetabview.mj_header endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请检查下您的网络~" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
}

#pragma mark - 请求数据回调

- (void)getMainDataWithDict:(NSDictionary *)dict success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    
    inputData = [NSDictionary dictionaryWithObject:dict forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:@"V3_Message" withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                success(object);
            }else{
                fail(kDataErrorWarning);
                [Messagetabview.mj_header endRefreshing];
            }
        }else{
            fail(kNetworkWarning);
            [Messagetabview.mj_header endRefreshing];
            LOG(@"getmaindataerror%@",err);
        }
    }];
    
}

#pragma mark - uitableviewdatasources

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
    {
        return 101;
    }
    else
    {
        return 71;
    }
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (data.count > 2)
    {
        return 5;//由于数据原因，故形态写死
    }else
    {
        return 0;
    }
}
//由于数据原因，故形态写死
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleIdentify = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentify];
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentify];
    }
    //data为空，cell返回nil
    if (data.count > 2)
    {   //4个圆
        if(indexPath.row == 0)
        {
            [yuan1 removeFromSuperview];
            [yuan2 removeFromSuperview];
            [yuan3 removeFromSuperview];
            [yuan4 removeFromSuperview];
            
            
            yuan1 = [UIButton buttonWithType:UIButtonTypeCustom];
            if (Height > 667.0000) {
                yuan1.frame = CGRectMake(24, 12, 56, 56);
            }
            else
            {
                yuan1.frame = CGRectMake(16, 12, 56, 56);
            }
            
            yuan1.layer.cornerRadius = yuan1.frame.size.width/2;
//            yuan1.layer.borderWidth = 0.2;
            [yuan1 setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
            [yuan1 setTitle:@"已申请" forState:UIControlStateNormal];
            [yuan1 setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
            //            [yuan1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            yuan1.titleLabel.font = [UIFont systemFontOfSize:12];
            [yuan1 addTarget:self action:@selector(yuan1tap) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:yuan1];
            
            
            //            yuan1.layer.shouldRasterize = YES;
            //            yuan1.layer.borderColor =[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1].CGColor;
            
            
            //            CAShapeLayer *solidLine =  [CAShapeLayer layer];
            //            CGMutablePathRef solidPath =  CGPathCreateMutable();
            //            solidLine.lineWidth = 0.5 ;
            //            solidLine.strokeColor = [UIColor blackColor].CGColor;
            //            solidLine.fillColor = [UIColor clearColor].CGColor;
            //            CGPathAddEllipseInRect(solidPath, nil, yuan1.frame);
            //            solidLine.path = solidPath;
            //            CGPathRelease(solidPath);
            //            [cell.contentView.layer addSublayer:solidLine];
            
            yuan2= [UIButton buttonWithType:UIButtonTypeCustom];
            yuan2.frame = CGRectMake((self.view.frame.size.width - 142 - 110)/3 + 55 + 16, 12, 55, 55);
            yuan2.layer.cornerRadius = yuan2.frame.size.width/2;
//            yuan2.layer.borderWidth = 0.2;
            [yuan2 setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
            [yuan2 setTitle:@"已审阅" forState:UIControlStateNormal];
            yuan2.titleLabel.font = [UIFont systemFontOfSize:12];
            [yuan2 setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
            //            [yuan2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [yuan2 addTarget:self action:@selector(yuan2tap) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:yuan2];
            
            yuan3 = [UIButton buttonWithType:UIButtonTypeCustom];
            //            yuan3.frame = CGRectMake(yuan2.frame.origin.x + 55 + (self.view.frame.size.width - 220)/5, 12, 55, 55);
            yuan3.frame = CGRectMake((self.view.frame.size.width - 142 - 110)/3 + yuan2.frame.origin.x + 55, 12, 55, 55);
            yuan3.layer.cornerRadius = yuan3.frame.size.width/2;
//            yuan3.layer.borderWidth = 0.2;
            [yuan3 setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
            [yuan3 setTitle:@"已通过" forState:UIControlStateNormal];
            //            [yuan3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            yuan3.titleLabel.font = [UIFont systemFontOfSize:12];
            [yuan3 setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
            [yuan3 addTarget:self action:@selector(yuan3tap) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:yuan3];
            
            yuan4 = [UIButton buttonWithType:UIButtonTypeCustom];
            if (self.view.frame.size.height>667.0000) {
                yuan4.frame = CGRectMake(self.view.frame.size.width - 79, 12, 56, 56);
            }
            else
            {
                yuan4.frame = CGRectMake(self.view.frame.size.width - 71, 12, 56, 56);
            }
            yuan4.layer.cornerRadius = yuan4.frame.size.width/2;
//            yuan4.layer.borderWidth = 0.2;
            [yuan4 setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
            [yuan4 setTitle:@"未通过" forState:UIControlStateNormal];
            //            [yuan4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            yuan4.titleLabel.font = [UIFont systemFontOfSize:12];
            [yuan4 setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
            [yuan4 addTarget:self action:@selector(yuan4tap) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:yuan4];
            
            
            //            if ([[[data objectForKey:@"WorkProgressNotice"] objectForKey:@"ApplyingRed"] isEqualToString:@"true"]) {
            //                ApplyingRed = [[UIView alloc] initWithFrame:CGRectMake(23.5, 40, 8, 8)];
            //                ApplyingRed.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
            //                ApplyingRed.layer.cornerRadius = 4;
            //                [yuan1 addSubview:ApplyingRed];
            //            }
            if ([[[data objectForKey:@"WorkProgressNotice"] objectForKey:@"CheckedRed"] isEqualToString:@"true"]) {
                CheckedRed = [[UIView alloc] initWithFrame:CGRectMake(23.5, 40, 8, 8)];
                CheckedRed.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                CheckedRed.layer.cornerRadius = 4;
                [yuan2 addSubview:CheckedRed];
            }
            if ([[[data objectForKey:@"WorkProgressNotice"] objectForKey:@"RejectRed"] isEqualToString:@"true"]) {
                RejectRed = [[UIView alloc] initWithFrame:CGRectMake(23.5, 40, 8, 8)];
                RejectRed.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                RejectRed.layer.cornerRadius = 4;
                [yuan4 addSubview:RejectRed];
            }
            if ([[[data objectForKey:@"WorkProgressNotice"] objectForKey:@"SuccessRed"] isEqualToString:@"true"]) {
                SuccessRed = [[UIView alloc] initWithFrame:CGRectMake(23.5, 40, 8, 8)];
                SuccessRed.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                SuccessRed.layer.cornerRadius = 4;
                [yuan3 addSubview:SuccessRed];
            }
            
            
            
            
        }//送岗专区
        else if (indexPath.row == 2) {
            
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [views removeFromSuperview];
            [viewx removeFromSuperview];
            [img2 removeFromSuperview];
            [labetext2 removeFromSuperview];
            [labtitle2 removeFromSuperview];
            [time2 removeFromSuperview];
            [red2 removeFromSuperview];
            
            
            views = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
            views.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
            [cell.contentView addSubview:views];
            viewx = [[UIView alloc] initWithFrame:CGRectMake(0, 101  - 15, self.view.frame.size.width, 15)];
            viewx.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
            [cell.contentView addSubview:viewx];
            
            
            img2 = [[UIImageView alloc] initWithFrame:CGRectMake(yuan1.frame.origin.x, 25, 55, 55)];
            //                     img
            [img2 sd_setImageWithURL:[NSURL URLWithString:[[data objectForKey:@"SelfWorkNotice"] objectForKey:@"HeadImgURL"]] placeholderImage:nil];
            //            img.backgroundColor = [UIColor yellowColor];
            img2.layer.masksToBounds=YES;
            img2.layer.cornerRadius = 27.5;
            [cell.contentView addSubview:img2];
            
            labtitle2 = [[UILabel alloc] initWithFrame:CGRectMake(img2.frame.origin.x + 66, 33, 140, 20)];
            //            labtitle.backgroundColor = [UIColor blackColor];
            labtitle2.text = [[data objectForKey:@"SelfWorkNotice"] objectForKey:@"Name"];
            labtitle2.font = [UIFont systemFontOfSize:12];
            labtitle2.textColor  =[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            [labtitle2 sizeToFit];
            [cell.contentView addSubview:labtitle2];
            
            
            if (![[[[data objectForKey:@"SelfWorkNotice"] objectForKey:@"Red"] stringValue] isEqualToString:@"0"]) {
                
                red2 = [[UIView alloc] initWithFrame:CGRectMake(labtitle2.frame.size.width  + labtitle2.frame.origin.x + 7, 34, 8, 8)];
                red2.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                red2.layer.cornerRadius = 4;
                [cell.contentView addSubview:red2];
            }
            
            
            
            labetext2 = [[UILabel alloc] initWithFrame:CGRectMake(img2.frame.origin.x + 66, 56, Width - img2.frame.origin.x - 70, 20)];
            //            labetext.backgroundColor = [UIColor yellowColor];
            labetext2.text = [[data objectForKey:@"SelfWorkNotice"] objectForKey:@"Content"];
            labetext2.font = [UIFont systemFontOfSize:12];
            labetext2.textColor  =[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
//            [labetext2 sizeToFit];
            [cell.contentView addSubview:labetext2];
            
            
            time2 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 30, 80, 20)];
            //            time.backgroundColor = [UIColor blueColor];
            time2.text = [self uptime:[[data objectForKey:@"SelfWorkNotice"] objectForKey:@"Time"]];
            time2.font = [UIFont systemFontOfSize:9];
            time2.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
            [cell.contentView addSubview:time2];
            
            
            
        }//WorkPushNotice
        else if (indexPath.row == 1)
        {
            
            
            [img1 removeFromSuperview];
            [labetext1 removeFromSuperview];
            [labtitle1 removeFromSuperview];
            [time1 removeFromSuperview];
            [red1 removeFromSuperview];
            [line removeFromSuperview];
            
            
            
            line = [[UIImageView alloc] initWithFrame:CGRectMake(yuan1.frame.origin.x, 2, Width -  2 * yuan1.frame.origin.x, 1)];            line.image = [UIImage imageNamed:@"虚线.png"];
            [cell.contentView addSubview:line];

            
            img1 = [[UIImageView alloc] initWithFrame:CGRectMake(yuan1.frame.origin.x, 8, 55, 55)];
            //         img.
            [img1 sd_setImageWithURL:[NSURL URLWithString:[[data objectForKey:@"WorkPushNotice"] objectForKey:@"HeadImgURL"]] placeholderImage:nil];
            img1.layer.masksToBounds=YES;
            img1.layer.cornerRadius = 27.5;
            [cell.contentView addSubview:img1];
            
            
            labtitle1 = [[UILabel alloc] initWithFrame:CGRectMake(img1.frame.origin.x + 66, 18, 140, 20)];
            //            labtitle.backgroundColor = [UIColor blackColor];
            labtitle1.text =[[data objectForKey:@"WorkPushNotice"] objectForKey:@"Name"];
            labtitle1.font = [UIFont systemFontOfSize:12];
            labtitle1.textColor  =[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            [labtitle1 sizeToFit];
            [cell.contentView addSubview:labtitle1];
            
            
            if (![[[[data objectForKey:@"WorkPushNotice"] objectForKey:@"Red"] stringValue] isEqualToString:@"0"]) {
                
                red1 = [[UIView alloc] initWithFrame:CGRectMake(labtitle1.frame.size.width  + labtitle1.frame.origin.x + 7, 20, 8, 8)];
                red1.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                red1.layer.cornerRadius = 4;
                [cell.contentView addSubview:red1];
            }
            
            
            labetext1 = [[UILabel alloc] initWithFrame:CGRectMake(img1.frame.origin.x + 66, 41, Width - img1.frame.origin.x - 70, 20)];
            //            labetext.backgroundColor = [UIColor yellowColor];
            labetext1.text = [[data objectForKey:@"WorkPushNotice"] objectForKey:@"Content"];
            labetext1.font = [UIFont systemFontOfSize:12];
            labetext1.textColor  =[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
//            [labetext1 sizeToFit];
            [cell.contentView addSubview:labetext1];
            
            
            time1 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 20)];
            //            time.backgroundColor = [UIColor blueColor];
            time1.text = [self uptime:[[data objectForKey:@"WorkPushNotice"] objectForKey:@"Time"]];
            time1.font = [UIFont systemFontOfSize:9];
            time1.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
            [cell.contentView addSubview:time1];
        }//CustomerService
        else if (indexPath.row == 3)
        {
            
            [img3 removeFromSuperview];
            [labetext3 removeFromSuperview];
            [labtitle3 removeFromSuperview];
            [time3 removeFromSuperview];
            [lineview3 removeFromSuperview];
            [red3 removeFromSuperview];
            
            
            img3 = [[UIImageView alloc] initWithFrame:CGRectMake(yuan1.frame.origin.x, 8, 55, 55)];
            //         img.
            [img3 sd_setImageWithURL:[NSURL URLWithString:[[data objectForKey:@"CustomerService"] objectForKey:@"HeadImgURL"]] placeholderImage:nil];
            img3.layer.masksToBounds=YES;
            img3.layer.cornerRadius = 27.5;
            [cell.contentView addSubview:img3];
            
            
            labtitle3 = [[UILabel alloc] initWithFrame:CGRectMake(img3.frame.origin.x + 66, 18, 140, 20)];
            labtitle3.text =[[data objectForKey:@"CustomerService"] objectForKey:@"Name"];
            labtitle3.font = [UIFont systemFontOfSize:12];
            labtitle3.textColor  =[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            [labtitle3 sizeToFit];
            [cell.contentView addSubview:labtitle3];
            
            
            if (![[[[data objectForKey:@"CustomerService"] objectForKey:@"Red"] stringValue] isEqualToString:@"0"]) {
                
                red3 = [[UIView alloc] initWithFrame:CGRectMake(labtitle3.frame.size.width  + labtitle3.frame.origin.x + 7, 20, 8, 8)];
                red3.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                red3.layer.cornerRadius = 4;
                [cell.contentView addSubview:red3];
            }
            
            labetext3 = [[UILabel alloc] initWithFrame:CGRectMake(img3.frame.origin.x + 66, 41, Width - img3.frame.origin.x - 70, 20)];
            //            labetext.backgroundColor = [UIColor yellowColor];
            labetext3.text = [[data objectForKey:@"CustomerService"] objectForKey:@"Content"];
            labetext3.font = [UIFont systemFontOfSize:12];
            labetext3.textColor  =[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
//            [labetext3 sizeToFit];
            [cell.contentView addSubview:labetext3];
            
            
            time3 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 20)];
            //            time.backgroundColor = [UIColor blueColor];
            time3.text = [self uptime:[[data objectForKey:@"CustomerService"] objectForKey:@"Time"]];
            time3.font = [UIFont systemFontOfSize:9];
            time3.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
            [cell.contentView addSubview:time3];
            
            
            lineview3 = [[UIView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 0.5)];
            lineview3.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
            [cell.contentView addSubview:lineview3];
            
        }//CommentPushNotice
        else if (indexPath.row == 4)
        {
            
            [img4 removeFromSuperview];
            [labetext4 removeFromSuperview];
            [labtitle4 removeFromSuperview];
            [time4 removeFromSuperview];
            [red4 removeFromSuperview];
            
            img4 = [[UIImageView alloc] initWithFrame:CGRectMake(yuan1.frame.origin.x, 8, 55, 55)];
            //         img.
            img4.layer.masksToBounds=YES;
            img4.layer.cornerRadius = 27.5;
            [img4 sd_setImageWithURL:[NSURL URLWithString:[[data objectForKey:@"CommentPushNotice"] objectForKey:@"HeadImgURL"]] placeholderImage:nil];
            [cell.contentView addSubview:img4];
            
            
            labtitle4 = [[UILabel alloc] initWithFrame:CGRectMake(img4.frame.origin.x + 66, 18, 140, 20)];
            //            labtitle.backgroundColor = [UIColor blackColor];
            labtitle4.text =[[data objectForKey:@"CommentPushNotice"] objectForKey:@"Name"];
            labtitle4.font = [UIFont systemFontOfSize:12];
            labtitle4.textColor  =[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            [labtitle4 sizeToFit];
            [cell.contentView addSubview:labtitle4];
            
            
            if (![[[[data objectForKey:@"CommentPushNotice"] objectForKey:@"Red"] stringValue] isEqualToString:@"0"]) {
                
                red4 = [[UIView alloc] initWithFrame:CGRectMake(labtitle4.frame.size.width  + labtitle4.frame.origin.x + 7, 20, 8, 8)];
                red4.backgroundColor = [UIColor colorWithRed:252/255.0 green:122/255.0 blue:130/255.0 alpha:1];
                red4.layer.cornerRadius = 4;
                [cell.contentView addSubview:red4];
            }
            
            
            labetext4 = [[UILabel alloc] initWithFrame:CGRectMake(img4.frame.origin.x + 66, 41, Width - img4.frame.origin.x - 70, 20)];
            //            labetext.backgroundColor = [UIColor yellowColor];
            labetext4.text = [[data objectForKey:@"CommentPushNotice"] objectForKey:@"Content"];
            labetext4.font = [UIFont systemFontOfSize:12];
            labetext4.textColor  =[UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
//            [labetext4 sizeToFit];
            [cell.contentView addSubview:labetext4];
            
            
            time4 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 15, 80, 20)];
            //            time.backgroundColor = [UIColor blueColor];
            time4.text = [self uptime:[[data objectForKey:@"CommentPushNotice"] objectForKey:@"Time"]];
            time4.font = [UIFont systemFontOfSize:9];
            time4.textColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1];
            [cell.contentView addSubview:time4];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    return nil;
}

#pragma mark - tableView didSelectRow

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row!=0) {
        if (indexPath.row==1) { //进入工作消息界面
            WorkNewsViewController * WorkNewsVC = [[WorkNewsViewController alloc] init];
            WorkNewsVC.hidesBottomBarWhenPushed = YES;
            WorkNewsVC.delegate = self;
            [self.navigationController pushViewController:WorkNewsVC animated:YES];
            //            [red1 removeFromSuperview];
        }
        else if(indexPath.row==2)
        {
            DirectSupportAcceptedViewController * dsaVC = [DirectSupportAcceptedViewController new];
            dsaVC.delegate = self;
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:dsaVC animated:YES];
//            self.hidesBottomBarWhenPushed = NO;
            //            [red2 removeFromSuperview];
            
        }
        else if(indexPath.row==3)//进入客服咨询界面
        {
            ConsultingViewController *  Consulting = [[ConsultingViewController alloc] init];
            Consulting.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:Consulting animated:YES];
            //            [red3 removeFromSuperview];
            
        }
        else if(indexPath.row==4)//进入评论消息界面
        {
            CommentNewsViewController *  CommentNewsVC = [[CommentNewsViewController alloc] init];
            CommentNewsVC.delegate = self;
            CommentNewsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:CommentNewsVC animated:YES];
            //            [red4 removeFromSuperview];
        }
    }
}

#pragma mark - 4个圆的点击

- (void)yuan1tap
{
    MyApplyViewController *myVC = [[MyApplyViewController alloc]init];
    myVC.page = @"0";
    myVC.delegate = self;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:myVC animated:YES];
    
}
- (void)yuan2tap
{
    MyApplyViewController *myVC = [[MyApplyViewController alloc]init];
    myVC.page = @"1";
    myVC.delegate = self;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:myVC animated:YES];
}
- (void)yuan3tap
{
    MyApplyViewController *myVC = [[MyApplyViewController alloc]init];
    myVC.page = @"2";
    myVC.delegate = self;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:myVC animated:YES];
}
- (void)yuan4tap
{
    MyApplyViewController *myVC = [[MyApplyViewController alloc]init];
    myVC.page = @"3";
    myVC.delegate = self;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:myVC animated:YES];
}

#pragma mark - viewDidAppear

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [inputDataDic setObject:bUser ? bUser.objectId : @"" forKey:kToUserObjectId];
        [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
            if (obj) {
                if (data) {
                    [data removeAllObjects];
                }
                [data addEntriesFromDictionary:obj];
                if(data.count != 0){
                    nodataimage.hidden = YES;
                }else
                {
                    nodataimage.hidden = NO;
                }
                [Messagetabview reloadData];
            }
        }fail:^(NSString *err){
        }];
    });
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;    //让rootView禁止滑动
}
#pragma mark - 修改固定数据时间格式
- (NSString *)uptime:(NSString *)createtime
{
    if (createtime.length > 16) {
        NSRange range = {0,16};
        createtime = [createtime substringWithRange:range];
    }
    return createtime;
}
#pragma mark - 环信
-(void)loginEaseForRcid:(NSString *)rcid md5Passwodrd:(NSString *)md5Passwodrd
{
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:rcid password:md5Passwodrd completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         //登录成功
         if (loginInfo && !error) {
             LOG(@"成功!");
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
             [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
         }else {
             
             switch (error.errorCode) {
                 case EMErrorServerNotReachable:
                     LOG(@"hx连接服务器失败!");
                     break;
                 case EMErrorTooManyLoginRequest:
                 {
                     static int num1 = 0;
                     num1 ++;
                     if (num1 == 3) {
                         num1 = 0;
                         return;
                     }
                     //已经登录过了，再次重新登录
                     [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                         
                         [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
                     } onQueue:nil];
                     
                 }
                     break;
                 case EMErrorServerAuthenticationFailure:
                     LOG(@"hxerror.description");
                     break;
                 case EMErrorServerTimeout:
                     LOG(@"hx连接服务器超时!");
                     break;
                 default:
                     LOG(@"hx登录失败");
                     static int num = 0;
                     num ++;
                     if (num == 3) {
                         num = 0;
                         return;
                     }
                     [[EaseMob sharedInstance].chatManager registerNewAccount:[bUser objectForKey:kobjectId] password:@"QAZWSXEDC" error:&error];
                     
                     [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
                     //      [[EaseMob sharedInstance].chatManager loginWithUsername:[bUser objectForKey:kobjectId] password:@"QAZWSXEDC" error:&error];
                     break;
             }
         }
     } onQueue:nil];
    
}

#pragma mark - 底部tabBar，及判断用户是否已经登录了

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [Messagetabview.mj_header endRefreshing];

    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self setHidesBottomBarWhenPushed:NO];
    bUser = [ShareDataSource sharedDataSource].myData;
    //判断用户是否登录了
    if (bUser == nil) {
        //        NSLog(@"bUser==nil");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去登录", nil];
        alertView.tag = 250;
        [alertView show];
    }
    else
    {
        //    if ([USER_DEFAULT objectForKey:@"User_HXmm"]) {
        //        [self loginEaseForRcid:[bUser objectForKey:@"username"] md5Passwodrd:[USER_DEFAULT objectForKey:@"User_HXmm"]];
        //    }
        [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
        
    }
    
}
#pragma mark - viewDidDisappear

- (void)viewDidDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [Messagetabview.mj_header endRefreshing];
}
#pragma mark - IChatManagerDelegate dealloc

-(void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}
#pragma mark - IChatManagerDelegate 消息变化

#pragma mark - 会话列表信息更新时的回调
//1. 当会话列表有更改时(新添加,删除), 2. 登陆成功时, 以上两种情况都会触发此回调
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    LOG(@"话列表信息更新时的回调");
}
#pragma mark - 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
//    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
//    NSInteger unreadCount = 0;
//    UIApplication *app = [UIApplication sharedApplication];
//    for (EMConversation *conversation in conversations) {
//        unreadCount += conversation.unreadMessagesCount;
//    }
//    if (unreadCount > 0) {
//        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
//        app.applicationIconBadgeNumber = unreadCount;
//    }else{
//        self.navigationController.tabBarItem.badgeValue = nil;
//        app.applicationIconBadgeNumber = 0;
//    }
}

#pragma mark - 当前登录账号在其它设备登录时的通知回调
- (void)didLoginFromOtherDevice
{
    LOG(@"当前登录账号在其它设备登录时的通知回调");
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        if(error){
            [weakSelf showHint:@"您的账号已在其它设备登录"];
        }
        
    } onQueue:nil];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号已在其它设备登录~" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    alertView.tag = 99999;
    [alertView show];
}
#pragma mark - alertView代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99999)
    {
        if ([ShareDataSource sharedDataSource].myData) {
            [BmobUser logout];
            [USER_DEFAULT setObject:@"" forKey:kMyInfoKey];
            [ShareDataSource sharedDataSource].myData = nil;
        }
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [[self getCurrentVC] presentViewController:login animated:YES completion:nil];
    }
    
    if (alertView.tag == 250) {
        
        if (buttonIndex == 1) { //点击去登录情况
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            //        NSArray *arr = self.tabBarController.view.subviews;
            //        UITabBar *tabBarView = [arr objectAtIndex:1];
            //        tabBarView.frame=CGRectMake(0, Height, Width, 49);
            [self presentViewController:login animated:YES completion:nil];
        }
        else
        {   //未登录情况点击取消去登录
            self.tabBarController.selectedIndex = 0;
            
            //        NSArray *arr = self.tabBarController.view.subviews;
            //        UITabBar *tabBarView = [arr objectAtIndex:1];
            //        tabBarView.frame=CGRectMake(0, Height - 49, Width, 49);
        }
    }
    
}
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
#pragma mark - 当前登录账号已经被从服务器端删除
- (void)didRemovedFromServer
{
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        
        [weakSelf showHint:@"你的账号已被从服务器端移除"];
        //        [weakSelf toLogin];
        
    } onQueue:nil];
}
#pragma mark - 自动登录回调

- (void)willAutoReconnect{
    LOG(@"将要发起自动重连操作");
    [SVProgressHUD showInfoWithStatus:@"正在重连服务器..."];
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    LOG(@"自动重连操作完成后的回调（成功的话，error为nil，失败的话，查看error的错误信息）");
    
    //    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    //    if (showreconnect && [showreconnect boolValue]) {
    //        [self hideHud];
    if (error) {
        
        [SVProgressHUD showSuccessWithStatus:@"重连成功"];
        //                [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
    }else{
        //                [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
        //                [SVProgressHUD showErrorWithStatus:@"重连失败,请重新登录"];
        //                if ([ShareDataSource sharedDataSource].myData) {
        //                    [BmobUser logout];
        //                    [USER_DEFAULT setObject:@"" forKey:kMyInfoKey];
        //                    [ShareDataSource sharedDataSource].myData = nil;
        //                }
        //                LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        //                [[self getCurrentVC] presentViewController:login animated:YES completion:nil];
    }
    //    }
}

#pragma mark - 除去红点

//除去红点
-(void)Remove_Red:(NSString *)str andRemove_red:(NSString *)NoticeObjectId andType:(NSString *)Type
{
    if ([str isEqualToString:@"1"]){
        [red4 removeFromSuperview];
    }
    
    else if ([str isEqualToString:@"3"])
    {
//        [red1 removeFromSuperview];
    }else {
        
    }
        
    
    [self Remove_red:NoticeObjectId andType:Type];
}
- (void)Remove_Red2:(NSString *)str andRemove_red:(NSString *)WorkOrderObjectId andType:(NSString *)Type
{
    
    if ([str isEqualToString:@"13"])
    {
//        [SuccessRed removeFromSuperview];
    }
    else if ([str isEqualToString:@"12"])
    {
//        [CheckedRed removeFromSuperview];
    }
    else if ([str isEqualToString:@"2"])
    {
//        [red2 removeFromSuperview];
        
        Type = kDismissSelfWorkRedPoint;
    }
    else
    {
//        [RejectRed removeFromSuperview];
    }
    [self Remove_red2:WorkOrderObjectId andType:Type];
}

#pragma mark -  除去cell红点接口

//除去红点接口
- (void)Remove_red:(NSString *)NoticeObjectId andType:(NSString *)Type
{
    NSMutableDictionary * inputDataDic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           NoticeObjectId,@"NoticeObjectId",
                                           [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:kobjectId],kCityObjectId,
                                           Type,kType,
                                           kCloudVersion,kVersion,
                                           nil];
    
    [self getMainDataWithDict:inputDataDic1 success:^(NSDictionary *obj){
        if (obj){
        }
    }fail:^(NSString *err){
    }];
}

#pragma mark -  除去圆圆红点接口,小邦送岗红点接口

//除去圆圆红点接口
- (void)Remove_red2:(NSString *)WorkOrderObjectId andType:(NSString *)Type
{
    NSMutableDictionary * inputDataDic1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           WorkOrderObjectId,kWorkOrderObjectId,
                                           [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:kobjectId],kCityObjectId,
                                           Type,kType,
                                           kCloudVersion,kVersion,
                                           nil];
    
    [self getMainDataWithDict:inputDataDic1 success:^(NSDictionary *obj){
        if (obj){
        }
    }fail:^(NSString *err){
    }];
}

#pragma mark -  RemovelocalRed

- (void)RemovelocalRed:(NSString *)str
{
    if ([str isEqualToString:@"13"])
    {
        [SuccessRed removeFromSuperview];
    }
    else if ([str isEqualToString:@"1"]){
        [red4 removeFromSuperview];
    }
    
    else if ([str isEqualToString:@"3"])
    {
        [red1 removeFromSuperview];
    }
    else if ([str isEqualToString:@"12"])
    {
        [CheckedRed removeFromSuperview];
    }
    else if ([str isEqualToString:@"2"])
    {
        [red2 removeFromSuperview];
    }
    else if ([str isEqualToString:@"14"])
    {
        [RejectRed removeFromSuperview];
    }
}


@end
