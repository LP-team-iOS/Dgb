//
//  DirectSupportAcceptedViewController.m
//  duangongbang
//
//  Created by Macist on 15/11/5.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "DirectSupportAcceptedViewController.h"
#import "DirectAcceptedDetailViewController.h"

//  直营列表缓存

#define kDirectSupportAcceptedWorkListKey @"DirectSupportAcceptedWorkList"
#define kNoMoreWorks @"没有更多岗位"

#import "DGDetailViewController.h"

/**
 *  视图类，工具类（网络通信类，本地缓存类，视图类别类）
 */
#import <BmobSDK/BmobUser.h>
#import "CommonServers.h"

#import "SVProgressHUD.h"
#import "MainDataModel.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "LoginViewController.h"
#import "PersistenceHelper.h"


@interface DirectSupportAcceptedViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BmobUser *bUser;
    UIImageView *_nodataImageV;
}

//Data
@property (nonatomic, strong) MainDataModel *dataModel;
@property (nonatomic, strong) NSMutableArray *workListArray;
@property (nonatomic, strong) NSMutableDictionary *callCloudDic;
@property (nonatomic, strong) PersistenceHelper *archive;
@property (nonatomic, assign) BOOL nibRegistered;

@end

@implementation DirectSupportAcceptedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self config];
    [self configTableView];
    [self loadNewData];
    //    [self setHidesBottomBarWhenPushed:YES];
    // Do any additional setup after loading the view from its nib.
    
        //logineasemob
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:@"3c018af4d1" password:@"QAZWSXEDC" completion:^(NSDictionary *loginInfo, EMError *error) {
            if (!error && loginInfo) {
                NSLog(@"登陆成功");
                NSLog(@"loginInfo:%@",loginInfo);
            }else if (error.errorCode == EMErrorTooManyLoginRequest){
                NSLog(@"登录成功");
                NSLog(@"log error :%@",error.description);
    
            }else{
                [SVProgressHUD showErrorWithStatus:@"登录失败，请检查网络连接并重新登录！"];
            }
        } onQueue:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
   
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - uitableviewdatasources

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _workListArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (Width > 320) {
        static NSString *simpleIdentify = @"jobCell2";
        JobTableViewCell2 *nib = (JobTableViewCell2 *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell2" owner:self options:nil]lastObject];
        }
        [nib setAllFrameWithWorkList:[_workListArray objectAtIndex:indexPath.row]];
        nib.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return nib;
    }else {
        static NSString *simpleIdentify = @"jobCell";
        JobTableViewCell *nib = (JobTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell" owner:self options:nil]lastObject];
        }
        [nib setAllFrameWithWorkList:[_workListArray objectAtIndex:indexPath.row]];
        nib.selectionStyle = UITableViewCellSelectionStyleNone;
        return nib;
    }

    
}

#pragma mark - uitableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_workListArray.count) {
        DirectAcceptedDetailViewController *noticficationVC = [[DirectAcceptedDetailViewController alloc]init];
        
        NSDictionary *dic = [_workListArray objectAtIndex:indexPath.row];
        
        noticficationVC.workTitle = [dic objectForKey:@"Title"];
        noticficationVC.selfWorkDic = [dic objectForKey:@"SelfWork"];
        
        noticficationVC.workOrderObjectId = [[_workListArray objectAtIndex:indexPath.row] objectForKey:@"WorkOrderObjectId"];
        
        noticficationVC.workObjectId = [[_workListArray objectAtIndex:indexPath.row] objectForKey:@"objectId"];
        
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:noticficationVC animated:YES];
        
        [self.delegate Remove_Red2:@"2" andRemove_red:[[_workListArray objectAtIndex:indexPath.row] objectForKey:@"WorkOrderObjectId"] andType:kDismissApplyWorkListItemRedPoint];
    }
    else{
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
    }

//    [self setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:dgVC animated:YES];
//    [self setHidesBottomBarWhenPushed:NO];
    
}
#pragma mark - configure

- (void)configTableView
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    //    _mainTableView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
    
    
    MyRefresh * header1 = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header1.stateLabel.hidden = YES;
    header1.lastUpdatedTimeLabel.hidden = YES;
    self.mainTableView.header = header1;
    MyRefreshFooter * footer1 = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    //        footer1.stateLabel.hidden = YES;
    self.mainTableView.footer = footer1;
    
    
}


- (void)config
{
    bUser = [BmobUser getCurrentUser];

    
    _nodataImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data"]];
    _nodataImageV.frame = CGRectMake(Width/2 - 62.5, Height/2 - 62.5 - 65, 125, 125);
    [self.view addSubview:_nodataImageV];
    
    /**
     *  {"inputData": {"DeviceType":"ios","CityObjectId":"Cbqr444B","limit":20,"Type":"GetSelfWorkList","Version":"324","skip":0 ,"UserObjectId":"61acc57699"}}
     */
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSDictionary *dic = @{
                          @"CityObjectId":[[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],
                          @"limit": @10,
                          @"Type": @"GetSelfWorkList",
                          @"Version": kCloudVersion,
                          @"skip": @0,
                          @"UserObjectId":bUser ? bUser.objectId:@"",
                          };
    _callCloudDic = [dic mutableCopy];
    
    [self.navigationItem setHidesBackButton:YES];
    self.view.backgroundColor = [UIColor blackColor];
    //导航栏的配置
    self.title = @"送岗专区";
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _titleLabel.superview.hidden = YES;
    self.toolBar.barTintColor = kmainBlackColor;
    self.toolBar.translucent = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNewData) name:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];

    
}
#pragma mark - Methods Or Actions

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 网络通信 Get data
/**
 *  array = newarray >> reloaddata >> endrefresh
 *
 *  @param str  <#str description#>
 *  @param type <#type description#>
 */

- (void)loadNewData{
    [_callCloudDic setObject:@0 forKey:@"skip"];
    NSLog(@"INPUT :%@",_callCloudDic);
    
    @try {
        [SVProgressHUD show];
        [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id object) {
            if (object) {
                NSLog(@"data:%@",object);
                //            NSLOG(object);
                if ([[object objectForKey:@"Static"] isEqualToString:@"success"]) {
                    if ([object isKindOfClass:[NSMutableArray class]]) {
                        _workListArray = [object objectForKey:@"Works"];
                    }else{
                        _workListArray = [NSMutableArray new];
                        [_workListArray addObjectsFromArray:[object objectForKey:@"Works"]];
                    }
                    
                    [_archive archiveData:_workListArray withKey:kDirectSupportAcceptedWorkListKey];
                    [SVProgressHUD showSuccessWithStatus:@"获取数据成功"];
                    [_mainTableView reloadData];
                }else {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[object objectForKey:@"Value"]]];
                }
            }
            if (_workListArray.count == 0)
            {
                _nodataImageV.hidden = NO;
            }
            else
            {
                _nodataImageV.hidden = YES;
            }
            
        } fail:^(NSString *reason) {
            [SVProgressHUD showErrorWithStatus:reason];
        }];
    }
    @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
    }
    @finally {
        [self.mainTableView.header endRefreshing];
    }
}


- (void)loadMoreData
{
    
    //    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    //            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                             @10,kLimit,
    //                             kVersion,@"Version",
    //                             @"-createdAt",@"order",
    //                             @(_listData.count),@"skip",
    //                             bUser ? bUser.objectId : @"",kUserObjectId,
    //                             @"GetApplyWorks",@"Type",
    //                             nil];
    
    NSString *skip = [NSString stringWithFormat:@"%lu", (unsigned long)_workListArray.count];
    [_callCloudDic setObject:skip forKey:@"skip"];
    
    [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id obj){
        
        //            [timer invalidate];
        
        NSArray * array = [obj objectForKey:@"Works"];
        if (array.count == 0) {
            [SVProgressHUD showErrorWithStatus:kNoMoreWorks];
        }else{
            [_workListArray addObjectsFromArray:array];
            
            [self.mainTableView reloadData];
            
        }
        [self.mainTableView.header endRefreshing];
        [self.mainTableView.footer endRefreshing];
        
    }fail:^(NSString *str){
        
        //            [self stopRefreshing:timer];
        //            [timer invalidate];
        [self.mainTableView.header endRefreshing];
        [self.mainTableView.footer endRefreshing];
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
        
    }];
}


- (void)commentWithContent:(NSString *)str type:(NSString *)type{
    
    
}


#pragma mark -  viewDidDisappear

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        [_callCloudDic setObject:@0 forKey:@"skip"];
//        @try {
//            [SVProgressHUD show];
//            [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id object) {
//                if (object) {
//                    if ([[object objectForKey:@"Static"] isEqualToString:@"success"]) {
//                        if ([object isKindOfClass:[NSMutableArray class]]) {
//                            _workListArray = [object objectForKey:@"Works"];
//                        }else{
//                            _workListArray = [NSMutableArray new];
//                            [_workListArray addObjectsFromArray:[object objectForKey:@"Works"]];
//                        }
//                        [_archive archiveData:_workListArray withKey:kDirectSupportAcceptedWorkListKey];
//                        [SVProgressHUD showSuccessWithStatus:@"获取数据成功"];
//                        //                    [_mainTableView reloadData];
//                        
//                        for (int i = 0; i < _workListArray.count; i++)
//                        {
//                            if (![[[_workListArray objectAtIndex:i] objectForKey:@"Red"] isEqualToString:@"false"])
//                            {
//                                return ;
//                            }
//                            if (_workListArray.count-1 == i)
//                            {
//                                [self.delegate RemovelocalRed:@"2"];
//                            }
//                        }
//
//                    }else {
//                    }
//                }
//            } fail:^(NSString *reason) {
//            }];
//        }
//        @catch (NSException *exception) {
//        }
//        @finally {
//        }
//    });

    
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

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];

}


@end

/**
 *  
 1.在数据获取完成之前，用户点击返回，而hud却依然在显示，如何避免？在viewdiddisappear里结束任务，停止hud。
 */
