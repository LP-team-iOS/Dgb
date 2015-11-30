//
//  CommentNewsViewController.m
//  duangongbang
//
//  Created by ljx on 15/11/2.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "CommentNewsViewController.h"
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "WorkNews.h"
#import "DGDetailViewController.h"
#import "LoginViewController.h"

@interface CommentNewsViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    BmobUser *bUser;
    NSMutableDictionary *inputDataDic;
    NSDictionary *inputData;
    NSMutableArray * data;
    UITableView * CommentNewsTableView;
    UIImageView * nodataimage;
}
@end

@implementation CommentNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏的配置
    self.title = @"评论消息";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
    self.view.backgroundColor =[UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //BarButton
    UIBarButtonItem * leftback = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"detailBackIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:0 target:self action:@selector(leftbacktap)];
    self.navigationItem.leftBarButtonItem = leftback;
    //tabview初始化
    CommentNewsTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    CommentNewsTableView.dataSource = self;
    CommentNewsTableView.delegate  = self;
    CommentNewsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    CommentNewsTableView.backgroundColor = RGB(243, 243, 243, 1.0);
    [self.view addSubview:CommentNewsTableView];
    
    //tabviewCell注册
    [CommentNewsTableView registerNib:[UINib nibWithNibName:@"WorkNewCell" bundle:nil] forCellReuseIdentifier:@"WorkNewCell"];
    
    //下拉刷新
    MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    CommentNewsTableView.mj_header = header;
    
    //菊花转呀转
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];
    
    //获取用户信息
    bUser = [ShareDataSource sharedDataSource].myData;
    
    inputDataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:kobjectId],kCityObjectId,
                    kUser,kUserType,[bUser objectForKey:kobjectId]?[bUser objectForKey:kobjectId]:@"" ,kToUserObjectId,
                    kGetCommentPushNotices,kType,
                    kCloudVersion,kVersion,
                    @0,kskip,
                    nil];
    //    inputDataDic = [NSMutableDictionary dictionary];
    data = [NSMutableArray array];
    
    //    {"inputData":{"CityObjectId":"ZUaK444F","UserType":"User","ToUserObjectId":"61acc57699","Version":"324","skip":0,"Type":"GetCommentPushNotices"}}
    
    //[bUser objectForKey:@"objectId"]
    
    //    [inputDataDic setObject:@"ZUaK444F" forKey:@"CityObjectId"];
    //    [inputDataDic setObject:@"User"forKey:@"UserType"];
    //    [inputDataDic setObject:@"61acc57699" forKey:@"ToUserObjectId"] ;
    //    [inputDataDic setObject:@"GetCommentPushNotices"forKey:@"Type"];
    //    [inputDataDic setObject:@"324"forKey:@"Version"];
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
            data1 = [WorkNews objectArrayWithKeyValuesArray:[obj objectForKey:@"CommentPushNotices"]];
            
            if (data1.count != 0) {
                nodataimage.hidden = YES;
            }
            else
            {
                nodataimage.hidden = NO;
            }
            [data addObjectsFromArray:data1];
            
            [SVProgressHUD dismiss];
            [CommentNewsTableView reloadData];
        }
    }fail:^(NSString *err){
        [SVProgressHUD dismiss];
    }];
}
- (void)loadNewData
{
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    [CommentNewsTableView.mj_header beginRefreshing];
    //    [inputDataDic setObject:@"10" forKey:@"limit"];
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        NSArray*  data1 = [[NSArray alloc] init];
        [timer invalidate];
        if (obj)
        {
            data1 = [WorkNews objectArrayWithKeyValuesArray:[obj objectForKey:@"CommentPushNotices"]];
            if (data1.count != 0) {
                nodataimage.hidden = YES;
            }
            else
            {
                nodataimage.hidden = NO;
            }
            [SVProgressHUD showSuccessWithStatus:@"刷新成功啦!"];
            if (data) {
                [data removeAllObjects];
            }
            [data addObjectsFromArray:data1];
            
            [CommentNewsTableView reloadData];
            [CommentNewsTableView.mj_header endRefreshing];
        }
    }fail:^(NSString *err){
        [SVProgressHUD showErrorWithStatus:@"刷新失败,请检测下网络吧"];
        [CommentNewsTableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
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
                [CommentNewsTableView.mj_header endRefreshing];
                //                [CommentNewsTableView.footer endRefreshing];
            }
        }else{
            fail(kNetworkWarning);
            LOG(@"getmaindataerror%@",err);
            [CommentNewsTableView.mj_header endRefreshing];
            //            [CommentNewsTableView.footer endRefreshing];
        }
    }];
    //    [jobTableView reloadData];
}
#pragma mark - uitableviewdatasources

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"WorkNewCell"];
    WorkNews *notice=[data objectAtIndex:indexPath.row];
    if (notice)
    {
        UILabel * Content = (UILabel *)[cell viewWithTag:201];
        Content.text = notice.Content;
        
        UILabel * title = (UILabel *)[cell viewWithTag:203];
        title.text = notice.Title;
        
        UILabel * time = (UILabel *)[cell viewWithTag:202];
        time.text = [self uptime:notice.createdAt];
        
        UIView * view = (UIView *)[cell viewWithTag:204];
        if (indexPath.row == data.count -1) {
            view.hidden = YES;
        }
        else
        {
            view.hidden = NO;
        }
        
        return cell;
    }
    return nil;
}

#pragma mark - //刷新或者上拉加载超时

- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [CommentNewsTableView.mj_header endRefreshing];
        //        [CommentNewsTableView.footer endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请检查下你的网络哟~" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
}
- (NSString *)uptime:(NSString *)createtime
{
    NSRange range = {5,11};
    
    createtime = [createtime substringWithRange:range];
    
    return createtime;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回上一界面

- (void)leftbacktap
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - viewWillAppear

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    //    self.title = @"评论消息";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
    
    
    bUser = [ShareDataSource sharedDataSource].myData;
    //判断用户是否登录了
    if (bUser == nil) {
        //        NSLog(@"bUser==nil");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - tableView didSelectRow
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommentNewsTableView deselectRowAtIndexPath:indexPath animated:YES];
    DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
    WorkNews *notice=[data objectAtIndex:indexPath.row];
    [dgVC setWorkObjectId:notice.WorkObjectId];
    [self.navigationController pushViewController:dgVC animated:YES];
    [self.delegate Remove_Red:@"1" andRemove_red:notice.objectId andType:kDismissRedPoint];
}

-(NSString *)getWorkObjectId:(NSString *)str
{
    //    {"WorkObjectId":"9c148af917","WorkOrderObjectId":"34a6ff629f"}
    NSRange range = [str rangeOfString:@","];
    NSRange range1 = [str rangeOfString:@":"];
    NSRange range2 = {range1.location + 2,range.location - 1 - (range1.location + 2)};
    str = [str substringWithRange:range2];
    return str;
}

#pragma mark - alertView代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self presentViewController:login animated:YES completion:nil];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
//        for (int i = 0; i < data.count; i++)
//        {
//            //        if ([[[_workListArray objectAtIndex:i] objectForKey:@"Red"] isEqualToString:@"false"])
//            //        {
//            //            [self.delegate RemovelocalRed:@"2"];
//            //        }
//            if (![[[data objectAtIndex:i] objectForKey:@"Red"] isEqualToString:@"false"])
//            {
//                return ;
//            }
//            if (data.count-1 == i)
//            {
//                [self.delegate RemovelocalRed:@"1"];
//            }
//        }
        //        //请求数据啦
        //        [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        //            NSArray*  data1 = [[NSArray alloc] init];
        //            if (obj)
        //            {
        //                //请求到PushNotices中的数据
        //                data1 = [WorkNews objectArrayWithKeyValuesArray:[obj objectForKey:@"PushNotices"]];
        //                if (data1.count != 0) {
        //                    nodataimage.hidden = YES;
        //                }
        //                else
        //                {
        //                    nodataimage.hidden = NO;
        //                }
        //                [SVProgressHUD showSuccessWithStatus:@"刷新成功啦!"];
        //                //判断data是否为空，空就删除它
        //                if (data) {
        //                    [data removeAllObjects];
        //                }
        //                //添加新的数据到data
        //                [data addObjectsFromArray:data1];
        //                [WorkNewsTableView reloadData];
        //            }
        //        }fail:^(NSString *err)
        //         {
        //         }];
        //        
        //    });

//    });
    
}

#pragma mark -  viewDidAppear

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    
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
