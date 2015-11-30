//
//  DGListViewController.m
//  duangongbang
//
//  Created by ljx on 15/5/13.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "DGListViewController.h"
#import "DOPDropDownMenu.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "MJRefresh.h"
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>
#import "DGDetailViewController.h"
#import "UIImage+UIColor.h"
#import "PersistenceHelper.h"
#import "UINavigationController+MoveBottomBlackLine.h"
#import "GetFilters.h"
#import "DGSearchViewViewController.h"
#import "SVProgressHUD.h"
#import "UIScrollView+EmptyDataSet.h"
#import "TOWebViewController.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"



#define kLimit @"limit"
#define kOrder @"order"
#define kCityId @"cityId"
#define kType @"Type"
#define kMethod @"method"
#define kClassifyId @"classifyId"
#define kSkip @"skip"
#define kAreaId @"areaId"
//#define kUserObjectId @"userObjectId"

#define kGetInputDataType @"GetWorkList"

@interface DGListViewController ()<DOPDropDownMenuDataSource,DOPDropDownMenuDelegate,MBProgressHUDDelegate>{
    BmobUser *bUser;
    
    
    NSMutableArray *classifyLabelArray;
    NSMutableArray *classifyLabelObjectIdArray;//存放选中标签objectId
    
    NSMutableArray *areaLabelArray;
    NSMutableArray *areaLabelObjectIdArray;
    
    NSArray *titlesArray;
    NSMutableArray *classifys;
    NSArray *cate0;
    NSArray *cate1;
    NSArray *cate2;
    NSMutableArray *areas;
    NSArray *pay;
    NSArray *sorts;
    
    NSMutableDictionary *getWorkDic;
    MBProgressHUD *HUD;
    NSString *cityId;
    NSString *payMethod;
    
    NSMutableArray *workListArray;
    
    PersistenceHelper *archive;
    
    DOPDropDownMenu *menu;
    NSMutableArray *refreshingImages;

}

@property (weak, nonatomic) UIImageView *logoImg;
@property (weak, nonatomic) UIBarButtonItem *btnMassage;

@end

@implementation DGListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationController.navigationBar.translucent = NO;

    bUser = [ShareDataSource sharedDataSource].myData;
    archive = [[PersistenceHelper alloc] init];
    
    if ([archive unarchiveDatawithKey:kWorkListKey]) {
        workListArray = [archive unarchiveDatawithKey:kWorkListKey];
        // 设置正在刷新状态的动画图片
        MyRefreshFooter * footer = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreWorks)];

        footer.stateLabel.hidden = NO;
        _mainTableView.mj_footer = footer;
        [_mainTableView reloadData];
    }else{
        
        MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData:)];
        header.stateLabel.hidden = YES;
        header.lastUpdatedTimeLabel.hidden = YES;
        _mainTableView.mj_header = header;
        // 马上进入刷新状态
        [_mainTableView.mj_header beginRefreshing];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [menu hideWhenDisAppear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainTableView.contentInset = UIEdgeInsetsMake(16, 0, 0, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;


    //去除navigationBar黑线
    [self.navigationController moveBottomBlackLine];
    
    classifys = [[NSMutableArray alloc] init];
    classifyLabelArray = [[NSMutableArray alloc] init];
    classifyLabelObjectIdArray = [[NSMutableArray alloc] init];
    areas = [[NSMutableArray alloc] init];
    areaLabelObjectIdArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatCategoryMean) name:KEY_KVO_CREAT_CATEGORY_MEAN object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_CREAT_CATEGORY_MEAN object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseNewCityAndLoadList) name:KEY_KVO_GET_WORK_LIST object:nil];
    /**
     *  {"inputData":{"limit":20,"order":"-createdAt","cityId":"ZUaK444F","Type":"GetWorkList","method":"日结","classifyId":"","skip":0,"areaId":"","userObjectId":"61acc57699"}}
     */
    bUser = [ShareDataSource sharedDataSource].myData;
    getWorkDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  @20,kLimit,
                  @"-createdAt",kOrder, //or Price
                  kGetInputDataType,kType,
                  [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],kCityId,
                  @"",kMethod,
                  @"",kClassifyId,
                  @0,kSkip,
                  @"",kAreaId,
                  bUser ? bUser.objectId : @"",kUserObjectId,
                  nil];
    
    MyRefresh * header = [MyRefresh headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData:)];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    header.stateLabel.hidden = YES;

    _mainTableView.mj_header = header;
    
    MyRefreshFooter * footer = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreWorks)];
    
    footer.stateLabel.hidden = YES;
    
    _mainTableView.mj_footer = footer;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!animated) {

    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_CREAT_CATEGORY_MEAN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_GET_WORK_LIST object:nil];
    
    menu.delegate = nil;
    menu.dataSource = nil;
}

- (void)dgSearchView:(id)sender {
    DGSearchViewViewController *dgSearchView = [[DGSearchViewViewController alloc] initWithNibName:@"DGSearchViewViewController" bundle:nil];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:dgSearchView animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - DZNEmptyDataSetSource
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"no_data"];
}

#pragma mark - uitableviewdatasources
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return workListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (Width > 320) {
        static NSString *simpleIdentify = @"jobCell2";
        JobTableViewCell2 *nib = (JobTableViewCell2 *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell2" owner:self options:nil]lastObject];
        }
        [nib setAllFrameWithWorkList:[workListArray objectAtIndex:indexPath.row]];
        nib.selectionStyle = UITableViewCellSelectionStyleNone;

        return nib;
    }else {
        static NSString *simpleIdentify = @"jobCell";
        JobTableViewCell *nib = (JobTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell" owner:self options:nil]lastObject];
        }
        [nib setAllFrameWithWorkList:[workListArray objectAtIndex:indexPath.row]];
        nib.selectionStyle = UITableViewCellSelectionStyleNone;
        return nib;
    }
    
}

#pragma mark - uitableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
    [dgVC setWorkObjectId:[[workListArray objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:dgVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

#pragma mark - 获取分类导航数据
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu
{
    return titlesArray.count;
}

- (NSArray *)titlesOfMenu:(DOPDropDownMenu *)menu
{
    return titlesArray;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column
{
    if (column == 0) {
        return classifys.count;
    }else if (column == 1){
        return areas.count;
    }else if (column == 2){
        return pay.count;
    }else{
        return sorts.count;
    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        return classifys[indexPath.row];
    }else if (indexPath.column == 1){
        return areas[indexPath.row];
    }else if (indexPath.column == 2){
        return pay[indexPath.row];
    }else{
        return sorts[indexPath.row];
    }
    
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column
{
    if (column == 0) {
//        
//        if (row == 1) {
//            return cate0.count;
//        }else if (row == 2){
//            return cate1.count;
//        }
//        
        //
        //        if (row == 0) {
        //            return cates.count;
        //        }
    }
    return 0;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForItemsInRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.column == 0) {
        if (indexPath.row == 1) {
            return cate0[indexPath.item];
        }else if (indexPath.row == 2){
            return cate1[indexPath.item];
        }
        //        if (indexPath.row == 0) {
        //            return cates[indexPath.item];
        //        }
    }
    return nil;
}

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath
{
    if (indexPath.item >= 0) {
        //LOG(@"点击了 %ld - %ld - %ld 项目",(long)indexPath.column,(long)indexPath.row,(long)indexPath.item);
    }else {
        //LOG(@"点击了 %ld - %ld 项目",(long)indexPath.column,(long)indexPath.row);
    }
    
    if(indexPath.column == 0){
        
        [getWorkDic setObject:[[classifys objectAtIndex:indexPath.row] isEqualToString:@"不限"] ? @"" : [classifyLabelObjectIdArray objectAtIndex:indexPath.row] forKey:kClassifyId];
        
        if (indexPath.row == 0) {
            
        }
        
        if (indexPath.row == 1) {
            if (indexPath.item >= 0) {
                
            }
            
        }else if(indexPath.row == 2){
            if (indexPath.item >= 0) {
                
            }
        }
        
    }else if (indexPath.column == 1){
        
        [getWorkDic setObject:[areaLabelObjectIdArray objectAtIndex:indexPath.row] forKey:kAreaId];
        
        if (indexPath.row == 0) {
            
            
        }else if(indexPath.row == 1){
            
        }else{
            
        }
        
    }else if (indexPath.column == 2){
        
        [getWorkDic setObject:[[pay objectAtIndex:indexPath.row] isEqualToString:@"不限"] ? @"" : [pay objectAtIndex:indexPath.row] forKey:kMethod];
        
        if (indexPath.row == 0) {
            
        }else{
            
        }
        
    }else{
        
        if (indexPath.row == 0) {
            
            [getWorkDic setObject:@"-createdAt" forKey:kOrder];
            
        }else if (indexPath.row == 1){
            
            [getWorkDic setObject:@"Price" forKey:kOrder];
            
        }
        
    }
    
    [_mainTableView.mj_header beginRefreshing];

}

#pragma mark - methods
- (void)creatCategoryMean{
    
    @try {
        if ([USER_DEFAULT objectForKey:kCategoriesAndArea]) {
            
            NSDictionary *dicClassify = [GetFilters getAllClassisfyWithArray:[[USER_DEFAULT objectForKey:kCategoriesAndArea] objectForKey:@"Classify"]];
            NSDictionary *dicArea = [GetFilters getAllAreaWithArray:[[USER_DEFAULT objectForKey:kCategoriesAndArea] objectForKey:@"Area"]];
            
            classifys = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:0];
//            classifyLabelArray = [[dicClassify objectForKey:kClassifyNameArray] objectForKey:0];
            classifyLabelObjectIdArray = [[dicClassify objectForKey:kClassifyObjectIdArray] objectAtIndex:0];
            areas = [dicArea objectForKey:kAreaName];
            areaLabelObjectIdArray = [dicArea objectForKey:kAreaObject];
        }
        
        titlesArray = @[@"类型",@"地区",@"结算",@"排序"];
        pay = @[@"不限",@"日结",@"周结",@"月结",@"其他"];
        sorts = @[@"最新发布",@"最高价格"];
        //  下拉分类菜单
        menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, -1) andHeight:64];
        menu.delegate = self;
        menu.dataSource = self;
        [self.view addSubview:menu];
    }
    @catch (NSException *exception) {
        LOG(@"CreatMenuError:%@",exception);
        classifys = [NSMutableArray arrayWithObject:@"不限"];
//        classifyLabelArray = [NSMutableArray arrayWithObjects:@"", nil];
        classifyLabelObjectIdArray = [NSMutableArray arrayWithObjects:@"",nil];
        areas = [NSMutableArray arrayWithObject:@"全城"];
        areaLabelObjectIdArray = [NSMutableArray arrayWithObject:@""];
        titlesArray = @[@"类型",@"地区",@"结算",@"排序"];
        pay = @[@"不限",@"日结",@"周结",@"月结",@"其他"];
        sorts = @[@"最新发布",@"最高价格"];
        //  下拉分类菜单
        menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:64];
        menu.delegate = self;
        menu.dataSource = self;
        [self.view addSubview:menu];
    }
    @finally {
        
    }
    
    
}

- (void)loadNewData:(id)sender{
    
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    [getWorkDic setObject:@0 forKey:@"skip"];
    
    @try {
        [self callWorkCloudWithDic:getWorkDic success:^(NSDictionary *obj){
            //取消计时器
            [timer invalidate];
            workListArray = [obj objectForKey:@"Works"];
            [archive archiveData:workListArray withKey:kWorkListKey];
            [_mainTableView.mj_header endRefreshing];
            [_mainTableView reloadData];
            if (_mainTableView.mj_footer == nil) {
                // 设置正在刷新状态的动画图片
                
                [menu reloadData];
                
                MyRefreshFooter * footer = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreWorks)];
//                _mainTableView.gifFooter.stateHidden = YES;
                footer.stateLabel.hidden = NO;
                _mainTableView.mj_footer = footer;
            }
        }fail:^(NSString *err){
            //[self showMBProgressHUD:err];
            [timer invalidate];
            [self stopRefreshing:timer];
        }];
    }
    @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
    }
    @finally {
        
    }
    
}

- (void)loadMoreWorks{
    
    //当刷新请求超过规定秒时，停止刷新
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];
    
    NSInteger skipNo = workListArray.count;
    
    [getWorkDic setObject:[NSNumber numberWithInteger:skipNo] forKey:kSkip];
    
    [self callWorkCloudWithDic:getWorkDic success:^(NSDictionary *obj){
        
        //取消计时器
        [timer invalidate];
        
        if (workListArray.count==0) {
            //[self showMBProgressHUD:@"已无更多数据.."];
            
        }else{
            NSArray *array =  [workListArray arrayByAddingObjectsFromArray:[obj objectForKey:@"Works"]];
            workListArray = [NSMutableArray arrayWithArray:array];
            [archive archiveData:workListArray withKey:kWorkListKey];
            [_mainTableView reloadData];
            
        }
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        MyRefreshFooter * footer = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreWorks)];
        footer.stateLabel.hidden = NO;
        _mainTableView.mj_footer = footer;
        [_mainTableView.mj_footer endRefreshing];
        
        
    } fail:^(NSString *reason){
        //[self showMBProgressHUD:reason];
    }];
    
}

//刷新或者上拉加载超时
- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [_mainTableView.mj_header endRefreshing];
        [_mainTableView.mj_footer endRefreshing];
    }
}

- (void)chooseNewCityAndLoadList{
    [getWorkDic setObject:@"" forKey:kAreaId];
    [getWorkDic setObject:[[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"] forKey:kCityId];
    [_mainTableView.mj_header beginRefreshing];
    
}

#pragma mark - Servers
/**
 *  云代码调用
 *
 *  @param inputDic 传入inputData
 *  @param success  返回成功字典
 *  @param fail     反悔是啊比字符串
 */
- (void)callWorkCloudWithDic:(NSMutableDictionary *)inputDic success:(void (^)(NSDictionary *obj))success fail:(void (^)(NSString *err))fail{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:inputDic forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:kCloudWork withParameters:dict block:^(id obj, NSError *err){
        if (obj) {
            success(obj);
        }
        if (err) {
            fail(kNetworkWarning);
        }
    }];
}

@end
