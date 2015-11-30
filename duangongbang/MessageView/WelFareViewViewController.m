//
//  WelFareViewViewController.m
//  duangongbang
//
//  Created by ljx on 15/11/23.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "WelFareViewViewController.h"
#import "DGDetailViewController.h"

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
#import "PersistenceHelper.h"

@interface WelFareViewViewController ()<UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>
{
    BmobUser *bUser;
    UIImageView * nodataimage;

}

//Data
@property (nonatomic, strong) MainDataModel *dataModel;
@property (nonatomic, strong) NSMutableArray *workListArray;
@property (nonatomic, strong) NSMutableDictionary *callCloudDic;
@property (nonatomic, strong) PersistenceHelper *archive;
@property (nonatomic, assign) BOOL nibRegistered;
@property (nonatomic, strong) UITableView * mainTableView;


@end

@implementation WelFareViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //导航栏的配置
    self.title = _str_Description;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    //BarButton
    UIBarButtonItem * leftback = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"detailBackIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:0 target:self action:@selector(leftbacktap)];
    self.navigationItem.leftBarButtonItem = leftback;
    
    //提示语
    UILabel * la = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Width, 21)];
    la.text = @"短工邦直营工作专区: 官方认证,薪资保障,护送上岗";
    la.textColor = [UIColor whiteColor];
    la.backgroundColor =  RGB(255, 164, 20, 1.0);
    la.font = [UIFont systemFontOfSize:13];
    la.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:la];
    
    //tabview初始化
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 21, Width, Height - 41)];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTableView];
    
    nodataimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data"]];
    nodataimage.frame = CGRectMake(Width/2 - 62.5, Height/2 - 62.5 - 65, 125, 125);
    [self.view addSubview:nodataimage];
    
    [self config];
    [self configTableView];
    [self loadNewData];
    
}

#pragma mark - viewWillAppear


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
}

#pragma mark - didReceiveMemoryWarning


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
        [dgVC setWorkObjectId:[[_workListArray objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
        [self.navigationController pushViewController:dgVC animated:YES];
    }
    else{
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
    }
    
    
}
#pragma mark - configure

- (void)configTableView
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    MyRefresh * header1 = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header1.stateLabel.hidden = YES;
    header1.lastUpdatedTimeLabel.hidden = YES;
    self.mainTableView.mj_header = header1;
    MyRefreshFooter * footer1 = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.mainTableView.mj_footer = footer1;
}

#pragma mark - config _ dic

- (void)config
{
    bUser = [BmobUser getCurrentUser];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSDictionary *dic = @{
                          kCityObjectId:[[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:kobjectId],
                          klimit: @"10",
                          kDescription:self.str_Description?self.str_Description:@"",
                          korder:kcreatedAt,
                          kVersion:kCloudVersion,
                          kskip:@"0",
                          kUserObjectId:@"",
                          kType:kWorkTopic1,
                          };
    
    _callCloudDic = [dic mutableCopy];
    

    
}
#pragma mark - Methods Or Actions

- (void)leftbacktap{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - loadNewData

- (void)loadNewData{
    [_callCloudDic setObject:@0 forKey:@"skip"];
    
    @try {
        [SVProgressHUD show];
        [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id object) {
            if (object) {

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

                if (_workListArray.count == 0)
                {
                    nodataimage.hidden = NO;
                }
                else
                {
                    nodataimage.hidden = YES;
                }
                
            }
        } fail:^(NSString *reason) {
            [SVProgressHUD showErrorWithStatus:reason];
        }];
    }
    @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
    }
    @finally {
        [self.mainTableView.mj_header endRefreshing];
        [self.mainTableView.mj_footer endRefreshing];
    }
    
    
}

#pragma mark - loadMoreData

- (void)loadMoreData
{
    
    NSString *skip = [NSString stringWithFormat:@"%lu", (unsigned long)_workListArray.count];
    [_callCloudDic setObject:skip forKey:@"skip"];
    
    [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id obj){
                
        NSArray * array = [obj objectForKey:@"Works"];
        if (array.count == 0) {
            [SVProgressHUD showErrorWithStatus:kNoMoreWorks];
        }else{
            [_workListArray addObjectsFromArray:array];
            
            [self.mainTableView reloadData];
            
        }
        [self.mainTableView.mj_header endRefreshing];
        [self.mainTableView.mj_footer endRefreshing];
        
    }fail:^(NSString *str){
        
        //            [self stopRefreshing:timer];
        //            [timer invalidate];
        [self.mainTableView.mj_header endRefreshing];
        [self.mainTableView.mj_footer endRefreshing];
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
        
    }];
}

#pragma mark -  viewDidAppear

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
    
}

@end
