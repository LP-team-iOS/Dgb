//
//  MyApplyViewController.m
//  duangongbang
//
//  Created by ljx on 15/9/29.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "MyApplyViewController.h"
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import "CommonServers.h"
#import <MJRefresh.h>
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "SVProgressHUD.h"
#import "UIScrollView+EmptyDataSet.h"
#import "DGDetailViewController.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "NotificationViewController.h"


#define kGetInputDataType @"GetWorkList"
#define kLimit @"limit"
#define kOrder @"order"
#define kCityId @"cityId"
#define kType @"Type"
#define kMethod @"method"
#define kClassifyId @"classifyId"
#define kSkip @"skip"
#define kAreaId @"areaId"
#define kUserObjectId @"UserObjectId"



@interface MyApplyViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray * _listData;
    BmobUser * bUser;
    NSMutableDictionary *_callCloudDic;
    NSInteger num;

}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UITableView *tableView3;
@property (weak, nonatomic) IBOutlet UITableView *tableView4;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;

- (IBAction)back:(id)sender;

@end

@implementation MyApplyViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainView.userInteractionEnabled = YES;
    self.mainView.frame = CGRectMake(0, 0, Width*4, Height- 44 -64);
    [self.scrollView addSubview:self.mainView];
    [self configTopView];
    [self configScrollView];
    [self configToolBar];
    [self configTableView];

    if (_page == nil) {
        self.button1.selected = YES;
        [self.tableView1.mj_header beginRefreshing];
    }else {
        switch ([_page intValue]) {
            case 0:
                [self topViewAction:self.button1];
                [self.tableView1.mj_header beginRefreshing];
                break;
            case 1:
                [self topViewAction:self.button2];
                [self.tableView2.mj_header beginRefreshing];
                break;
            case 2:
                [self topViewAction:self.button3];
                [self.tableView3.mj_header beginRefreshing];
                break;
            case 3:
                [self topViewAction:self.button4];
                [self.tableView4.mj_header beginRefreshing];
                break;
            default:
                break;
        }
        
    }
    
    _listData = [[NSMutableArray alloc]init];
    
    
}

#pragma mark - topView
- (void)configTopView
{
    self.topView.backgroundColor = [UIColor colorWithRed:48/255.0 green:50/255.0 blue:63/255.0 alpha:1.0];

    self.button1.frame = CGRectMake(0, 20, Width/4, 44);
    [self.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.button1 addTarget:self action:@selector(topViewAction:) forControlEvents:UIControlEventTouchUpInside];
    self.button2.frame = CGRectMake(Width/4, 20, Width/4, 44);
    [self.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.button2 addTarget:self action:@selector(topViewAction:) forControlEvents:UIControlEventTouchUpInside];
    self.button3.frame = CGRectMake((Width/4)*2, 20, Width/4, 44);
    [self.button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.button3 addTarget:self action:@selector(topViewAction:) forControlEvents:UIControlEventTouchUpInside];
    self.button4.frame = CGRectMake((Width/4)*3, 20, Width/4, 44);
    [self.button4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.button4 addTarget:self action:@selector(topViewAction:) forControlEvents:UIControlEventTouchUpInside];


}

- (void)topViewAction:(UIButton *)sender
{
    
    if (sender == self.button1) {
        [self.tableView1.mj_header beginRefreshing];
        self.button1.selected = YES;
        self.button2.selected = NO;
        self.button3.selected = NO;
        self.button4.selected = NO;
        self.scrollView.contentOffset = CGPointMake(0, 0);
        
            
    }else if (sender == self.button2){
        [self.tableView2.mj_header beginRefreshing];
        self.button1.selected = NO;
        self.button2.selected = YES;
        self.button3.selected = NO;
        self.button4.selected = NO;
        self.scrollView.contentOffset = CGPointMake(Width, 0);
    }else if (sender == self.button3){
        [self.tableView3.mj_header beginRefreshing];
        self.button1.selected = NO;
        self.button2.selected = NO;
        self.button3.selected = YES;
        self.button4.selected = NO;
        self.scrollView.contentOffset = CGPointMake(Width*2, 0);

    }else if (sender == self.button4){
        [self.tableView4.mj_header beginRefreshing];
        self.button1.selected = NO;
        self.button2.selected = NO;
        self.button3.selected = NO;
        self.button4.selected = YES;
        self.scrollView.contentOffset = CGPointMake(Width*3, 0);

    }else {
    
    }
    

}
#pragma mark - scrollView
- (void)configScrollView
{
    self.scrollView.contentSize = CGSizeMake(Width*4, Height - 44 - 64);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (scrollView == _scrollView) {
        
        num = _scrollView.contentOffset.x/Width;
                switch (num) {
            case 0:{
                
                [self.tableView1.mj_header beginRefreshing];
                self.button1.selected = YES;
                self.button2.selected = NO;
                self.button3.selected = NO;
                self.button4.selected = NO;
                
            }
                break;
            case 1:{
                
                [self.tableView2.mj_header beginRefreshing];
                self.button1.selected = NO;
                self.button2.selected = YES;
                self.button3.selected = NO;
                self.button4.selected = NO;
                
            }
                break;
            case 2:{

                [self.tableView3.mj_header beginRefreshing];
                self.button1.selected = NO;
                self.button2.selected = NO;
                self.button3.selected = YES;
                self.button4.selected = NO;
                
            }
                break;
            case 3:{
    
                [self.tableView4.mj_header beginRefreshing];
                
                self.button1.selected = NO;
                self.button2.selected = NO;
                self.button3.selected = NO;
                self.button4.selected = YES;
                
            }
                break;
            default:
                break;
        }
    }

}

#pragma mark - tableView
- (void)configTableView
{
    self.tableView1.frame = CGRectMake(0, 0, Width, Height - 44 - 64);
    self.tableView1.delegate = self;
    self.tableView1.dataSource = self;
    self.tableView1.showsVerticalScrollIndicator = NO;
    self.tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView2.frame = CGRectMake(Width, 0, Width, Height - 44 - 64);
    self.tableView2.delegate = self;
    self.tableView2.dataSource = self;
    self.tableView2.showsVerticalScrollIndicator = NO;
    self.tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView3.frame = CGRectMake(Width*2, 0, Width, Height - 44 - 64);
    self.tableView3.dataSource = self;
    self.tableView3.delegate = self;
    self.tableView3.showsVerticalScrollIndicator = NO;
    self.tableView3.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView4.frame = CGRectMake(Width*3, 0, Width, Height - 44 - 64);
    self.tableView4.dataSource = self;
    self.tableView4.delegate = self;
    self.tableView4.showsVerticalScrollIndicator = NO;
    self.tableView4.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    MyRefresh * header1 = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header1.stateLabel.hidden = YES;
    header1.lastUpdatedTimeLabel.hidden = YES;
    self.tableView1.mj_header = header1;
    MyRefreshFooter * footer1 = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer1.refreshingTitleHidden = YES;
    footer1.stateLabel.hidden = YES;
    self.tableView1.mj_footer = footer1;
    
    MyRefresh * header2 = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header2.stateLabel.hidden = YES;
    header2.lastUpdatedTimeLabel.hidden = YES;
    self.tableView2.mj_header = header2;
    MyRefreshFooter * footer2 = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer2.refreshingTitleHidden = YES;
    footer2.stateLabel.hidden = YES;
    self.tableView2.mj_footer = footer2;
    
    MyRefresh * header3 = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header3.stateLabel.hidden = YES;
    header3.lastUpdatedTimeLabel.hidden = YES;
    self.tableView3.mj_header = header3;
    MyRefreshFooter * footer3 = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer3.refreshingTitleHidden = YES;
    footer3.stateLabel.hidden = YES;
    self.tableView3.mj_footer = footer3;
    
    MyRefresh * header4 = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header4.stateLabel.hidden = YES;
    header4.lastUpdatedTimeLabel.hidden = YES;
    self.tableView4.mj_header = header4;
    MyRefreshFooter * footer4 = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer4.refreshingTitleHidden = YES;
    footer4.stateLabel.hidden = YES;
    self.tableView4.mj_footer = footer4;
    
}

//刷新或者上拉加载超时
- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [self.tableView1.mj_header endRefreshing];
        [self.tableView1.mj_footer endRefreshing];
        [self.tableView2.mj_header endRefreshing];
        [self.tableView2.mj_footer endRefreshing];
        [self.tableView3.mj_header endRefreshing];
        [self.tableView3.mj_footer endRefreshing];
        [self.tableView4.mj_header endRefreshing];
        [self.tableView4.mj_footer endRefreshing];
    }
}

- (void)loadNewData
{
    [_listData removeAllObjects];
    bUser = [BmobUser getCurrentUser];
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    NSInteger i = self.scrollView.contentOffset.x/Width;
    UIImageView *noDataImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"no_data"]];
    noDataImageView.frame = CGRectMake((Width/2 - 62.5)+Width*i, Height/2 - 100, 125, 125);

    if (i == 0) {
        /*
         *  Apply
         *{"inputData":{"limit":50,"Version":"310","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetApplyWorks"}}
         */
        
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @0,@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetApplyWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];

            _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"Works"]];
            [self.tableView1 reloadData];
            [self.tableView1.mj_header endRefreshing];
            if (_listData.count == 0) {
                self.tableView1.hidden = YES;
                [self.scrollView addSubview:noDataImageView];
            }
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView1.mj_header endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];
    }
    else if (i == 1)
    {
        /*
         *  Read
         *{"inputData":{"limit":50,"Version":"310","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetReadWorks"}}
         */
//        [self.tableView2.header beginRefreshing];
        
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @0,@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetReadWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];
            _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"Works"]];
            [self.tableView2 reloadData];
            [self.tableView2.mj_header endRefreshing];
            if (_listData.count == 0) {
                self.tableView2.hidden = YES;
                [self.scrollView addSubview:noDataImageView];
            }

            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView2.mj_header endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];

    }
    else if (i == 2)
    {
        /*
         *  GetPassWorks
         *{"inputData":{"limit":50,"Version":"310","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetPassWorks"}}
         */
        
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @0,@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetPassWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];
            _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"Works"]];
            [self.tableView3 reloadData];
            [self.tableView3.mj_header endRefreshing];
            if (_listData.count == 0) {
                self.tableView3.hidden = YES;
                [self.scrollView addSubview:noDataImageView];
            }
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView3.mj_header endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];

    }
    else
    {
        /*
         *  Reject
         *{"inputData":{"limit":50,"Version":"307","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetRejectWorks"}}
         */
        
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @0,@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetRejectWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];
            _listData = [NSMutableArray arrayWithArray:[obj objectForKey:@"Works"]];
            [self.tableView4 reloadData];
            [self.tableView4.mj_header endRefreshing];
            if (_listData.count == 0) {
                self.tableView4.hidden = YES;
                [self.scrollView addSubview:noDataImageView];
            }
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView4.mj_header endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];

    }
    
}


- (void)loadMoreData
{
    
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    bUser = [BmobUser getCurrentUser];
    NSInteger i = self.scrollView.contentOffset.x/Width;

    if (i == 0) {
        /*
         *  Apply
         *{"inputData":{"limit":50,"Version":"310","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetApplyWorks"}}
         */
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @(_listData.count),@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetApplyWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            
            [timer invalidate];
            
            NSArray * array = [obj objectForKey:@"Works"];

            [_listData addObjectsFromArray:array];
            [self.tableView1 reloadData];
            [self.tableView1.mj_header endRefreshing];
            [self.tableView1.mj_footer endRefreshing];
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView1.mj_header endRefreshing];
            [self.tableView1.mj_footer endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];
    }
    else if (i == 1)
    {
        /*
         *  Read
         *{"inputData":{"limit":50,"Version":"310","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetReadWorks"}}
         */
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @(_listData.count),@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetReadWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];
            NSArray * array = [obj objectForKey:@"Works"];
            [_listData addObjectsFromArray:array];
            [self.tableView2 reloadData];
            [self.tableView2.mj_header endRefreshing];
            [self.tableView2.mj_footer endRefreshing];
            
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView2.mj_header endRefreshing];
            [self.tableView2.mj_footer endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];
        
    }
    else if (i == 2)
    {
        /*
         *  GetPassWorks
         *{"inputData":{"limit":50,"Version":"310","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetPassWorks"}}
         */
        
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @(_listData.count),@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetPassWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];
            NSArray * array = [obj objectForKey:@"Works"];
            [_listData addObjectsFromArray:array];
            [self.tableView3 reloadData];
            [self.tableView3.mj_header endRefreshing];
            [self.tableView3.mj_footer endRefreshing];
            
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView3.mj_header endRefreshing];
            [self.tableView3.mj_footer endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];
        
    }
    else
    {
        /*
         *  Reject
         *{"inputData":{"limit":50,"Version":"307","order":"-createdAt","skip":0,"UserObjectId":"bf7dc21fb4","Type":"GetRejectWorks"}}
         */
        bUser = [BmobUser getCurrentUser];
        _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         @10,kLimit,
                         kVersion,@"Version",
                         @"-createdAt",@"order",
                         @(_listData.count),@"skip",
                         bUser ? bUser.objectId : @"",kUserObjectId,
                         @"GetRejectWorks",@"Type",
                         nil];
        
        [CommonServers callCloudWithAPIName:kCloudUser andDic:_callCloudDic success:^(id obj){
            [timer invalidate];
            NSArray * array = [obj objectForKey:@"Works"];
            [_listData addObjectsFromArray:array];
            [self.tableView4 reloadData];
            [self.tableView4.mj_header endRefreshing];
            [self.tableView4.mj_footer endRefreshing];
            
            
        }fail:^(NSString *str){
            
            [self stopRefreshing:timer];
            [timer invalidate];
            [self.tableView4.mj_header endRefreshing];
            [self.tableView4.mj_footer endRefreshing];
            [SVProgressHUD showErrorWithStatus:kNetworkWarning];
            
        }];
        
    }

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//        DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
//        [dgVC setWorkObjectId:[[_listData objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:dgVC animated:YES];
    if (_listData.count) {
        NotificationViewController *noticficationVC = [[NotificationViewController alloc]init];
        noticficationVC.workOrderObjectId = [[_listData objectAtIndex:indexPath.row] objectForKey:@"WorkOrderObjectId"];
        
        noticficationVC.workObjectId = [[_listData objectAtIndex:indexPath.row] objectForKey:@"objectId"];
        
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:noticficationVC animated:YES];
        
        if (![self.page isEqualToString:@"0"]) {
            [self.delegate Remove_Red2:[NSString stringWithFormat:@"1%d",(int)[self.page integerValue]+1] andRemove_red:[[_listData objectAtIndex:indexPath.row] objectForKey:@"WorkOrderObjectId"] andType:kDismissApplyWorkListItemRedPoint];
            }
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            for (int i = 0; i < _listData.count; i++)
//            {
//                if (![[[_listData objectAtIndex:i] objectForKey:@"Red"] isEqualToString:@"false"])
//                {
//                    return ;
//                }
//                if (_listData.count-1 == i)
//                {
//                    [self.delegate RemovelocalRed:[NSString stringWithFormat:@"1%d",(int)[self.page integerValue]+1]];
//                }
//            }
//            
//        });
        }
    else{
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
    }
    
}

#pragma mark - UITableViewDataSources
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configToolBar
{
    self.toolBar.barTintColor = RGB(48, 50, 63, 1.0);
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
