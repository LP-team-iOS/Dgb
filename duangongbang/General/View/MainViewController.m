//
//  MainViewController.m
//  duangongbang
//
//  Created by ljx on 15/4/23.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//


#import "MainViewController.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "UIImage+ImageEffects.h"
#import "LoginViewController.h"
#import "VisitorChooseViewController.h"
#import "ChooseLabelViewController.h"
#import "DGDetailViewController.h"
#import "MainDataModel.h"
#import <BmobSDK/Bmob.h>
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "PersistenceHelper.h"
#import "UIImage+Resize.h"
#import "PulsingHaloLayer.h"
#import "SVProgressHUD.h"
#import "LaunchScreenViewController.h"
#import <pop/POP.h>
#import "CityLocationViewController.h"
#import "UINavigationController+MoveBottomBlackLine.h"
#import "LoginViewController.h"
#import "TOWebViewController.h"
#import "RFRateMe.h"
#import "AFNetworking.h"
#import "ChatViewController.h"
#import "DGSearchViewViewController.h"
#import "WelFareViewViewController.h"

#define kVersion         @"Version"
#define kType            @"Type"
#define kAreaData        @"AreaData"
#define kClassifyData    @"ClassifyData"
#define kCityObjectId    @"CityObjectId"
#define kUserObjectId    @"UserObjectId"
#define kDeviceId        @"DeviceId"
#define kLongitude       @"Longitude"
#define kLatitude        @"Latitude"

#define kWebValue        @"Web1"
#define kDescriptionUrl  @"Description"

@interface MainViewController ()<MBProgressHUDDelegate>{
    BmobUser *bUser;
    CGFloat alpha;
    BOOL isRefreshing;
    NSDictionary *inputData;
    NSDictionary *mainDataDic;
    MainDataModel *mainModel;
    NSMutableDictionary *inputDataDic;
    NSString *path;
    PersistenceHelper *archive;
    BOOL isSelectedVisitor;//在主页面直接push到存在navBar的页面为yes
    
    UIView *alertTheAction;
    UIImageView *imageViewAlert;
    UIImageView *stageViewAlert;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentTwoLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentOneLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hiTopContant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBGPImgTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pptToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refreshImgBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *refreshReplaceImg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgpImgToPrivateConstant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableViewHeight;

@property (weak, nonatomic) IBOutlet UIView *viewNavView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UITableView *jobTableView;
@property (weak, nonatomic) IBOutlet UIView *privateView;
@property (weak, nonatomic) IBOutlet UIView *customView;

@property (strong, nonatomic) IBOutlet UIView *viewMainView;

@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPT1;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPT2;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPT3;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPT4;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPTH1;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPTH2;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPTV1;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPTV2;
@property (weak, nonatomic) IBOutlet UIImageView *imgPPT;

@property (weak, nonatomic) IBOutlet UIImageView *mainBackgroupImg;

@property (weak, nonatomic) IBOutlet UIImageView *refreshReImg;

@property (weak, nonatomic) IBOutlet UIImageView *refreshImg;

@property (weak, nonatomic) IBOutlet UIButton *btnPlace;

@property (weak, nonatomic) IBOutlet UIButton *btnPrivate;

@property (weak, nonatomic) IBOutlet UILabel *lbUserRole;

@property (strong, nonatomic) UIImageView *imgHeadPro;
@property (assign, nonatomic) BOOL screensaverLaunched;
@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:isSelectedVisitor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    bUser = [BmobUser getCurrentUser];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([[USER_DEFAULT objectForKey:MY_CITY_KEY] isKindOfClass:[NSDictionary class]]){
            
        }else{
            LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logVC];

            [self presentViewController:nav animated:YES completion:nil];
        }
    });
    
    
    
    //      提示进入评分
    [RFRateMe showRateAlertAfterTimesOpened:5];
    
    archive = [[PersistenceHelper alloc] init];
    if ([archive unarchiveDatawithKey:kMainModelKey]) {
        mainModel = [archive unarchiveDatawithKey:kMainModelKey];
        [self performSelectorOnMainThread:@selector(setAllView:) withObject:mainModel waitUntilDone:NO];
    }else {
        
    }
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSInteger timesOpened = [defaults integerForKey:@"timesOpened"];
//    if (timesOpened == 1) {
//        
//        alertTheAction = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainScreenWidth, mainScreenHeight + 20)];
//        alertTheAction.backgroundColor = UIColorFromRGBAlpha(0x212121, 0.3);
//        [self.tabBarController.view addSubview:alertTheAction];
//        imageViewAlert = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Alert_Video"]];
//        imageViewAlert.contentMode = UIViewContentModeCenter;
//        imageViewAlert.center = CGPointMake(mainScreenWidth * 0.5, mainScreenHeight - 168);
//        imageViewAlert.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoImageAlert:)];
//        [imageViewAlert addGestureRecognizer:tap];
//        [alertTheAction addSubview:imageViewAlert];
//    }
    
    [ShareDataSource sharedDataSource].myData = [BmobUser getCurrentUser];
    
//    [self scrollToTop];
    
    // Do any additional setup after loading the view from its nib.
    [_mainScrollView setContentOffset:CGPointZero animated:YES];
    
    [_btnPrivate addTarget:self action:@selector(privateButton:) forControlEvents:UIControlEventTouchUpInside];
    [_btnPlace addTarget:self action:@selector(selectCityButtom:) forControlEvents:UIControlEventTouchUpInside];
    //  分割线高度
    _segmentOneLineHeight.constant = 0.5;
    _segmentTwoLineHeight.constant = 0.5;
    
    _viewNavView.backgroundColor = UIColorFromRGBAlpha(xMainBlackColor, 1.0);
    
    _constraintTableViewHeight.constant = 112;
    
//    [_jobTableView setNeedsLayout];
    [_jobTableView updateConstraints];
    
    CGFloat viewHeight = 112 + (mainScreenWidth == 320 ? 176 : 160)*(mainScreenWidth/320) + mainScreenWidth;

    CGSize size = CGSizeMake(mainScreenWidth, viewHeight);
    
    _viewMainView.frame = CGRectMake(0, 0, size.width, size.height);
    
    _mainScrollView.contentSize = _viewMainView.frame.size;
    [_mainScrollView addSubview:_viewMainView];
    
//    self.imgHeadPro = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Head_Image.png"]];
//    self.imgHeadPro.layer.masksToBounds = YES;
//    self.imgHeadPro.hidden = YES;
//    [_viewNavView addSubview:self.imgHeadPro];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMessageCebter:)];
//    _refreshImg.userInteractionEnabled = YES;
//    [_refreshImg addGestureRecognizer:tap];
    
    //tableView注册复用
    
    [_jobTableView registerNib:[UINib nibWithNibName:@"JobTableViewCell2" bundle:nil] forCellReuseIdentifier:@"jobCell2"];
    [_jobTableView registerNib:[UINib nibWithNibName:@"JobTableViewCell" bundle:nil] forCellReuseIdentifier:@"jobCell"];

    //add KVO
    [_refreshReplaceImg addObserver:self forKeyPath:KEY_KVO_RefreshReplaceImg options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToTop) name:KEY_KVO_SCROLLTOTOPWHENFIRSTTAPPED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMainData) name:KEY_KVO_GETMAINDATA object:nil];
    //FIXME: 导致第一次加载是没用页面。
    if (![[USER_DEFAULT objectForKey:MY_CITY_KEY] isKindOfClass:[NSDictionary class]]){
        return;
    }
    
    [self.navigationController moveBottomBlackLine];
    
    @try {
        [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];
        [self getMainData];
    }
    @catch (NSException *exception) {
        LOG(@"mianFirstGetDataError:%@",exception);
    }
    @finally {
        
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    isSelectedVisitor = NO;
    

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!animated) {
        
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [_refreshReplaceImg removeObserver:self forKeyPath:KEY_KVO_RefreshReplaceImg];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_GETMAINDATA object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_SCROLLTOTOPWHENFIRSTTAPPED object:nil];
}

#pragma mark - 设置主页所有数据
- (void)setAllView:(id)sender{

    bUser = [ShareDataSource sharedDataSource].myData;
    
    if (bUser) {
#pragma mark - 环信登录
        [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
    }
    _searchBackgroundView.layer.cornerRadius = 15.0f;
    [_searchBackgroundView.layer setMasksToBounds:YES];
    
    [_searchButton addTarget:self action:@selector(searchAndInvitation) forControlEvents:UIControlEventTouchUpInside];
    
    _lbUserRole.text = mainModel.customRule;
    NSMutableString* string = [NSMutableString stringWithString:[[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"CityName"]];
    NSString *aStr = [string substringToIndex:[string length] - 1];
//    _btnPlace.titleLabel.text = [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"CityName"];
    _btnPlace.titleLabel.text = aStr;
//    [_btnPlace setTitle:[[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"CityName"] forState:UIControlStateNormal];
    [_btnPlace setTitle:aStr forState:UIControlStateNormal];
    [self setPPTImageWithType:mainModel.pptType];
//    UIImage *image = _mainBackgroupImg.image;
//    UIImage *blurImg =nil;
//    blurImg = [image applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
//    _mainBackgroupImg.image = blurImg;
//    [_mainBackgroupImg sd_setImageWithURL:[NSURL URLWithString:mainModel.indexBackgroup] placeholderImage:blurImg completed:^(UIImage *image,NSError *err,SDImageCacheType cacheType,NSURL *imageURL){
////        UIImage *img = image;
////        UIImage *blurImage =nil;
////        blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
////        _mainBackgroupImg.image = blurImage;
//    }];
////    [_imgHeadPro sd_setImageWithURL:[NSURL URLWithString:mainModel] placeholderImage:(UIImage *)
    
//    BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
//    [_imgHeadPro sd_setImageWithURL:[NSURL URLWithString:headImg.url] placeholderImage:[UIImage imageNamed:@"Head_Image.png"]];
    
    _jobTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _constraintTableViewHeight.constant = kCellHeight * mainModel.workList.count;
    [_jobTableView updateConstraints];
    
    CGFloat viewHeight = (mainScreenWidth == 320 ? 176 : 160)*(mainScreenWidth/320) + kCellHeight * mainModel.workList.count + mainScreenWidth;
    
    CGSize size = CGSizeMake(mainScreenWidth, viewHeight);
    
    _viewMainView.frame = CGRectMake(0, 0, size.width, size.height);
    
    _mainScrollView.contentSize = _viewMainView.frame.size;
    
    [self saveObjectClassifyAndAreaDict:mainModel];
}

#pragma mark - uitableviewdatasources
- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return mainModel.workList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (Width > 320) {
        static NSString *simpleIdentify = @"jobCell2";
        JobTableViewCell2 *nib = (JobTableViewCell2 *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell2" owner:self options:nil]lastObject];
        }
        [nib setAllFrameWithWork:[mainModel.workList objectAtIndex:indexPath.row]];
        nib.selectionStyle = UITableViewCellSelectionStyleNone;

        return nib;
    }else {
        static NSString *simpleIdentify = @"jobCell";
        JobTableViewCell *nib = (JobTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell" owner:self options:nil]lastObject];
        }
        [nib setAllFrameWithWork:[mainModel.workList objectAtIndex:indexPath.row]];
        nib.selectionStyle = UITableViewCellSelectionStyleNone;
        return nib;
    }
    
}

#pragma mark - uitableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
    [dgVC setWorkObjectId:[[mainModel.workList objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
    dgVC.mainViewPush = YES;
    isSelectedVisitor = NO;
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:dgVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

#pragma mark - uiscrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _navViewTop.constant = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y <= 0.0){
        
        _viewBGPImgTop.constant = scrollView.contentOffset.y;
        
        
        _pptToTop.constant = 81.0 + scrollView.contentOffset.y;
        
        _navViewTop.constant = scrollView.contentOffset.y;
        
//        _refreshImg.alpha = (_refreshReplaceImg.constant - 7)/57.0;
        
//        if (!isRefreshing) {
//            _refreshReplaceImg.constant = 64.0 + scrollView.contentOffset.y;
//        }
//        if (scrollView.contentOffset.y <= -22.0) {
//            
////            if (!isRefreshing) {
////                _refreshImgBottom.constant = 29.0 + scrollView.contentOffset.y;
////            }
//            
//            if (scrollView.contentOffset.y <= -57.0) {
//                //[self rotate360DegreeWithImageView:_refreshReImg num:50];
////                _refreshImgBottom.constant = -28.0;
////                _refreshReplaceImg.constant = 7.0;
////                _refreshImg.alpha = 0.0;
//            }
//        }
    }
    if (scrollView.contentOffset.y >= 0.0) {
        
        _pptToTop.constant = 81.0 - scrollView.contentOffset.y * 0.2;
        
    }
//    if (scrollView.contentOffset
//        .y <= 42.0) {
////        self.imgHeadPro.hidden = YES;
//        _viewNavView.backgroundColor = UIColorFromRGBAlpha(xMainBlueColor,0.0f);
//    }
//    if (scrollView.contentOffset.y >= 42.0 && scrollView.contentOffset.y <= 164.0) {
//        self.imgHeadPro.hidden = NO;
//        
//        _viewNavView.backgroundColor = UIColorFromRGBAlpha(xMainBlueColor,(scrollView.contentOffset.y - 42)/122);
//        
//        imgRect = CGRectMake(temp.origin.x, temp.origin.y, 32.0 * (scrollView.contentOffset.y - 42.0)/122.0, 32.0 * (scrollView.contentOffset.y - 42.0)/122.0);
//        self.imgHeadPro.layer.cornerRadius = 16.0 * (scrollView.contentOffset.y - 42.0)/122.0;
//        self.imgHeadPro.layer.borderWidth = 1.5;
//        self.imgHeadPro.layer.borderColor = [UIColor whiteColor].CGColor;
//        self.imgHeadPro.frame = imgRect;
//        self.imgHeadPro.center = CGPointMake(36.0, 44.0);
//    }
//    if (scrollView.contentOffset.y >= 164.0){
//        temp.size = CGSizeMake(32.0, 32.0);
//        
//        _viewNavView.backgroundColor = UIColorFromRGBAlpha(xMainBlackColor, 1.0);
//        self.imgHeadPro.layer.cornerRadius = 16.0;
//        self.imgHeadPro.frame = temp;
//        self.imgHeadPro.center = CGPointMake(36.0, 44.0);
//        isRefreshing = NO;
//    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    if (_mainScrollView.contentOffset.y <= -57.0) {
//        _refreshImgBottom.constant = -28.0;
//        _refreshReplaceImg.constant = 7;
//        _refreshImg.alpha = 0.0;
//        [self rotate360DegreeWithImageView:_refreshReImg];
        [SVProgressHUD showWithStatus:@"正在刷新"];
        @try {
            if (isRefreshing == NO) {
                
                isRefreshing = YES;
                NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing) userInfo:nil repeats:NO];
                //  获取主页数据
                bUser = [ShareDataSource sharedDataSource].myData;
                [inputDataDic setObject:bUser ? bUser.objectId : @"" forKey:kUserObjectId] ;
                [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){
                    if (obj) {
                        [timer invalidate];
                        mainDataDic = obj;
//                        [SVProgressHUD showSuccessWithStatus:REFRESHED_SUCCESS_KEY];
                        [SVProgressHUD dismiss];
                        mainModel = [MainDataModel initMainDataWithDic:obj];
                        [archive archiveData:mainModel withKey:kMainModelKey];
                        isRefreshing = NO;
                        [self performSelectorOnMainThread:@selector(setAllView:) withObject:mainDataDic waitUntilDone:NO];
                        [_jobTableView reloadData];
                        [self finishedRefreshImageBack];
                    }
                }fail:^(NSString *err){
                    [timer invalidate];
                    [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
                    isRefreshing = NO;
                    [self finishedRefreshImageBack];
                }];
            }
        }
        @catch (NSException *exception) {
            LOG(@"mianFirstGetDataError:%@",exception);
            isRefreshing = NO;
        }
        @finally {
            
        }
        
    }
}

#pragma mark - Button
- (void)privateButton:(id)sender{
    isSelectedVisitor = YES;
    UINavigationController *nav = [[UINavigationController alloc] init];
    if (bUser) {
        ChooseLabelViewController *chooseVC = [[ChooseLabelViewController alloc] initWithNibName:@"ChooseLabelViewController" bundle:nil];
        [nav pushViewController:chooseVC animated:YES];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        VisitorChooseViewController *visitorVC = [[VisitorChooseViewController alloc] initWithNibName:@"VisitorChooseViewController" bundle:nil];
        visitorVC.thisViewIsPush = NO;
        [nav pushViewController:visitorVC animated:YES];
        [self presentViewController:nav animated:YES completion:nil];
    }
}
- (void)selectCityButtom:(id)sender{
    isSelectedVisitor = YES;
    CityLocationViewController *cityVC = [[CityLocationViewController alloc] init];
    cityVC.justChooseCity = YES;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cityVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}
- (void)refreshingSleep{
    sleep(2);
}

- (void)searchAndInvitation
{
    DGSearchViewViewController *dgSearchView = [[DGSearchViewViewController alloc] initWithNibName:@"DGSearchViewViewController" bundle:nil];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:dgSearchView animated:YES];
    self.hidesBottomBarWhenPushed = NO;

}

#pragma mark - methods
- (void)finishedRefreshImageBack{
    dispatch_async(dispatch_get_main_queue(), ^{
        POPAnimatableProperty *constantProperty = [POPAnimatableProperty propertyWithName:@"constant" initializer:^(POPMutableAnimatableProperty *prop){
            prop.readBlock = ^(NSLayoutConstraint *layoutConstraint, CGFloat values[]) {
                values[0] = [layoutConstraint constant];
            };
            prop.writeBlock = ^(NSLayoutConstraint *layoutConstraint, const CGFloat values[]) {
                [layoutConstraint setConstant:values[0]];
            };
        }];
        POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"alpha" initializer:^(POPMutableAnimatableProperty *prop){
            prop.writeBlock = ^(id obj, const CGFloat value[]) {
                _refreshImg.alpha = 1.0;
            };
        }];
        POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];
        anBasic.property = prop;
        anBasic.fromValue = @(0);
        anBasic.toValue = @(1);
        anBasic.duration = 1.0;
//        [_refreshImg pop_addAnimation:anBasic forKey:@"alpha"];
        [anBasic setCompletionBlock:^(POPAnimation *anim,BOOL isFinished){
//            _refreshImg.alpha = 1.0;
//            [_refreshReImg.layer removeAllAnimations];
            isRefreshing = NO;
        }];
        
        POPSpringAnimation *refreshImgAnimation = [POPSpringAnimation animation];
        refreshImgAnimation.property = constantProperty;
        refreshImgAnimation.fromValue = @(_refreshImgBottom.constant);
        refreshImgAnimation.springSpeed = 5;
        refreshImgAnimation.toValue = @(7.0);
//        [_refreshImgBottom pop_addAnimation:refreshImgAnimation forKey:@"constantAnimation"];
        
        POPSpringAnimation *refreshReplaceImgAnimation = [POPSpringAnimation animation];
        refreshReplaceImgAnimation.property = constantProperty;
        refreshReplaceImgAnimation.springSpeed = 5;
        refreshReplaceImgAnimation.fromValue = @(_refreshReplaceImg.constant);
        refreshReplaceImgAnimation.toValue = @(64.0);
//        [_refreshReplaceImg pop_addAnimation:refreshReplaceImgAnimation forKey:@"constantAnimation"];
        
        [UIView animateWithDuration:1.0 animations:^{
//            _refreshImg.alpha = 1.0;
        }completion:^(BOOL isFinished){
//            [_refreshReImg.layer removeAllAnimations];
            isRefreshing = NO;
        }];
        
    });
}

- (void)getMainData{
    
    /**
     * 云端代码传入参数
     *
     * {"Version":3,
     * "Type":"Visitor",
     * "AreaData":true,
     * "ClassifyData":true,
     * "CityObjectId":"Cbqr444B",
     * "UserObjectId":"",
     * "DeviceType":"ios",
     * "DeviceId":"15793E8F7AF5743F597BB7C54E42DAEF",
     * "Longitude":119.251189,
     * "Latitude":26.106024}
     */
//    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY  maskType:SVProgressHUDMaskTypeClear];
    
    NSNumber *latitude = [[USER_DEFAULT objectForKey:KEY_COORDINATE] objectForKey:KEY_COORDINATE_LATITUDE];
    NSNumber *longitude = [[USER_DEFAULT objectForKey:KEY_COORDINATE] objectForKey:KEY_COORDINATE_LONGITUDE];
    bUser = [ShareDataSource sharedDataSource].myData;
    inputDataDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:307],kVersion,
                    (bUser ? @"User" : @"Visitor"),kType,
                    [NSNumber numberWithBool:YES],kAreaData,
                    [NSNumber numberWithBool:YES],kClassifyData,
                    [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],kCityObjectId,
                    (bUser ? bUser.objectId : @""),kUserObjectId,
                    @"ios",kDeviceType,
                    longitude ? longitude : @0.0,kLongitude,
                    latitude ? latitude : @0.0,kLatitude,
                    [USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY],kDeviceId,
                    nil];
    

    //  获取主页数据
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing) userInfo:nil repeats:NO];
    
    [self getMainDataWithDict:inputDataDic success:^(NSDictionary *obj){

        if (obj) {
            [timer invalidate];
            mainDataDic = obj;

//            [SVProgressHUD showSuccessWithStatus:REFRESHED_SUCCESS_KEY maskType:SVProgressHUDMaskTypeClear];
            [SVProgressHUD dismiss];
            mainModel = [MainDataModel initMainDataWithDic:obj];
            [archive archiveData:mainModel withKey:kMainModelKey];
            [_jobTableView reloadData];
            [self performSelectorOnMainThread:@selector(setAllView:) withObject:mainDataDic waitUntilDone:NO];
        }
    }fail:^(NSString *err){
        [timer invalidate];
        [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
    }];
    
}

- (void)stopRefreshing{
    [SVProgressHUD showErrorWithStatus:kNetworkWarning];
}

- (void)scrollToTop{
    isSelectedVisitor = NO;
    if (_mainScrollView.contentOffset.y > 0) {
        [_mainScrollView setContentOffset:CGPointZero animated:YES];
    }
    
}

- (void)setImageWithUIImageView:(UIImageView *)imgView index:(int)index{
    imgView.hidden = NO;
    [imgView sd_setImageWithURL:[[mainModel.pptList objectAtIndex:index] objectForKey:@"ImgUrl"] placeholderImage:[UIImage imageNamed:@"PPT_Image_Base.png"] completed:^(UIImage *image,NSError *err,SDImageCacheType cacheType,NSURL *imageURL){
    }];
}

////  旋转
//- (UIImageView *)rotate360DegreeWithImageView:(UIImageView *)imageView{
//    CABasicAnimation *animation = [ CABasicAnimation
//                                   animationWithKeyPath: ANIMATION_ROTATION ];
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//    
//    //围绕Z轴旋转，垂直与屏幕
//    animation.toValue = [ NSValue valueWithCATransform3D:
//                         
//                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
//    animation.duration = 0.5;
//    
//    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
//    animation.cumulative = YES;
//    animation.repeatCount = refreshMaxTime * 2;
//    
//    [imageView.layer addAnimation:animation forKey:nil];
//    return imageView;
//}

- (void)pptImageViewAddGesture:(NSArray *)imageViewArray{
    
    for (int i = 0; i < mainModel.pptList.count; i++) {
        if ([[[mainModel.pptList objectAtIndex:i] objectForKey:@"Value"] isEqualToString:kWebValue]) {
            [[imageViewArray objectAtIndex:i] setUserInteractionEnabled:YES];
            [[imageViewArray objectAtIndex:i] setTag:i];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPPTAndOpenTheWebSite:)];
            [[imageViewArray objectAtIndex:i] addGestureRecognizer:singleTap];
        }
    }
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPPTAndOpenTheWebSite2:)];
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPPTAndOpenTheWebSite3:)];
    //            singleTap.tag = 100 + i;
    [self.imgPPT4 addGestureRecognizer:singleTap2];
    [self.imgPPT3 addGestureRecognizer:singleTap3];
}
- (void)touchPPTAndOpenTheWebSite2:(UITapGestureRecognizer *)sender{
    
    WelFareViewViewController *  Welfare = [[WelFareViewViewController alloc] init];
    Welfare.hidesBottomBarWhenPushed = YES;
    Welfare.str_Description = [[mainModel.pptList objectAtIndex:3] objectForKey:@"Description"];
    [self.navigationController pushViewController:Welfare animated:YES];
    //    self.hidesBottomBarWhenPushed = NO;
    
}

- (void)touchPPTAndOpenTheWebSite3:(UITapGestureRecognizer *)sender{
    WelFareViewViewController *  Welfare = [[WelFareViewViewController alloc] init];
    Welfare.hidesBottomBarWhenPushed = YES;
    Welfare.str_Description = [[mainModel.pptList objectAtIndex:2] objectForKey:@"Description"];
    [self.navigationController pushViewController:Welfare animated:YES];
}

- (void)setPPTImageWithType:(NSNumber *)type{
    
    _imgPPT.clipsToBounds = YES;
    _imgPPT1.clipsToBounds = YES;
    _imgPPT2.clipsToBounds = YES;
    _imgPPT3.clipsToBounds = YES;
    _imgPPT4.clipsToBounds = YES;
    _imgPPTH1.clipsToBounds = YES;
    _imgPPTH2.clipsToBounds = YES;
    _imgPPTV1.clipsToBounds = YES;
    _imgPPTV2.clipsToBounds = YES;
    _imgPPT.hidden = NO;
    _imgPPT1.hidden = NO;
    _imgPPT2.hidden = NO;
    _imgPPT3.hidden = NO;
    _imgPPT4.hidden = NO;
    _imgPPTH1.hidden = NO;
    _imgPPTH2.hidden = NO;
    _imgPPTV1.hidden = NO;
    _imgPPTV2.hidden = NO;
    switch ([type intValue]) {
        case 0:
            _imgPPT.alpha = 0.0;
            _imgPPTH1.hidden = YES;
            _imgPPTH2.hidden = YES;
            _imgPPTV1.hidden = YES;
            _imgPPTV2.hidden = YES;
            [self setImageWithUIImageView:_imgPPT1 index:0];
            [self setImageWithUIImageView:_imgPPT2 index:1];
            [self setImageWithUIImageView:_imgPPT3 index:2];
            [self setImageWithUIImageView:_imgPPT4 index:3];
            [self pptImageViewAddGesture:@[_imgPPT1,_imgPPT2,_imgPPT3,_imgPPT4,]];
            break;
        case 1:
            _imgPPT.alpha = 0.0;
            _imgPPT1.hidden = YES;
            _imgPPT2.hidden = YES;
            _imgPPT3.hidden = YES;
            _imgPPT4.hidden = YES;
            _imgPPTH1.hidden = YES;
            _imgPPTH2.hidden = YES;
            [self setImageWithUIImageView:_imgPPTV1 index:0];
            [self setImageWithUIImageView:_imgPPTV2 index:1];
            [self pptImageViewAddGesture:@[_imgPPTV1,_imgPPTV2]];
            break;
        case 2:
            _imgPPT.alpha = 0.0;
            _imgPPT1.hidden = YES;
            _imgPPT2.hidden = YES;
            _imgPPT3.hidden = YES;
            _imgPPT4.hidden = YES;
            _imgPPTV1.hidden = YES;
            _imgPPTV2.hidden = YES;
            [self setImageWithUIImageView:_imgPPTH1 index:0];
            [self setImageWithUIImageView:_imgPPTH2 index:1];
            [self pptImageViewAddGesture:@[_imgPPTH1,_imgPPTH2]];
            break;
        case 3:
            _imgPPT.alpha = 1.0;
            _imgPPT1.hidden = YES;
            _imgPPT2.hidden = YES;
            _imgPPT3.hidden = YES;
            _imgPPT4.hidden = YES;
            _imgPPTV1.hidden = YES;
            _imgPPTV2.hidden = YES;
            _imgPPTH1.hidden = YES;
            _imgPPTH2.hidden = YES;
            [self setImageWithUIImageView:_imgPPT index:0];
            [self pptImageViewAddGesture:@[_imgPPT]];
            break;
        case 4:
            _imgPPT.alpha = 0.0;
            _imgPPT1.hidden = YES;
            _imgPPT3.hidden = YES;
            _imgPPTH1.hidden = YES;
            _imgPPTH2.hidden = YES;
            _imgPPTV2.hidden = YES;
            [self setImageWithUIImageView:_imgPPTV1 index:0];
            [self setImageWithUIImageView:_imgPPT2 index:1];
            [self setImageWithUIImageView:_imgPPT4 index:2];
            [self pptImageViewAddGesture:@[_imgPPTV1,_imgPPT2,_imgPPT4]];
            break;
        case 5:
            _imgPPT.alpha = 0.0;
            _imgPPT1.hidden = YES;
            _imgPPT3.hidden = YES;
            _imgPPTV1.hidden = YES;
            _imgPPTV2.hidden = YES;
            _imgPPTH2.hidden = YES;
            [self setImageWithUIImageView:_imgPPTH1 index:0];
            [self setImageWithUIImageView:_imgPPT3 index:1];
            [self setImageWithUIImageView:_imgPPT4 index:2];
            [self pptImageViewAddGesture:@[_imgPPTH1,_imgPPT3,_imgPPT4]];
            break;
        case 6:
            _imgPPT.hidden = YES;
            _imgPPT1.hidden = YES;
            _imgPPT2.hidden = YES;
            _imgPPT3.hidden = YES;
            _imgPPT4.hidden = YES;
            _imgPPTH1.hidden = YES;
            _imgPPTH2.hidden = YES;
            _imgPPTV1.hidden = YES;
            _imgPPTV2.hidden = YES;
            break;
            
        default:
            break;
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:KEY_KVO_RefreshReplaceImg]) {

        _refreshImg.alpha = (_refreshReplaceImg.constant - 7)/57.0;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)saveObjectClassifyAndAreaDict:(id)object{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:mainModel.classify,@"Classify", mainModel.area, @"Area", nil];
    
    [USER_DEFAULT setObject:dict forKey:kCategoriesAndArea];
    [USER_DEFAULT synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_CREAT_CATEGORY_MEAN object:nil];
}

#pragma mark - servers
- (void)getMainDataWithDict:(NSDictionary *)dict success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    inputData = [NSDictionary dictionaryWithObject:dict forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:kCloudInit withParameters:inputData block:^(id object, NSError *err){
        if (!err) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                success(object);
            }else{
                fail(kDataErrorWarning);
            }
        }else{
            fail(kNetworkWarning);
            LOG(@"getmaindataerror%@",err);
        }
    }];
    
}

#pragma mark - gesture
/**
 *  第一次进主页的指示图切换
 *
 *  @param gesture
 */
//- (void)handleVideoImageAlert:(UIGestureRecognizer *)gesture {
//    [imageViewAlert removeFromSuperview];
//    stageViewAlert = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Alert_Stage"]];
//    stageViewAlert.contentMode = UIViewContentModeCenter;
//    stageViewAlert.center = CGPointMake(mainScreenWidth * 0.7 - 62, mainScreenHeight - 168);
//    stageViewAlert.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoStageAlert:)];
//    [stageViewAlert addGestureRecognizer:tap];
//    [alertTheAction addSubview:stageViewAlert];
//}

- (void)handleVideoStageAlert:(UIGestureRecognizer *)gesture {
    [alertTheAction removeFromSuperview];
}

- (void)touchPPTAndOpenTheWebSite:(UITapGestureRecognizer *)sender{
    LOG(@"%@",[[mainModel.pptList objectAtIndex:sender.self.view.tag] objectForKey:kDescriptionUrl]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        TOWebViewController *webView = [[TOWebViewController alloc ] initWithURL:[NSURL URLWithString:[[mainModel.pptList objectAtIndex:sender.self.view.tag] objectForKey:kDescriptionUrl]]];
        isSelectedVisitor = YES;
        
        webView.webViewStyle = ToWebViewShareWebView;
        webView.navigationButtonsHidden = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webView animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    });
}

- (void)showMessageCebter:(UITapGestureRecognizer *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        TOWebViewController *webView = [[TOWebViewController alloc ] initWithURL:[NSURL URLWithString:kKefuUrl]];
        isSelectedVisitor = YES;
        webView.webViewStyle = ToWebViewOnlyWeb;
        webView.navigationButtonsHidden = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webView animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    });
}



#pragma mark - 环信

-(void)loginEaseForRcid:(NSString *)rcid md5Passwodrd:(NSString *)md5Passwodrd
{
    
    __weak typeof(self) weakSelf = self;
    //        [[EaseMob sharedInstance].chatManager setApnsNickname:rcid];
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:rcid password:md5Passwodrd completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         //登录成功
         if (loginInfo && !error) {
             
             //             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             //             [userDefaults setObject:weakSelf.userModel.sessionid forKey:@"sessionid"];
             //             [userDefaults setObject:weakSelf.userModel.rc_id forKey:@"rcid"];
             //             [userDefaults setObject:weakSelf.userModel.userid forKey:@"userid"];
             //             [userDefaults setObject:weakSelf.userModel.nickname forKey:@"nickname"];
             //
             //             [userDefaults synchronize];
             
             LOG(@"成功!");
             //             DebugLog(@"---保存Session ＝ %@--",SESSIONID);
             
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
             [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
             
             //             [weakSelf toMain];
             
         }else {
             
             switch (error.errorCode) {
                     
                 case EMErrorServerNotReachable:
                     //                     TTAlertNoTitle(@"连接服务器失败!");
                     LOG(@"hx连接服务器失败!");
                     break;
                     
                 case EMErrorTooManyLoginRequest:
                 {
                     
                     //已经登录过了，再次重新登录
                     static int num1 = 0;
                     num1 ++;
                     if (num1 == 3) {
                         num1 = 0;
                         return;
                     }
                     
                     [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                         
                         [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
                         
                         
                     } onQueue:nil];
                     
                 }
                     break;
                 case EMErrorServerAuthenticationFailure:
                     //                     TTAlertNoTitle(error.description);
                     //                     [self.hud hide:YES];
                     LOG(@"hxerror.description");
                     break;
                 case EMErrorServerTimeout:
                     //                     TTAlertNoTitle(@"连接服务器超时!");
                     //                     [self hideHud];
                     //                     [self.hud hide:YES];
                     LOG(@"hx连接服务器超时!");
                     break;
                 default:
                     //                                          TTAlertNoTitle(@"登录失败");
                     //                                          [self hideHud];
                     //                                          [self.hud hide:YES];
                     LOG(@"hx登录失败");
                     
                     static int num = 0;
                     num ++;
                     if (num == 3) {
                         num = 0;
                         return;
                     }
                     [[EaseMob sharedInstance].chatManager registerNewAccount:[bUser objectForKey:kobjectId] password:@"QAZWSXEDC" error:&error];
                     
                     [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
                     break;
             }
         }
     } onQueue:nil];
    
}

@end
