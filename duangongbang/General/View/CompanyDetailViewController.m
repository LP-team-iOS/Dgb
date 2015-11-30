//
//  CompanyDetailViewController.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/8.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "CompanyDetailViewController.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "UIImage+ImageEffects.h"
#import <BmobSDK/BmobUser.h>
#import "CommonServers.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "DGDetailViewController.h"

#define HEADER_DETAIL_HEIGHT 374
#define X_TITLE_COLOR 0xb2e4fb
#define X_CONTENT_COLOR 0x999999

@interface CompanyDetailViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate>{
    UIImageView *_imgBack;
    UIImageView *_imgHead;
    UILabel *_lbCompanyName;
    UILabel *_lbType;
    UILabel *_lbAddress;
    UILabel *_lbUserName;
    UILabel *_lbContent;
    
    BmobUser *bUser;
    
    NSMutableDictionary *_callCloudDic;
    
    NSArray *_listData;
    
    __weak IBOutlet UITableView *_tableView;
    
    
}

@property (nonatomic, weak) UIView *navBackView;

@end

@implementation CompanyDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlackColor);
    
    //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *homeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backHomeItem"] style:UIBarButtonItemStylePlain target:self action:@selector(popToHome)];
    homeItem.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:homeItem];
    
    CGFloat alaph = (_tableView.contentOffset.y - 64) / 64;
    alaph = alaph < 0 ? 0 : alaph;
    _navBackView.backgroundColor = UIColorFromRGBAlpha(xMainBlackColor, alaph);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage: forBarPosition: barMetrics:)]){
        UIImage *backgroundImage = [UIImage imageNamed:@"alipay"];
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsCompactPrompt];
    } else if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        UIImage *backgroundImage = [UIImage imageNamed:@"alipay"];
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsCompactPrompt];
    }
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTintColor:[UIColor clearColor]];
    
    [self getBackView:self.navigationController.navigationBar];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:kFontName size:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"商家介绍";
    self.navigationItem.titleView = label;
    self.navigationController.delegate = self;
    _tableView.tableHeaderView = [self headerViewWithRect:CGRectMake(0, 0, mainScreenWidth, HEADER_DETAIL_HEIGHT)];
    
    [_tableView registerNib:[UINib nibWithNibName:@"JobTableViewCell" bundle:nil] forCellReuseIdentifier:@"jobCell"];
    
    /**
     *  {"Type":"GetAboutCompany","Version":"3","UserObjectId":"fd338c0164"}
     */
    [SVProgressHUD showWithStatus:kRefreshingShowText];
    _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:kCloudVersion, @"Version", @"GetAboutCompany", @"Type", _userObjectId, @"UserObjectId", nil];
    @try {
        [CommonServers callAccountWithDict:_callCloudDic success:^(NSDictionary *object) {
            if (object) {
                if ([[object objectForKey:@"Static"] isEqualToString:@"success"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:kRefreshedFinish];
                        
                        _listData = [NSArray arrayWithArray:[object objectForKey:@"WorkList"]];
                        
                        [_imgHead sd_setImageWithURL:[NSURL URLWithString:[object objectForKey:@"HeadImgURL"]] placeholderImage:[UIImage imageNamed:@"Head_Image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            _imgBack.image = [_imgHead.image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];
                        }];
                        _lbCompanyName.text = [object objectForKey:@"Name"];
                        _lbType.text = [object objectForKey:@"VIPName"];
                        _lbAddress.text = [object objectForKey:@"Address"];
                        _lbUserName.text = [[object objectForKey:@"Nickname"] isEqualToString:@""] ? @"用户太懒没有填写" : [object objectForKey:@"Nickname"];
                        _lbContent.text = [object objectForKey:@"Intro"];
                        [_tableView reloadData];
                    });
                }
            }
        } fail:^(NSString *reason) {
            [SVProgressHUD showErrorWithStatus:reason];
        }];
    }
    @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
        LOG(@"%@",exception);
    }
    @finally {
        
    }
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = RGB(48, 50, 63, 1.0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    if (viewController == self) {
//        self.navigationController.navigationBar.alpha = 0.300;
//    }else{
//        self.navigationController.navigationBar.alpha =1;
//    }
}

#pragma mark - UITableViewDataSources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - UITableViewDelegete
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
    [dgVC setWorkObjectId:[[_listData objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:dgVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat alaph = (scrollView.contentOffset.y - 64) / 64;
    alaph = alaph < 0 ? 0 : alaph;
    _navBackView.backgroundColor = UIColorFromRGBAlpha(xMainBlueColor, alaph);
}

#pragma mark - methods
-(void)getBackView:(UIView*)superView
{
    if ([superView isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
        _navBackView = superView;
        //在这里可设置背景色
//        _navBackView.backgroundColor = UIColorFromRGB(xMainBlueColor);
    }else if ([superView isKindOfClass:NSClassFromString(@"_UIBackdropView")]) {
        
        //_UIBackdropEffectView是_UIBackdropView的子视图，这是只需隐藏父视图即可
        [superView removeFromSuperview];
    }
    
    for (UIView *view in superView.subviews) {
        [self getBackView:view];
    }
}

- (void)backPop {

    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popToHome {
    self.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (UIView *)headerViewWithRect:(CGRect)rect {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = UIColorFromRGB(xTableViewGrayColor);
    //添加背景图片
    _imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height - 40)];
    _imgBack.image = [[UIImage imageNamed:@"Head_Image.png"] applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];
    
    [_imgBack setContentMode:UIViewContentModeScaleAspectFill];
    _imgBack.clipsToBounds = YES;
    [view addSubview:_imgBack];
    [view sendSubviewToBack:_imgBack];
    
    UIView *bottomView = [[UIView alloc] init];
    
    [view addSubview:bottomView];
    [view bringSubviewToFront:bottomView];
    
    //最近工作小标题
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor whiteColor];
    [view addSubview:titleView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view.mas_bottom).with.offset(0);
        make.left.equalTo(view.left).with.offset(0);
        make.right.equalTo(view.right).with.offset(0);
        make.height.equalTo(32.0);
    }];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = UIColorFromRGBAlpha(xAlertColor, 0.3);
    [titleView addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView.top).with.offset(16);
        make.left.equalTo(titleView.left).with.offset(16);
        make.size.equalTo(CGSizeMake(mainScreenWidth - 32, 0.5));
    }];
    
    UILabel *recentlyWork = [[UILabel alloc] init];
    recentlyWork.text = @"最近工作";
    recentlyWork.font = [UIFont fontWithName:kFontName size:14];
    recentlyWork.textAlignment = NSTextAlignmentCenter;
    recentlyWork.textColor = UIColorFromRGB(xAlertColor);
    recentlyWork.backgroundColor = [UIColor whiteColor];
    [titleView addSubview:recentlyWork];
    [recentlyWork mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(titleView.centerX);
        make.top.equalTo(titleView.top).with.offset(8);
        make.size.equalTo(CGSizeMake(80, 20));
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(titleView.mas_top).with.offset(-8.0);
        make.left.equalTo(view.left).with.offset(0);
        make.right.equalTo(view.right).with.offset(0);
        make.height.equalTo(102);
    }];
    
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.layer.masksToBounds = NO;
//    bottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, mainScreenWidth, 102)].CGPath;
    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomView.layer.shadowRadius = 3.0;
    bottomView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    bottomView.layer.shadowOpacity = 0.1f;
    
    CGFloat mainEdge = 16;
    CGFloat contentLBHeight = 20.0;
    CGFloat infoFontSize = 15;
    CGFloat titleFontSize = 9;
    _imgHead = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Head_Image.png"]];
    _imgHead.contentMode = UIViewContentModeScaleAspectFill;
    _imgHead.clipsToBounds = YES;
    _imgHead.layer.cornerRadius = 28.0;
    _imgHead.layer.masksToBounds = YES;
    [view addSubview:_imgHead];
    [_imgHead mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(64.0);
        make.left.equalTo(mainEdge);
        make.size.equalTo(CGSizeMake(56.0, 56.0));
    }];
    
    UILabel *_lbComanyTitle = [[UILabel alloc] init];
    _lbComanyTitle.text = @"发布方";
    _lbComanyTitle.font = [UIFont fontWithName:kFontName size:titleFontSize];
    _lbComanyTitle.textColor = UIColorFromRGB(X_TITLE_COLOR);
    [view addSubview:_lbComanyTitle];
    [_lbComanyTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_imgHead.mas_top);
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.height.equalTo(mainEdge);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    _lbCompanyName = [[UILabel alloc] init];
    _lbCompanyName.text = @"";
    _lbCompanyName.textColor = [UIColor whiteColor];
    _lbCompanyName.font = [UIFont fontWithName:kFontName size:infoFontSize];
    [view addSubview:_lbCompanyName];
    [_lbCompanyName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.top.equalTo(_lbComanyTitle.mas_bottom).with.offset(0);
        make.height.equalTo(contentLBHeight);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    UILabel *_lbTypeTitle = [[UILabel alloc] init];
    _lbTypeTitle.text = @"认证类型";
    _lbTypeTitle.font = [UIFont fontWithName:kFontName size:titleFontSize];
    _lbTypeTitle.textColor = UIColorFromRGB(X_TITLE_COLOR);
    [view addSubview:_lbTypeTitle];
    [_lbTypeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbCompanyName.mas_bottom);
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.height.equalTo(mainEdge);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    _lbType = [[UILabel alloc] init];
    _lbType.text = @"";
    _lbType.textColor = [UIColor whiteColor];
    _lbType.font = [UIFont fontWithName:kFontName size:infoFontSize];
    [view addSubview:_lbType];
    [_lbType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.top.equalTo(_lbTypeTitle.mas_bottom).with.offset(0);
        make.height.equalTo(contentLBHeight);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    UILabel *_lbAddressTitle = [[UILabel alloc] init];
    _lbAddressTitle.text = @"联系地址";
    _lbAddressTitle.font = [UIFont fontWithName:kFontName size:titleFontSize];
    _lbAddressTitle.textColor = UIColorFromRGB(X_TITLE_COLOR);
    [view addSubview:_lbAddressTitle];
    [_lbAddressTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbType.mas_bottom);
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.height.equalTo(mainEdge);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    _lbAddress = [[UILabel alloc] init];
    _lbAddress.text = @"";
    _lbAddress.textColor = [UIColor whiteColor];
    _lbAddress.font = [UIFont fontWithName:kFontName size:infoFontSize];
    [view addSubview:_lbAddress];
    [_lbAddress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.top.equalTo(_lbAddressTitle.mas_bottom).with.offset(0);
        make.height.equalTo(contentLBHeight);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    UILabel *_lbUserTitle = [[UILabel alloc] init];
    _lbUserTitle.text = @"联系人";
    _lbUserTitle.font = [UIFont fontWithName:kFontName size:titleFontSize];
    _lbUserTitle.textColor = UIColorFromRGB(X_TITLE_COLOR);
    [view addSubview:_lbUserTitle];
    [_lbUserTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_lbAddress.mas_bottom);
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.height.equalTo(mainEdge);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    _lbUserName = [[UILabel alloc] init];
    _lbUserName.text = @"";
    _lbUserName.textColor = [UIColor whiteColor];
    _lbUserName.font = [UIFont fontWithName:kFontName size:infoFontSize];
    [view addSubview:_lbUserName];
    [_lbUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_imgHead.mas_right).with.offset(mainEdge);
        make.top.equalTo(_lbUserTitle.mas_bottom).with.offset(0);
        make.height.equalTo(contentLBHeight);
        make.width.greaterThanOrEqualTo(10);
    }];
    
    _lbContent = [[UILabel alloc] init];
    _lbContent.text = @"";
    _lbContent.textColor = UIColorFromRGB(X_CONTENT_COLOR);
    _lbContent.numberOfLines = 0;
    _lbContent.font = [UIFont fontWithName:kFontName size:14.0];
    [_lbContent setAutoresizingMask:UIMinimumKeepAliveTimeout];
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:_lbContent.text];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:4];
    [paragraphStyle1 setFirstLineHeadIndent:24.0];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, _lbContent.text.length)];
    [_lbContent setAttributedText:attributedString1];
    [_lbContent setMinimumScaleFactor:8.0];
    [bottomView addSubview:_lbContent];
    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView.mas_top).with.offset(mainEdge);
        make.left.equalTo(bottomView.mas_left).with.offset(mainEdge);
        make.right.equalTo(bottomView.mas_right).with.offset(-mainEdge);
        make.height.lessThanOrEqualTo(70);
    }];
    
    
    return view;
}

@end
