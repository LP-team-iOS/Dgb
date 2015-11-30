//
//  ConsultingViewController.m
//  duangongbang
//
//  Created by ljx on 15/11/4.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "ConsultingViewController.h"
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "ConsultingList.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "LoginViewController.h"
#import "MessageViewController.h"

@interface ConsultingViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    
    BmobUser *bUser;
    NSMutableDictionary *inputDataDic;
    NSDictionary *inputData;
    NSMutableArray * data;
    UITableView * CStabview;
    UIImageView * nodataimage;
    
}
@end

@implementation ConsultingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏的配置
    self.view.backgroundColor =[UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                      
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"在线客服";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlackColor);
    //BarButton
    UIBarButtonItem * leftback = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"detailBackIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:0 target:self action:@selector(leftbacktap)];
    self.navigationItem.leftBarButtonItem = leftback;
    
    
    //    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //tabview初始化
    CStabview = [[UITableView alloc] initWithFrame:self.view.frame];
    CStabview.dataSource = self;
    CStabview.delegate  = self;
    CStabview.separatorStyle = UITableViewCellSeparatorStyleNone;
    CStabview.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    [self.view addSubview:CStabview];
    
    //tabviewCell注册
    [CStabview registerNib:[UINib nibWithNibName:@"ConsultingListCell" bundle:nil] forCellReuseIdentifier:@"ConsultingListCell"];
    
    MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    CStabview.mj_header = header;
    
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY  maskType:SVProgressHUDMaskTypeClear];
    
    
    //    {"inputData":{"CityObjectId":"Cbqr444B","DeviceType":"android","DeviceId":"ED1C72A7E32508AD9AD9316CC5B2C9E0","Type":"GetCustomerServiceList"}}
    
    bUser = [ShareDataSource sharedDataSource].myData;
    
    inputDataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:kobjectId],kCityObjectId,
                    kGetCustomerServiceList,kType,
                    kios,kDeviceType,
                    @0,kskip,
                    nil];
    
    data = [NSMutableArray array];
    
    //[bUser objectForKey:@"objectId"]
    
    //    [inputDataDic setObject:@"Cbqr444B" forKey:@"CityObjectId"];
    //    [inputDataDic setObject:@"ios"forKey:@"DeviceType"];
    //    [inputDataDic setObject:@"GetCustomerServiceList"forKey:@"Type"];
    
    //    [inputDataDic setObject:@"324"forKey:@"Version"];
    //    [inputDataDic setObject:@"0"forKey:@"skip"];
    //        [inputDataDic setObject:@"2"forKey:@"limit"];
    
    nodataimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data"]];
    nodataimage.frame = CGRectMake(Width/2 - 62.5, Height/2 - 62.5 - 65, 125, 125);
    [self.view addSubview:nodataimage];
    //    nodataimage.hidden = YES;
    
    
    
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        NSArray*  data1 = [[NSArray alloc] init];
        [timer invalidate];
        if (obj)
        {
            data1 = [ConsultingList objectArrayWithKeyValuesArray:[obj objectForKey:@"CustomerServiceList"]];
            if (data1.count != 0) {
                nodataimage.hidden = YES;
            }
            else
            {
                nodataimage.hidden = NO;
            }
            [data addObjectsFromArray:data1];
            
            [SVProgressHUD dismiss];
            [CStabview reloadData];
        }
    }fail:^(NSString *err){
        [SVProgressHUD dismiss];
    }];
}
//刷新或者上拉加载超时
- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [CStabview.mj_header endRefreshing];
        //        [CStabview.footer endRefreshing];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请检查下你的网络哟~" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
        
        
    }
}
- (void)loadNewData
{
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    [CStabview.mj_header beginRefreshing];
    
    //    [inputDataDic setObject:@"10" forKey:@"limit"];
    
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        NSArray*  data1 = [[NSArray alloc] init];
        [timer invalidate];
        if (obj)
        {
            data1 = [ConsultingList objectArrayWithKeyValuesArray:[obj objectForKey:@"CustomerServiceList"]];
            if (data1.count != 0) {
                nodataimage.hidden = YES;
            }
            else
            {
                nodataimage.hidden = NO;
            }
            if (data) {
                [data removeAllObjects];
            }
            [SVProgressHUD showSuccessWithStatus:@"刷新成功啦!"];
            [data addObjectsFromArray:data1];
            
            [CStabview.mj_header endRefreshing];
            [CStabview reloadData];
        }
    }fail:^(NSString *err){
        [SVProgressHUD showErrorWithStatus:@"刷新失败,请检测下网络吧"];
        [CStabview.mj_header endRefreshing];
        [SVProgressHUD dismiss];
        //        [WorkNewsTableView reloadData];
    }];
}
#pragma mark - servers

- (void)getMainDataWithDict:(NSDictionary *)dict success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    
    inputData = [NSDictionary dictionaryWithObject:dict forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:@"V3_Message" withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                success(object);
            }else{
                fail(kDataErrorWarning);
                [CStabview.mj_header endRefreshing];
            }
        }else{
            fail(kNetworkWarning);
            LOG(@"getmaindataerror%@",err);
            [CStabview.mj_header endRefreshing];
        }
    }];
    //        [WorkNewsTableView reloadData];
}
#pragma mark - uitableviewdatasources

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ConsultingListCell"];
    ConsultingList *notice=[data objectAtIndex:indexPath.row];
    if (notice)
    {
        UIImageView * Head_portrait = (UIImageView *)[cell viewWithTag:301];
        [Head_portrait sd_setImageWithURL:[NSURL URLWithString:notice.HeadImg]placeholderImage:nil];
        Head_portrait.layer.masksToBounds=YES;
        Head_portrait.layer.cornerRadius = 27.5;
        
        UILabel * titlename = (UILabel *)[cell viewWithTag:302];
        titlename.text = notice.Name;
        
        return cell;
    }
    return nil;
}
//- (NSString *)uptime:(NSString *)createtime
//{
//    NSRange range = {5,11};
//
//    createtime = [createtime substringWithRange:range];
//
//    return createtime;
//}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回上一界面

- (void)leftbacktap
{
    //    MessageViewController * MessageView = [[MessageViewController alloc] init];
    //    [self.navigationController popToViewController:MessageView animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
    //    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
}


#pragma mark - tableView didSelectRowAtIndexPath


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CStabview deselectRowAtIndexPath:indexPath animated:YES];
    //        ConsultingdetailsViewController *dgVC = [[ConsultingdetailsViewController alloc] init];
    ////        WorkNews *notice=[data objectAtIndex:indexPath.row];
    ////        [dgVC setWorkObjectId:notice.objectId];
    //        [self.navigationController pushViewController:dgVC animated:YES];
    ConsultingList *notice=[data objectAtIndex:indexPath.row];
    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:notice.CustomerId conversationType:eConversationTypeChat];
    chatVc.name = notice.Name;
    chatVc.isSender_no_headimage = notice.HeadImg;
    BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
    chatVc.isSender_yes_headimage = headImg.url;
    chatVc.isMy_Nickname = [bUser objectForKey:@"Name"];
    //    chatVc.Consultingid = notice.CustomerId;
    [self.navigationController pushViewController:chatVc animated:YES];
    
    
    //    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:@"127707962977288628" isGroup:YES];
    //    chatVc.name = notice.Name;
    //    chatVc.isSender_no_headimage = notice.HeadImg;
    //    BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
    //    chatVc.isSender_yes_headimage = headImg.url;
    //    chatVc.isMy_Nickname = [bUser objectForKey:@"Nickname"];
    //    [self.navigationController pushViewController:chatVc animated:YES];
    
    
    
    
}

#pragma mark - viewDidAppear


- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;    //让rootView禁止滑动
    
    [SVProgressHUD dismiss];

}
//-(void)dealloc
//{
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//}
//#pragma mark - IChatManagerDelegate 消息变化
//
//#pragma mark - 会话列表信息更新时的回调
////1. 当会话列表有更改时(新添加,删除), 2. 登陆成功时, 以上两种情况都会触发此回调
//- (void)didUpdateConversationList:(NSArray *)conversationList
//{
//    LOG(@"话列表信息更新时的回调");
//}
//#pragma mark - 未读消息数量变化回调
//-(void)didUnreadMessagesCountChanged
//{
//    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
//    NSInteger unreadCount = 0;
//    for (EMConversation *conversation in conversations) {
//        unreadCount += conversation.unreadMessagesCount;
//    }
//    if (unreadCount > 0) {
//        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
//    }else{
//        self.navigationController.tabBarItem.badgeValue = nil;
//    }
//}
//#pragma mark - IChatManagerDelegate 登录状态变化
//
//#pragma mark - 当前登录账号在其它设备登录时的通知回调
//- (void)didLoginFromOtherDevice
//{
//    LOG(@"当前登录账号在其它设备登录时的通知回调");
//    __weak typeof(self) weakSelf = self;
//    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
//        if(error){
//            [weakSelf showHint:@"您的账号已在其它设备登录"];
//
//
//
//        }
//
//    } onQueue:nil];
//
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您的账号已在其它设备登录~" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
//    alertView.tag = 99999;
//    [alertView show];
//
//
//}
//#pragma mark - alertView代理
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 99999)
//    {
//    LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//    [[self getCurrentVC] presentViewController:login animated:YES completion:nil];
//    }
//
//}
//- (UIViewController *)getCurrentVC
//{
//    UIViewController *result = nil;
//
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    if (window.windowLevel != UIWindowLevelNormal)
//    {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for(UIWindow * tmpWin in windows)
//        {
//            if (tmpWin.windowLevel == UIWindowLevelNormal)
//            {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
//
//    UIView *frontView = [[window subviews] objectAtIndex:0];
//    id nextResponder = [frontView nextResponder];
//
//    if ([nextResponder isKindOfClass:[UIViewController class]])
//        result = nextResponder;
//    else
//        result = window.rootViewController;
//
//    return result;
//}
//#pragma mark - 当前登录账号已经被从服务器端删除
//- (void)didRemovedFromServer
//{
//    __weak typeof(self) weakSelf = self;
//    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
//
//        [weakSelf showHint:@"你的账号已被从服务器端移除"];
//        //        [weakSelf toLogin];
//
//    } onQueue:nil];
//}
////-(void)toLogin
////{
////    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
////    delegate.window.rootViewController = [RCLoginController new];
////    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"sessionid"];
////
////}
//
//#pragma mark - 自动登录回调
//
//- (void)willAutoReconnect{
//
//    LOG(@"将要发起自动重连操作");
//}
//
//- (void)didAutoReconnectFinishedWithError:(NSError *)error
//{
//    LOG(@"自动重连操作完成后的回调（成功的话，error为nil，失败的话，查看error的错误信息）");
//
//    //    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    //    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
//    //    if (showreconnect && [showreconnect boolValue]) {
//    //        [self hideHud];
//    //        if (error) {
//    //            [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
//    //        }else{
//    //            [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
//    //        }
//    //    }
//}
#pragma mark -  viewWillAppear


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    self.tabBarController.tabBar.hidden = YES;
    
    
    bUser = [ShareDataSource sharedDataSource].myData;
    //判断用户是否登录了
    if (bUser == nil) {
        //        NSLog(@"bUser==nil");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark -  alertView clickedButtonAtIndex

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self presentViewController:login animated:YES completion:nil];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
