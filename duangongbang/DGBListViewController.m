//
//  DGBListViewController.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/7/20.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import "CommonServers.h"
#import "DGBListViewController.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "UIImageView+WebCache.h"
#import <MJRefresh/MJRefresh.h>
#import "SVProgressHUD.h"
#import "UIScrollView+EmptyDataSet.h"
#import "DGDetailViewController.h"

#import "MyRefresh.h"
#import "MyRefreshFooter.h"

@interface DGBListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_listData;
    BmobUser *bUser;
    NSMutableArray *refreshingImages;
    NSMutableDictionary *_callCloudDic;
    __weak IBOutlet UITableView *_tableView;
    BOOL isLoadData;
    UIImageView *nodataimage;
}

@end


@implementation DGBListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlackColor);
    //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    bUser = [ShareDataSource sharedDataSource].myData;
    self.tabBarController.tabBar.hidden = YES;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout= UIRectEdgeNone;
    _tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _listData = [[NSMutableArray alloc] init];
    
    MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData:)];
    header.stateLabel.hidden = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.mj_header = header;
    // 马上进入刷新状态
    [_tableView.mj_header beginRefreshing];
    
    [self callCloudAndReturnData];
    

    [self.navigationController.navigationBar setTitleTextAttributes:
     
  @{NSFontAttributeName:[UIFont systemFontOfSize:17],
    
    NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    nodataimage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_data"]];
    nodataimage.frame = CGRectMake(Width/2 - 62.5, Height/2 - 62.5 - 65, 125, 125);
    [self.view addSubview:nodataimage];

    switch (_listStates) {
        case UITableViewListApply:
             self.title = @"我的申请";
            break;
        case UITableViewListVideoResume:
             self.title = @"视频简历库";
            break;
        case UITableViewListCollections:
             self.title = @"我的收藏";
            break;
        case UITableViewListMyRelease:
             self.title = @"我的发布";
            break;
            default:
            break;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.listStates) {
        case UITableViewListApply:{
            DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
            [dgVC setWorkObjectId:[[_listData objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:dgVC animated:YES];
        }
            break;
        case UITableViewListCollections:{
            DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
            dgVC.workObjectId = [[_listData objectAtIndex:indexPath.row]objectForKey:@"objectId"];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:dgVC animated:YES];
        }
            break;
        case UITableViewListMyRelease:{
            
        }
            break;
    }
}

#pragma mark - UITableViewDataSources
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (self.listStates) {
        case UITableViewListApply:
            return kCellHeight;
            break;
        case UITableViewListVideoResume:
            return kCellHeight;
            break;
        case UITableViewListCollections:
            return kCellHeight;
            break;
        case UITableViewListMyRelease:
            return kCellHeight;
            break;
    }
    
    return 22;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (self.listStates) {
        case UITableViewListApply:
            return _listData.count;
            break;
        case UITableViewListVideoResume:
            return _listData.count;
            break;
        case UITableViewListCollections:
            return _listData.count;
            break;
        case UITableViewListMyRelease:
            
            break;
    }
    return _listData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (self.listStates) {
        case UITableViewListApply:{
            static NSString *simpleIdentify = @"jobCell";
            JobTableViewCell *cell = (JobTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell" owner:self options:nil]lastObject];
            }
            [cell setAllFrameWithWorkList:[_listData objectAtIndex:indexPath.row]];
            return  cell;
        }
        
            break;
        case UITableViewListCollections:{
            if (Width > 320) {
                static NSString *simpleIdentify = @"jobCell2";
                JobTableViewCell2 *nib = (JobTableViewCell2 *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
                if (nib == nil) {
                    nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell2" owner:self options:nil]lastObject];
                }
                [nib setAllFrameWithWorkList:[_listData objectAtIndex:indexPath.row]];
                nib.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return nib;
            }else {
                static NSString *simpleIdentify = @"jobCell";
                JobTableViewCell *nib = (JobTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
                if (nib == nil) {
                    nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell" owner:self options:nil]lastObject];
                }
                [nib setAllFrameWithWorkList:[_listData objectAtIndex:indexPath.row]];
                nib.selectionStyle = UITableViewCellSelectionStyleNone;
                return nib;
            }
        }
            break;
        case UITableViewListMyRelease:
            break;
    }
    UITableViewCell *cell;
    return cell;
}

- (void)loadNewData:(id)sender {
    
    
    bUser = [ShareDataSource sharedDataSource].myData;
    
    switch (self.listStates) {
        case UITableViewListApply:{
            /**
             *  Apply
             *{"Type":"GetMyApplyWork","Version":"3","UserObjectId":"f6b7ed5517","skip":0,"limit":10}
             */
            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"GetMyApplyWork",@"Type",
                             kCloudVersion,@"Version",
                             bUser ? bUser.objectId : @"", @"UserObjectId",
                             @0, @"skip",
                             @10, @"limit",
                             nil];
            [CommonServers callCloudWithAPIName:kCloudAccount andDic:_callCloudDic success:^(id obj){

                _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"WorkList"]];
                [_tableView.mj_header endRefreshing];
                [_tableView reloadData];
                if (_listData.count == 0)
                {
                    nodataimage.hidden = NO;
                }
                else
                {
                    nodataimage.hidden = YES;
                }

            }fail:^(NSString *str){
                
                [_tableView.mj_header endRefreshing];
                [SVProgressHUD showErrorWithStatus:kNetworkWarning];
                
            }];
            
        }
            break;
        case UITableViewListVideoResume:{
            /**
             *  VideoResume
             *  {"Type":"GetMyVideoList","Version":kCloudVersion,"CityObjectId":"xxx","UserObjectId":"4dac0354b2","order":"-createdAt","limit":10,"skip":0}
             */
            
            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GetMyVideoList",@"Type",kCloudVersion,@"Version",[[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],@"CityObjectId",bUser ? bUser.objectId : @"",@"UserObjectId",@"-createdAt",@"order",@10,@"limit",@0,@"Skip", nil];
            [CommonServers callCloudWithAPIName:kCloudVideo andDic:_callCloudDic success:^(id obj){
                if (obj) {
                    _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"VideoList"]];
                    [_tableView.mj_header endRefreshing];
                    [_tableView reloadData];

                }
            }fail:^(NSString *err){
                
                [_tableView.mj_header endRefreshing];
                [SVProgressHUD showErrorWithStatus:kNetworkWarning];

            }];
            
        }
            break;
        case UITableViewListCollections:
        {
            /**
             *  Collections
             *  {"inputData":{"Version":"321","Type":"GetMyFavourWorks","skip":0,"limit":0,"UserObjectId":"61acc57699","DeviceType":"android"}}
             */
            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"GetMyFavourWorks",@"Type",
                             kCloudVersion,@"Version",
                             bUser ? bUser.objectId : @"", @"UserObjectId",
                             @0, @"skip",
                             @10, @"limit",
                             @"ios",@"DeviceType",
                             nil];
            
            [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
                _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"Works"]];
                [_tableView.mj_header endRefreshing];
                [_tableView reloadData];
                if (_listData.count == 0)
                {
                    nodataimage.hidden = NO;
                }
                else
                {
                    nodataimage.hidden = YES;
                }
            }fail:^(NSString *str){
                
                [_tableView.mj_header endRefreshing];
                [SVProgressHUD showErrorWithStatus:kNetworkWarning];
                
            }];
    }
            
            break;
            default:
            break;
    }
    
    
}

- (void)loadMoreData:(id)sender {
    
    bUser = [ShareDataSource sharedDataSource].myData;
    
    switch (self.listStates) {
        case UITableViewListApply:{
            /**
             *  Apply
             *{"Type":"GetMyApplyWork","Version":"3","UserObjectId":"f6b7ed5517","skip":0,"limit":10}
             */
            
            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"GetMyApplyWork",@"Type",
                             kCloudVersion,@"Version",
                             bUser ? bUser.objectId : @"", @"UserObjectId",
                             @(_listData.count), @"skip",
                             @10, @"limit",
                             nil];
            [CommonServers callCloudWithAPIName:kCloudAccount andDic:_callCloudDic success:^(id obj){
                _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"WorkList"]];
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                [_tableView reloadData];
            }fail:^(NSString *str){
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                [SVProgressHUD showErrorWithStatus:kNetworkWarning];
                
            }];
            
        }
            break;
        case UITableViewListVideoResume:{
            /**
             *  VideoResume
             *  {"Type":"GetMyVideoList","Version":kCloudVersion,"CityObjectId":"xxx","UserObjectId":"4dac0354b2","order":"-createdAt","limit":10,"skip":0}
             */
            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"GetMyVideoList",@"Type",
                             kCloudVersion,@"Version",
                             [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],@"CityObjectId",
                             bUser ? bUser.objectId : @"",@"UserObjectId",
                             @"-createdAt",@"order",
                             @10,@"limit",
                             @(_listData.count),@"Skip",
                             nil];
            [CommonServers callCloudWithAPIName:kCloudVideo andDic:_callCloudDic success:^(id obj){
                if (obj) {
                    _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"VideoList"]];
                    [_tableView.mj_header endRefreshing];
                    [_tableView.mj_footer endRefreshing];
                    [_tableView reloadData];
                }
            }fail:^(NSString *err){
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                [SVProgressHUD showErrorWithStatus:kNetworkWarning];
                
            }];
            
        }
            break;
        case UITableViewListCollections:
        {
            /**
             *  Collections
             *  *
             */
            _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"GetMyFavourWorks",@"Type",
                             kCloudVersion,@"Version",
                             bUser ? bUser.objectId : @"", @"UserObjectId",
                             @(_listData.count), @"skip",
                             @10, @"limit",
                             @"ios",@"DeviceType",
                             nil];
            [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
                [_listData addObjectsFromArray:[obj objectForKey:@"Works"]];
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                [_tableView reloadData];
            }fail:^(NSString *str){
                
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
                [SVProgressHUD showErrorWithStatus:kNetworkWarning];
                
            }];
    }
            break;
        case UITableViewListMyRelease:
            /**
             *  MyRelease
             *
             */
            break;
        default:
            break;
    }
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    return rightUtilityButtons;
}

- (void)callCloudAndReturnData{
    
    switch (_listStates) {
        case UITableViewListApply:
            break;
        case UITableViewListVideoResume:
            break;
        case UITableViewListCollections:
            break;
        case UITableViewListMyRelease:
            break;
            default:
            break;
    }
}

- (void)backPop{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
