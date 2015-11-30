//
//  WorkNewsViewController.m
//  duangongbang
//
//  Created by ljx on 15/11/2.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "WorkNewsViewController.h"
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "WorkNews.h"
#import "NotificationViewController.h"
#import "LoginViewController.h"

@interface WorkNewsViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
    
    BmobUser *bUser;
    NSMutableDictionary *inputDataDic;
    NSDictionary *inputData;
    NSMutableArray * data;
    UITableView * WorkNewsTableView;
    UIImageView * nodataimage;
    
}
@end

@implementation WorkNewsViewController


#pragma mark - 进入界面

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏头头配置
    self.navigationItem.title = @"工作消息";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
    self.view.backgroundColor =[UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    //返回BarButton
    UIBarButtonItem * leftback = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"detailBackIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:0 target:self action:@selector(leftbacktap)];
    self.navigationItem.leftBarButtonItem = leftback;
    
    //TableView初始化
    WorkNewsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Width, Height - 65)];
    WorkNewsTableView.dataSource = self;
    WorkNewsTableView.delegate  = self;
    WorkNewsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    WorkNewsTableView.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    [self.view addSubview:WorkNewsTableView];
    
    //tableViewCell注册复用
    [WorkNewsTableView registerNib:[UINib nibWithNibName:@"WorkNewCell" bundle:nil] forCellReuseIdentifier:@"WorkNewCell"];
    
    //tableView上拉刷新
    MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    WorkNewsTableView.mj_header = header;
    
    //菊花转呀转
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];
    //获取用户数据
    bUser = [ShareDataSource sharedDataSource].myData;
    
    //        请求数据参数格式
    //    {"inputData":{"CityObjectId":"ZUaK444F",
    //    "UserType":"User",
    //    "ToUserObjectId":"61acc57699",
    //    "Version":"324",
    //    "skip":0,
    //    "Type":"GetWorkPushNotices"}}
    
    //请求数据字典初始化
    inputDataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],kCityObjectId,
                    kUser,kUserType,
                    bUser?bUser.objectId:@"" ,kToUserObjectId,
                    kGetWorkPushNotices,kType,
                    kCloudVersion,kVersion,
                    @0,kskip,
                    nil];
    //            [inputDataDic setObject:@"10"forKey:@"limit"];
    
    //数据数组初始化
    data = [NSMutableArray array];
    
    nodataimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data"]];
    nodataimage.frame = CGRectMake(Width/2 - 62.5, Height/2 - 62.5 - 65, 125, 125);
    [self.view addSubview:nodataimage];
    //    nodataimage.hidden = YES;
    
    //防止网络卡，菊花一直转
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    //请求数据
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        
        NSArray*  data1 = [[NSArray alloc] init];
        //stop timer
        [timer invalidate];
        if (obj)
        {
            //获取数据
            data1 = [WorkNews objectArrayWithKeyValuesArray:[obj objectForKey:@"PushNotices"]];
            if (data1.count != 0) {
                nodataimage.hidden = YES;
            }
            else
            {
                nodataimage.hidden = NO;
            }
            //将数据添加到data数组
            [data addObjectsFromArray:data1];
            //菊花消失
            [SVProgressHUD dismiss];
            //tabview刷新
            [WorkNewsTableView reloadData];
        }
    }fail:^(NSString *err)
     {
         //网络卡时，菊花消失
         [SVProgressHUD dismiss];
     }];
}


//YZtime = [NSTimer timerWithTimeInterval:4 target:self selector:@selector(time_picture) userInfo:nil repeats:YES];
//[[NSRunLoop currentRunLoop] addTimer:YZtime forMode:NSRunLoopCommonModes];


/**
 *  上拉刷新数据
 */
- (void)loadNewData
{
    //防止网络卡菊花一直转判断
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    //下拉菊花转也转
    [WorkNewsTableView.mj_header beginRefreshing];
    
    //    [inputDataDic setObject:@"10" forKey:@"limit"];
    
    //请求数据啦
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
        NSArray*  data1 = [[NSArray alloc] init];
        //stop  timer
        [timer invalidate];
        if (obj)
        {
            //请求到PushNotices中的数据
            data1 = [WorkNews objectArrayWithKeyValuesArray:[obj objectForKey:@"PushNotices"]];
            if (data1.count != 0) {
                nodataimage.hidden = YES;
            }
            else
            {
                nodataimage.hidden = NO;
            }
            [SVProgressHUD showSuccessWithStatus:@"刷新成功啦!"];
            //判断data是否为空，空就删除它
            if (data) {
                [data removeAllObjects];
            }
            //添加新的数据到data
            [data addObjectsFromArray:data1];
            //下拉菊花转呀转的停止
            [WorkNewsTableView.mj_header endRefreshing];
            //tabview刷新
            [WorkNewsTableView reloadData];
        }
    }fail:^(NSString *err)
     {
         [SVProgressHUD showErrorWithStatus:@"刷新失败,请检测下网络吧"];
         //下拉菊花停止
         [WorkNewsTableView.mj_header endRefreshing];
         //菊花停止
         [SVProgressHUD dismiss];
         //        [WorkNewsTableView reloadData];
     }];
    
}
/**
 *  请求数据回调
 *
 *  @return data
 */
#pragma mark - servers
- (void)getMainDataWithDict:(NSDictionary *)dict success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    
    //格式化请求数据体
    inputData = [NSDictionary dictionaryWithObject:dict forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:@"V3_Message" withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                //成功请求到数据
                success(object);
            }else{
                fail(kDataErrorWarning);
                //kDataErrorWarning
                [WorkNewsTableView.mj_header endRefreshing];
                //                [WorkNewsTableView.footer endRefreshing];
            }
        }else{
            fail(kNetworkWarning);
            //kNetworkWarning
            LOG(@"getmaindataerror%@",err);
            [WorkNewsTableView.mj_header endRefreshing];
            //            [WorkNewsTableView.footer endRefreshing];
            
        }
    }];
}
/**
 *  uitableviewdatasources
 *
 *  @param CGFloat 高度，数量，cell详细
 *
 *  @return cell
 */
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
    //notice是否为空，空返回nil
    if (notice)
    {
        //文本
        UILabel * Content = (UILabel *)[cell viewWithTag:201];
        Content.text = notice.Content;
        //标题
        UILabel * title = (UILabel *)[cell viewWithTag:203];
        title.text = notice.Title;
        //time
        UILabel * time = (UILabel *)[cell viewWithTag:202];
        time.text = [self uptime:notice.createdAt];
        //是否显示这个view
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

#pragma mark - 刷新或者上拉加载超时

//刷新或者上拉加载超时
- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [WorkNewsTableView.mj_header endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请检查下你的网路哟~" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alertView show];
        
        //        [WorkNewsTableView.footer endRefreshing];
    }
}

/**
 *  cell固定化时间格式
 *
 *  @param createtime <#createtime description#>
 *
 *  @return time
 */
- (NSString *)uptime:(NSString *)createtime
{
    NSRange range = {5,11};
    createtime = [createtime substringWithRange:range];
    return createtime;
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回上一层
- (void)leftbacktap
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - tableView didSelectRow
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [WorkNewsTableView deselectRowAtIndexPath:indexPath animated:YES];
    NotificationViewController *dgVC = [[NotificationViewController alloc] init];
    WorkNews *notice = [data objectAtIndex:indexPath.row];
    
    [dgVC setWorkObjectId:notice.WorkObjectId];//[self getWorkObjectId:notice.Value]
    dgVC.workOrderObjectId = notice.WorkOrderObjectId;
    
//    [self.delegate Remove_Red:@"3" andRemove_red:notice.WorkOrderObjectId andType:kDismissApplyWorkListItemRedPoint];
    [self.delegate Remove_Red2:@"3" andRemove_red:notice.WorkOrderObjectId andType:kDismissApplyWorkListItemRedPoint];
    [self.navigationController pushViewController:dgVC animated:YES];
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

#pragma mark -  viewDidAppear

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        for (int i = 0; i < data.count; i++)
//        {
//            if (![[[data objectAtIndex:i] objectForKey:@"Red"] isEqualToString:@"false"])
//            {
//                return ;
//            }
//            if (data.count-1 == i)
//            {
//                [self.delegate RemovelocalRed:@"3"];
//            }
//        }
        
        
        
//        //请求数据啦
//        [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
//            NSArray*  data1 = [[NSArray alloc] init];
//            //stop  timer
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
}

@end
