//
//  NotificationViewController.m
//  duangongbang
//
//  Created by ljx on 15/10/15.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationViewCell.h"
#import "MyDetailView.h"
#import "TopViewCell.h"
#import "HeadViewCell.h"
#import "DetailViewCell.h"
#import "WorkViewCell.h"
#import "NeedKnownViewCell.h"
#import "CommentViewCell.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import "CommonServers.h"
#import "TopViewCell.h"
#import "HeadViewCell.h"
#import "DetailViewCell.h"
#import "WorkViewCell.h"
#import "NeedKnownViewCell.h"
#import "CommentViewCell.h"
#import "WorkModel.h"
#import "TimeCaculate.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"
#import <pop/POP.h>
#import "LabelPlacing.h"
#import "HLAlertController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import "AFPopupView.h"
#import "CommentViewController.h"
#import "UIView+Border.h"
#import "CompanyDetailViewController.h"
#import "TOWebViewController.h"
#import "ShareSDKClass.h"
#import "ConsultingViewController.h"
#import "DirectSupportAcceptedViewController.h"
/**
 *  我的申请首页
 */
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
#define kVersion @"Version"
#define kWorkOrderObjectId @"WorkOrderObjectId"
#define kDeviceType @"DeviceType"
#define kOpenDetailTimes @"detailTimesOpened"
static NSString * const notNeedPersonStr = @"该工作满人了";
static NSString * const isNotTrueWorkStr = @"该工作虚假的";
static NSString * const isInvalidWorkStr = @"该工作无效的";
static NSString * const iWantTalkSomeStr = @"我也要来发言";

@interface NotificationViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>
{
    BmobUser *bUser;
    NSDictionary *dic;
    NSMutableArray *dataArray;
    NSDictionary *dataDic;
    NSDictionary *dataDic2;
    CGSize labelsize;
    NSDictionary *dic2;
    WorkModel *workModel;
    CGSize contentLabelSize;
    CGSize attentionLabelSize;
    UIAlertView *alertInput;
    NSString *_userComment;
    UIView *alertTheAction;
    UIImageView *imageViewAlert;
}

@property (strong,nonatomic ) UIButton     *applySituation;
@property (strong,nonatomic ) UIButton     *parttimeSituation;
@property (strong,nonatomic ) UIView       *topView;
@property (strong,nonatomic ) UIScrollView *mainScrollView;
@property (strong,nonatomic ) UITableView *tableView;
@property (strong,nonatomic ) UIView      *toolBarView;
@property (strong,nonatomic ) UITableView *detailTableView;
@property (strong,nonatomic ) AFPopupView *popCommentView;
@property (strong, nonatomic) CommentViewController *commentVC;


@end

@implementation NotificationViewController
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
   
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  = RGB(235, 235, 235, 1.0);
    [SVProgressHUD showWithStatus:kRefreshingShowText];
    /**
     *  {"inputData":{"Type":"GetWorkStatic","UserObjectId":"61acc57699","WorkOrderObjectId":"cb46f9c3a0","Version":"321"}}
     */
    //    [SVProgressHUD showWithStatus:kRefreshingShowText maskType:SVProgressHUDMaskTypeClear];
    
    bUser = [ShareDataSource sharedDataSource].myData;
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           @"GetWorkStatic",kType,
           bUser ? bUser.objectId : @"",kUserObjectId,
           _workOrderObjectId,kWorkOrderObjectId,
           kCloudVersion,kVersion,
           @"ios",kDeviceType,
           nil];
    LOG(@"坑爹2 = %@",_workOrderObjectId);
    [self getWorkDetailWithDic:dic];
    /**
     *  {"inputData":{"Version":"321","Type":"GetWork","WorkObjectId":"4cd24dbe30","UserObjectId":"61acc57699","DeviceType":"android"}}
     */
    dic2 = [NSDictionary dictionaryWithObjectsAndKeys:
            kCloudVersion,kVersion,
            @"GetWork",kType,
            bUser ? bUser.objectId : @"",kUserObjectId,
            _workObjectId,@"WorkObjectId",
            @"ios",kDeviceType,
            nil];

    [self configScrollView];
    [self configTopView];
    [self configTableView];
    [self configToolBar];
    [self configDetailTableView];
    [self getWorkInfoWithDic:dic2 success:^(NSDictionary *object) {
        workModel = [WorkModel initWithDic:[object objectForKey:@"Work"]];

//        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Width, Height/2)];
//        [headImageView sd_setImageWithURL:[NSURL URLWithString:workModel.headImgUrl] placeholderImage:[UIImage imageNamed:@"Head_Image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            UIImage *img;
//            cacheType = SDImageCacheTypeMemory;
//            UIImage *blurImage = nil;
//            UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Width, Height/2)];
//            blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
//            imgBackground.image = blurImage;
//            [_mainScrollView insertSubview:imgBackground aboveSubview:_detailTableView];
//            LOG(@"模糊视图%@",workModel);
//        }];
        UIImage *blurImage = nil;
        UIImage *img;
        UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(Width, 0, Width, Height/2)];
        [imgBackground sd_setImageWithURL:[NSURL URLWithString:workModel.headImgUrl]];
        img = imgBackground.image;
        blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
        imgBackground.image = blurImage;
        [_mainScrollView insertSubview:imgBackground belowSubview:_detailTableView];
        
        [self.detailTableView reloadData];
    } fail:^(NSString *reason) {
        LOG(@"reason === %@",reason);
    }];
    _commentVC = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    _userComment = [[NSString alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTheCommentVC) name:KEY_KVO_HIDE_COMMENTVC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWorkDetail:) name:KEY_KVO_GET_WORK_DETAIL object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_HIDE_COMMENTVC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_GET_WORK_DETAIL object:nil];
}

/**
 *  配置tableView
 */
- (void)configTableView
{
    _tableView                    = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, Width, Height -64 - 44) style:UITableViewStylePlain];
    _tableView.delegate           = self;
    _tableView.dataSource         = self;
    _tableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor    = RGB(235, 235, 235, 1.0);
    UINib *nib = [UINib nibWithNibName:@"NotificationViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"notificationCellIdentifier"];
    [_mainScrollView addSubview:_tableView];
    
}

/**
 *  配置scrollView
 */
- (void)configDetailTableView
{
    //    if (!_detailTableView) {
        _detailTableView                                = [[UITableView alloc]initWithFrame:CGRectMake(Width, 0, Width, Height - 44) style:UITableViewStylePlain];
        _detailTableView.delegate                       = self;
        _detailTableView.dataSource                     = self;
        _detailTableView.showsHorizontalScrollIndicator = NO;
        _detailTableView.showsVerticalScrollIndicator   = NO;
        _detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _detailTableView.backgroundColor = [UIColor clearColor];
        UIImageView *backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Width, Height)];
        backgroundView.image = [UIImage imageNamed:@"渐变叠加"];
        _detailTableView.backgroundView = backgroundView;
    
    
        UINib *topNib = [UINib nibWithNibName:@"TopViewCell" bundle:nil];
        [_detailTableView registerNib:topNib forCellReuseIdentifier:@"topCellIdentifier"];
        
        UINib *headNib = [UINib nibWithNibName:@"HeadViewCell" bundle:nil];
        [_detailTableView registerNib:headNib forCellReuseIdentifier:@"headCellIdentifier"];
    
        UINib *detailNib = [UINib nibWithNibName:@"DetailViewCell" bundle:nil];
        [_detailTableView registerNib:detailNib forCellReuseIdentifier:@"detailCellIdentifier"];
        
        UINib *workNib = [UINib nibWithNibName:@"WorkViewCell" bundle:nil];
        [_detailTableView registerNib:workNib forCellReuseIdentifier:@"workCellIdentifier"];
        
        UINib *needNib = [UINib nibWithNibName:@"NeedKnownViewCell" bundle:nil];
        [_detailTableView registerNib:needNib forCellReuseIdentifier:@"needCellIdentifier"];
        
        UINib *commmentNib = [UINib nibWithNibName:@"CommentViewCell" bundle:nil];
        [_detailTableView registerNib:commmentNib forCellReuseIdentifier:@"commentCellIdentifier"];
    
        [_mainScrollView addSubview:_detailTableView];
    

//    }
//    return _detailTableView;
}

- (void)configScrollView
{
    _mainScrollView = [[UIScrollView alloc]init];
    _mainScrollView.frame                          = CGRectMake(0, 0, Width, Height);
    _mainScrollView.contentSize                    = CGSizeMake(Width*2, Height);
    _mainScrollView.bounces                        = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator   = NO;
    _mainScrollView.pagingEnabled                  = YES;
    _mainScrollView.delegate                       = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:_mainScrollView];
}

/**
 *  配置toolBar
 */
- (void)configToolBar
{
    _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, Height - 44, Width*2, 44)];
    _toolBarView.backgroundColor = RGB(48, 50, 63, 1.0);
    
    NSArray * array = [NSArray arrayWithObjects:@"detailBackIcon",@"评论",@"客服",@"分享",@"投诉", nil];
    for (int i = 0; i < 4; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*Width/4 + Width, 10, Width/4, 24);
        [btn setImage:[UIImage imageNamed:array[i]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(toolbarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 200 + i;
        [_toolBarView addSubview:btn];
    }

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame     = CGRectMake(0, 10, Width/4, 24);
    [backBtn setImage:[UIImage imageNamed:@"detailBackIcon"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(toolbarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.tag       = 204;
    [_toolBarView addSubview:backBtn];
    
    /**
     *  暂时隐藏
     */
//    UIButton *complainBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
//    complainBtn.frame           = CGRectMake(Width/4*3, 10, Width/4, 24);
//    [complainBtn setTitle:@"投诉" forState:UIControlStateNormal];
//    complainBtn.titleLabel.font = [UIFont fontWithName:kFontName size:12];
//    [complainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    complainBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [complainBtn addTarget:self action:@selector(toolbarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    complainBtn.tag             = 205;
//    [_toolBarView addSubview:complainBtn];
    [_mainScrollView addSubview:_toolBarView];
    
}

/**
 *  配置topView
 */
- (void)configTopView
{
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, 64)];
    _topView.backgroundColor = [UIColor colorWithRed:48/255.0 green:50/255.0 blue:62/255.0 alpha:1.0];
    
    _applySituation = [UIButton buttonWithType:UIButtonTypeCustom];
    _applySituation.frame = CGRectMake(0, 30, Width/2, 34);
    [_applySituation setTitleColor:RGB(150, 150, 150, 1.0) forState:UIControlStateNormal];
    [_applySituation setTitle:@"申请情况" forState:UIControlStateNormal];
    _applySituation.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -70);
    _applySituation.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    [_applySituation setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _applySituation.selected = YES;
    [_applySituation addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_applySituation];
    
    _parttimeSituation = [UIButton buttonWithType:UIButtonTypeCustom];
    _parttimeSituation.frame = CGRectMake(Width/2, 30, Width/2, 34);
    [_parttimeSituation setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_parttimeSituation setTitle:@"工作详情" forState:UIControlStateNormal];
    _parttimeSituation.titleEdgeInsets = UIEdgeInsetsMake(0, -70, 0, 0);
    _parttimeSituation.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    [_parttimeSituation setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_parttimeSituation addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_parttimeSituation];
    
    [_mainScrollView addSubview:_topView];
}

- (void)buttonAction:(UIButton *)button
{
    if (button == _applySituation) {
        _applySituation.selected = YES;
        _parttimeSituation.selected = NO;
        _mainScrollView.contentOffset = CGPointMake(0, 0);

    }
    else
    {
        _parttimeSituation.selected = YES;
        _applySituation.selected = NO;
        _mainScrollView.contentOffset = CGPointMake(Width, 0);
        [self.detailTableView reloadData];
    }
    
}

#pragma mark scrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    UIColor *color=RGB(48, 50, 63, 1.0);
//    CGFloat offset = scrollView.contentOffset.x;
//    if (offset<0) {
//        self.topView.backgroundColor            = [color colorWithAlphaComponent:1.0];
//        _applySituation.titleLabel.textColor    = [[UIColor whiteColor] colorWithAlphaComponent:1.0];
//        _parttimeSituation.titleLabel.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1.0];
//
//    }else {
//        CGFloat alpha =((Width-offset)/Width);
//        self.topView.backgroundColor            = [color colorWithAlphaComponent:alpha];
//        _applySituation.titleLabel.textColor    = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
//        _parttimeSituation.titleLabel.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:alpha];
//
//    }
//    
    if (_mainScrollView.contentOffset.x >= 0 && _mainScrollView.contentOffset.x < Width) {
        _applySituation.selected    = YES;
        _parttimeSituation.selected = NO;
        _applySituation.hidden = NO;
        _parttimeSituation.hidden = NO;
        _topView.hidden = NO;
    }
    else
    {
        
        _applySituation.selected    = NO;
        _parttimeSituation.selected = YES;
        _applySituation.hidden = YES;
        _parttimeSituation.hidden = YES;
        _topView.hidden = YES;
        
    }

}

#pragma mark UItableView代理数据方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
    {
        return 1;
    }
    else if (tableView == _detailTableView)
    {
        return 6;
    }
    else
        return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableView) {
        return 37;
    }
    else
    {
        return 0;
    }
   
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView == _tableView) {
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, 37)];
        titleView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, Width-32, 37)];
        titleLabel.font = [UIFont fontWithName:kFontName size:12];
        titleLabel.textColor = RGB(103, 103, 103, 1.0);
        titleLabel.text = [dataDic objectForKey:@"Title"];
        [titleView addSubview:titleLabel];
        return titleView;
    }
    else
    {
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (tableView == _detailTableView) {
        switch (indexPath.row) {
            case 0:
                return 92;
                break;
            case 1:
                return 113;

                break;
            case 2:
                return 323;
                break;
            case 3:
//                return [tableView fd_heightForCellWithIdentifier:@"workCellIdentifier" configuration:^(WorkViewCell *cell) {
//                    [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
//                }];
                return [tableView fd_heightForCellWithIdentifier:@"workCellIdentifier" cacheByIndexPath:indexPath configuration:^(id cell) {
                    [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
                }];

                break;
            case 4:
//                return [tableView fd_heightForCellWithIdentifier:@"needCellIdentifier" configuration:^(NeedKnownViewCell *cell) {
//                    [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
//                }];
                return [tableView fd_heightForCellWithIdentifier:@"needCellIdentifier" cacheByIndexPath:indexPath configuration:^(id cell) {
                    [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
                }];
                break;
            case 5:
                return 132;
                break;
            default:
                break;
        }
    }
    else if(tableView == _tableView)
    {
//        return [tableView fd_heightForCellWithIdentifier:@"notificationCellIdentifier" configuration:^(NotificationViewCell *cell) {
//            [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
//        }];
        return [tableView fd_heightForCellWithIdentifier:@"notificationCellIdentifier" cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
        }];
    }
    return 44;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _tableView) {
        NotificationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCellIdentifier"];
        [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
        return cell;
    }
    else if (tableView == _detailTableView)
    {

                switch (indexPath.row) {
            case 0:
            {
                
                TopViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topCellIdentifier"];
                [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
                
                return cell;
            }
                break;
            case 1:
            {
                HeadViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headCellIdentifier"];
                
//                if (cell == nil) {
//                    cell = [[[NSBundle mainBundle]loadNibNamed:@"HeadViewCell" owner:self options:nil]firstObject];
                    [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
//                }
                return cell;
            }
                break;
            case 2:
            {
                DetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCellIdentifier"];
                [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];

                return cell;
            }
                break;
            case 3:
            {
                WorkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workCellIdentifier"];
                [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];

                return cell;
            }
                break;
            case 4:
            {
                NeedKnownViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"needCellIdentifier"];
                [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
                                return cell;
            }
                break;
            case 5:
            {
                CommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCellIdentifier"];
                [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
                return cell;
            }
                break;
            default:
                break;
        }

    }
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    return cell;
}

- (void)configureCell:(id)Cell AndTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _tableView) {
        NotificationViewCell *cell = (NotificationViewCell *)Cell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = RGB(235, 235, 235, 1.0);
        cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
        cell.contentLabel.text = dataDic[@"Ticp3"];
        cell.ticp2Label.text = dataDic[@"Ticp2"];
        cell.dateLabel.text = dataDic[@"OrderObjectUpdateTime"];
        cell.resultLabel.text = dataDic[@"Ticp1"];
        [cell.contact addTarget:self action:@selector(ContactMethod) forControlEvents:UIControlEventTouchUpInside];
        if ([dataDic[@"WorkOrderStatic"] isEqualToString:@"TYPE_DIRECT"]) {
            [cell.bgView setImage:[UIImage imageNamed:@"bg_colorful_success.jpg"]];
        }
        else if ([dataDic[@"WorkOrderStatic"] isEqualToString:@"TYPE_APPLYING"])
        {
            [cell.bgView setImage:[UIImage imageNamed:@"bg_colorful_applying.jpg"]];
        }
        else if ([dataDic[@"WorkOrderStatic"] isEqualToString:@"TYPE_CHECKED"])
        {
            [cell.bgView setImage:[UIImage imageNamed:@"bg_colorful_belook.jpg"]];
        }
        else if ([dataDic[@"WorkOrderStatic"] isEqualToString:@"TYPE_SUCCESS"])
        {
            [cell.bgView setImage:[UIImage imageNamed:@"bg_colorful_success.jpg"]];
        }
        else
        {
            [cell.bgView setImage:[UIImage imageNamed:@"bg_colorful_reject.jpg"]];
        }

    }else if (tableView == _detailTableView){
                switch (indexPath.row) {
            case 0:
            {
                TopViewCell *cell = (TopViewCell *)Cell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.lbLikeNum.text = [NSString stringWithFormat:@"%@",workModel.viewedTimes];
                NSString *date = [TimeCaculate getUTCFormateDate:[workModel.createdAt substringToIndex:16]];
                cell.lbTime.text = [NSString stringWithFormat:@"发表于%@",date];
                cell.lbTitle.text = workModel.title;
            }
                break;
            case 1:
            {
                HeadViewCell *cell = (HeadViewCell *)Cell;
                cell.bgView.layer.cornerRadius = 4;
                [cell.bgView.layer setMasksToBounds:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if ([workModel.vip isEqualToString:@"1"]) {
                    cell.imgVer.image = [UIImage imageNamed:@"黄色V"];
                }else{
                    cell.imgVer.image = nil;
                }
                cell.headImageView.layer.cornerRadius = 28.0;
                cell.headImageView.layer.borderColor = UIColorFromRGB(0xf5f5f5).CGColor;
                cell.headImageView.layer.borderWidth = 2.0;
                [cell.headImageView.layer setMasksToBounds:YES];
                [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:workModel.headImgUrl] placeholderImage:[UIImage imageNamed:@"Head_Image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    UIImage *img;
                    cacheType = SDImageCacheTypeDisk;
                    if (image) {
                        img = image;
                    }else{
                        img = cell.imgVer.image;
                    }
//                    UIImage *blurImage = nil;
//                    UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(Width, 0, Width, Height/2)];
//                    blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
//                    imgBackground.image = blurImage;
//                    [_mainScrollView addSubview:imgBackground];
//                    [_mainScrollView bringSubviewToFront:_detailTableView];
                }];
                [cell.btnCompanyDetail addTarget:self action:@selector(companyDetailHandle) forControlEvents:UIControlEventTouchUpInside];
                cell.lbCompanyUserName.text = workModel.companyUserName;
                cell.lbClickNotic.text = workModel.textPersonNumStr;
                NSNumber *need = workModel.needNum;
                NSNumber *pass = workModel.passNum;
                cell.lbClickPersonNum.text = [NSString stringWithFormat:@"%d/%d",[pass intValue],[need intValue]];
                cell.progressView.progress = [pass floatValue] / [need floatValue];

//                POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop) {
//                    prop.writeBlock = ^(id obj ,const CGFloat value[]){
//                        cell.progressView.progress = (float)value[0] / [need floatValue];
//                    };
//                }];
//                POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];//线性的时间函数
//                anBasic.property = prop;//自定义属性
//                anBasic.fromValue = @(0);//从0开始
//                anBasic.toValue = @([pass floatValue]);
//                anBasic.duration = kProgressTime;//持续时间
//                [cell.progressView pop_addAnimation:anBasic forKey:@"progress"];
            }
                break;
            case 2:
            {
                DetailViewCell *cell = (DetailViewCell *)Cell;
                cell.bgView.layer.cornerRadius = 4;
                [cell.bgView.layer setMasksToBounds:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.lbClassifyName.text = workModel.classifyName;
                cell.lbPriceUnit.text = workModel.priceAndUnit;
                cell.lbSex.text = workModel.sex;
                cell.lbPayMethod.text = workModel.payMethod;
                cell.lbWorkDate.text = workModel.workDateStr;
                cell.lbStreetName.text = workModel.streetName;
            }
                break;
            case 3:
            {
                WorkViewCell *cell = (WorkViewCell *)Cell;
                cell.bgView.layer.cornerRadius = 4;
                [cell.bgView.layer setMasksToBounds:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if (workModel) {
                    NSDictionary *dict =  [NSJSONSerialization JSONObjectWithData:[workModel.content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                    NSMutableString *muStr = [[NSMutableString alloc]init];
                    if ([dict objectForKey:@"contentArray"]) {
                        NSArray *contentArray = [NSArray arrayWithArray:[dict objectForKey:@"contentArray"]];
                        for (NSDictionary *dicData in contentArray) {
                            NSString *title = [dicData objectForKey:@"Title"];
                            [muStr appendString:[NSString stringWithFormat:@"%@\n",title]];
                            NSString *content = [dicData objectForKey:@"Content"];
                            [muStr appendString:[NSString stringWithFormat:@"%@\n",content]];
                        }
//                        if ([dict objectForKey:@"message"]) {
//                            NSString *message = [dict objectForKey:@"message"];
//                            [muStr appendString:[NSString stringWithFormat:@"%@\n",message]];
//                        }
//                        if ([dict objectForKey:@"phone"]) {
//                            NSString *phone = [dict objectForKey:@"phone"];
//                            [muStr appendString:[NSString stringWithFormat:@"联系电话：%@\n",phone]];
//                        }
                        
                        cell.lbContent.text = muStr;
                        
                    }else {
                        cell.lbContent.text = workModel.content;
                    }

                }
                
            }
                break;
            case 4:
            {
                NeedKnownViewCell *cell = (NeedKnownViewCell *)Cell;
                cell.bgView.layer.cornerRadius = 4;
                [cell.bgView.layer setMasksToBounds:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.lbApplyKnown.text = workModel.applyKnowNormal;
//                [LabelPlacing thtLabelPlacingWith:cell.lbApplyKnown];
                cell.lbApplyKnown.textAlignment = NSTextAlignmentLeft;
                cell.lbApplyKnowWarning.text = workModel.applyKnowRed;
//                cell.lbApplyKnowWarning.font = [UIFont systemFontOfSize:12];
//                [LabelPlacing thtLabelPlacingWith:cell.lbApplyKnowWarning];
            }
                break;
            case 5:
            {
                CommentViewCell *cell = (CommentViewCell *)Cell;
                cell.bgView.layer.cornerRadius = 4;
                [cell.bgView.layer setMasksToBounds:YES];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.btnCommentShow.layer.cornerRadius = 3.0;
                
                [cell.btnCommentShow addBorderWithColor:UIColorFromRGB(0xcccccc) andWidth:0.5];
                [cell.btnCommentShow addTarget:self action:@selector(showTheCommentVC) forControlEvents:UIControlEventTouchUpInside];
                if (workModel.commentList.count == 0) {
                    cell.btnCommentShow.hidden = YES;
                }else {
                    cell.btnCommentShow.hidden = NO;
                }
            }
                break;
            default:
                break;
        }
    }
}



- (void)companyDetailHandle
{
    if (workModel) {
        CompanyDetailViewController *companyVC = [[CompanyDetailViewController alloc] initWithNibName:@"CompanyDetailViewController" bundle:nil];
        companyVC.userObjectId = workModel.companyUserId;

        self.hidesBottomBarWhenPushed = YES;
        //        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:companyVC];
        [self.navigationController pushViewController:companyVC animated:YES];
        //        [self presentViewController:nav animated:YES completion:nil];
    }

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        if (buttonIndex == 1) {
            UITextField *text = [alertView textFieldAtIndex:0];
            _userComment = text.text;
            if ([_userComment isEqualToString:@""]) {
                return;
            }
            [self commentWithContent:_userComment type:@"Comment"];
        }
    
}

#pragma mark toolBar点击事件
- (void)toolbarButtonAction:(UIButton *)button
{
    NSInteger i = button.tag;
    switch (i) {
        case 200:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 204:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 201:
        {
//            HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"投诉选项" message:nil preferredStyle:HLAlertControllerStyleActionSheet];
//            
//            [alert addAction:[HLAlertAction actionWithTitle:notNeedPersonStr style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
//                [self commentWithContent:@"人满" type:@"WorkComplain"];
//            }]];
//            [alert addAction:[HLAlertAction actionWithTitle:isNotTrueWorkStr style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
//                [self commentWithContent:@"虚假" type:@"WorkComplain"];
//            }]];
//            [alert addAction:[HLAlertAction actionWithTitle:isInvalidWorkStr style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
//                [self commentWithContent:@"无效" type:@"WorkComplain"];
//            }]];
//            [alert addAction:[HLAlertAction actionWithTitle:iWantTalkSomeStr style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
            alertInput = [[UIAlertView alloc]initWithTitle:@"请输入内容" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"评论", nil];
            alertInput.delegate = self;
                [alertInput setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alertInput textFieldAtIndex:0].placeholder = @"评论: ";
                [alertInput show];
//            }]];
            
//            [alert showWithViewController:self];
        }
            break;
        case 202:
        {
//            TOWebViewController *webVC = [[TOWebViewController alloc ] initWithURL:[NSURL URLWithString:kKefuUrl]];
//            webVC.webViewStyle = ToWebViewOnlyWeb;
//            [webVC.webView.scrollView setContentSize:CGSizeMake(0, webVC.webView.scrollView.contentSize.height)];
//            webVC.navigationButtonsHidden = YES;
//            self.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:webVC animated:YES];
            ConsultingViewController *consultingVC = [[ConsultingViewController alloc]init];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:consultingVC animated:YES];
        }
            break;
        case 203:
        {
            [ShareSDKClass shareWithImage:[UIImage imageNamed:@"DGBIcon"] contentText:[NSString stringWithFormat:@"刚刚在短工邦看到一条工作信息“%@”，薪资%@，在%@工作，有兴趣的可以下载短工邦报名哦！%@%@", workModel.title, workModel.priceAndUnit, workModel.streetName, kWorkUrlPrefix, workModel.workObjectId] title:workModel.title type:SSDKContentTypeAuto view:nil url:[NSString stringWithFormat:@"%@%@",kWorkUrlPrefix,workModel.workObjectId]];
        }
            break;
        case 205:
        {
            LOG(@"投诉");
        }
            break;
        
        default:
            break;
    }
}

- (void)ContactMethod
{
    /**
     *  
     "Static":"success",
     "Value":"获取工作状态成功",
     "Title":"【天猫商城】诚招双11客服兼职",
     "ApplyWay":"Way1",
     "OrderObjectUpdateTime":"2015-10-20 17:33:41",
     "Ticp1":"请直接联系商家",
     "WorkOrderStatic":"TYPE_DIRECT",
     "Ticp2":"系统通知",
     "CompanyUserPhone":"",
     "Message":"您好，我的姓名是/%name/，刚在短工邦看到一条兼职信息/%title/，想问下还有位置吗？我想报名。",
     "Ticp3":"该工作是电话报名或者发短信报名，请直接联系商家~"
     */
                    
        HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"您可以采用以下方式联系报名" message:nil preferredStyle:HLAlertControllerStyleAlert];
        
        if ([workModel.applyWay isEqualToString:@"Way1"] || [workModel.applyWay isEqualToString:@""] || workModel.applyWay == nil) {
            [alert addAction:[HLAlertAction actionWithTitle:@"打电话" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                [self callThePhone:workModel.companyUserPhone];
            }]];
            [alert addAction:[HLAlertAction actionWithTitle:@"发短信" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                
                [self sendSMS:workModel.message recipientList:[NSArray arrayWithObjects:workModel.companyUserPhone, nil]];
            }]];
            [alert showWithViewController:self];

            
        }else if ([workModel.applyWay isEqualToString:@"Way2"]) {
            [alert addAction:[HLAlertAction actionWithTitle:@"打电话" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                [self callThePhone:workModel.companyUserPhone];
            }]];
            [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
                
            }]];
            [alert showWithViewController:self];
            
        }else if ([workModel.applyWay isEqualToString:@"Way3"]) {
            [alert addAction:[HLAlertAction actionWithTitle:@"发短信" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                [self sendSMS:workModel.message recipientList:[NSArray arrayWithObjects:workModel.companyUserPhone, nil]];
            }]];
            [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
                
            }]];
            [alert showWithViewController:self];
            
        }else if ([workModel.applyWay isEqualToString:@"Way4"]) {
            [SVProgressHUD showErrorWithStatus:workModel.message];
            
        }else if ([workModel.applyWay isEqualToString:@"Way5"]) {
            [alert addAction:[HLAlertAction actionWithTitle:@"打电话" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                [self callThePhone:workModel.companyUserPhone];
            }]];
            [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
            }]];
            [alert showWithViewController:self];

        }else if ([workModel.applyWay isEqualToString:@"Way7"]){
            DirectSupportAcceptedViewController *directVC = [[DirectSupportAcceptedViewController alloc]init];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:directVC animated:NO];
            
        }else {
            [SVProgressHUD showErrorWithStatus:@"请留意最新版本功能"];
        }

}

- (void)callThePhone:(NSString *)phone {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *callWebview = [[UIWebView alloc] init];
        NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [self.view addSubview:callWebview];
    });
}

- (void)applyTheWorkAndCallTheCloudWithType:(NSString *)type success:(void (^)(id object))block {
    /**
     *  {"Type":"WorkCall","Version":"3","UserObjectId":"3c018af4d1","WorkObjectId":"ea325573f2"}
     */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:type, @"Type", kCloudVersion, @"Version", bUser.objectId, @"UserObjectId", workModel.workObjectId, @"WorkObjectId", nil];
    [CommonServers callCloudWithAPIName:kCloudInteractive andDic:dict success:^(id object) {
        block(object);
    } fail:^(NSString *reason) {
        
    }];
}

#pragma mark - 调用短信
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]) {
            controller.body = bodyOfMessage;
            controller.recipients = recipients;
            //            UINavigationBar *navibar = [UINavigationBar appearanceWhenContainedIn:[DGDetailViewController  class], nil];
            //            navibar.barTintColor = UIColorFromRGB(xMainBlueColor);
            //            [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
            //            [navibar setTintColor:[UIColor whiteColor]];
            //
            //            [navibar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    });
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            [SVProgressHUD showErrorWithStatus:@"取消发送"];
            break;
        case MessageComposeResultSent:{
            [SVProgressHUD showSuccessWithStatus:@"成功发送"];
            [self applyTheWorkAndCallTheCloudWithType:@"WorkMessage" success:^(id object) {
                if (object) {
                    [self getWorkDetail:nil];
                }
            }];
        }
            break;
        case MessageComposeResultFailed:
            [SVProgressHUD showErrorWithStatus:@"取消发送"];
            break;
        default:
            break;
    }
}


#pragma mark 获取数据
- (void)getWorkDetail:(NSDictionary *)sender {
    @try {
        NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(detailStopRefreshing) userInfo:nil repeats:NO];
        
        [self getWorkInfoWithDic:dic2 success:^(NSDictionary *object) {
            [timer invalidate];
            [SVProgressHUD showSuccessWithStatus:kRefreshedFinish];
            workModel = [WorkModel initWithDic:[object objectForKey:@"Work"]];
            
            [self performSelectorOnMainThread:@selector(showInfoToView) withObject:workModel waitUntilDone:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commentSuccess" object:workModel.commentList];
        }fail:^(NSString *err){
            [SVProgressHUD showErrorWithStatus:err];
            [timer invalidate];
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)detailStopRefreshing{
    [SVProgressHUD showErrorWithStatus:kNetworkWarning];
}

- (void)showInfoToView
{
    [_detailTableView reloadData];
}

- (void)getWorkDetailWithDic:(id)sender
{
    /**
     {
     "CompanyUserPhone": "",
     "Message": "您好，我的姓名是/%name/，刚在短工邦看到一条兼职信息/%title/，想问下还有位置吗？我想报名。",
     "OrderObjectUpdateTime": "2015-10-2017: 33: 41",
     "Static": "success",
     "Ticp1": "请直接联系商家",
     "Ticp2": "系统通知",
     "Ticp3": "该工作是电话报名或者发短信报名，请直接联系商家~",
     "Title": "【天猫商城】诚招双11客服兼职",
     "Value": "获取工作状态成功",
     "WorkOrderStatic": "TYPE_DIRECT"
     }
     */
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(detailStopRefreshing) userInfo:nil repeats:NO];
    [CommonServers callCloudWithAPIName:kCloudUser andDic:dic success:^(id object) {
        [timer invalidate];
        [SVProgressHUD showSuccessWithStatus:kRefreshedFinish];
        dataDic = [[NSDictionary alloc]initWithDictionary:object];
        
//        labelsize = [self calculateLabelHeight:[dataDic objectForKey:@"Ticp3"] withFont:16];

        [_tableView reloadData];
        
    } fail:^(NSString *reason) {
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
    }];     
}

/**
 *  计算文本在label的高度
 *
 *  @param string 传入的数据
 *  @param font   字体大小
 *
 *  @return 返回文本在label里的高度
 */
//- (CGSize)calculateLabelHeight:(NSString *)string withFont:(NSInteger)font
//{
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Width - 66, 100)];
//    label.font = [UIFont fontWithName:kFontName size:font];
//    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.text = string;
//    CGSize titleSize = [string boundingRectWithSize:CGSizeMake(Width - 66, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
//    return titleSize;
//}

/**
 *  评论
 *
 *  @param str  str description
 *  @param type type description
 */
- (void)commentWithContent:(NSString *)str type:(NSString *)type{
    /**
     *  {"Type":"Comment","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55","Content":"感觉还行，继续加油"}
     */
    bUser = [BmobUser getCurrentUser];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          bUser.objectId, @"UserObjectId",
                          type, @"Type",
                          kCloudVersion, @"Version",
                          workModel.workObjectId, @"WorkObjectId",
                          str, @"Content",
                          nil];
    [SVProgressHUD show];
    [CommonServers callCloudWithAPIName:kCloudInteractive andDic:dict success:^(id object) {
        if (object) {
            if ([[object objectForKey:@"Static"] isEqualToString:@"success"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GET_WORK_DETAIL object:nil];
                [SVProgressHUD showSuccessWithStatus:@"评论成功"];
            }else {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[object objectForKey:@"Value"]]];
            }
        }
    } fail:^(NSString *reason) {
        [SVProgressHUD showErrorWithStatus:reason];
    }];
}

/**
 *  显示评论
 */
- (void)showTheCommentVC {
    _popCommentView = [AFPopupView popupWithView:_commentVC.view];
    _commentVC.commentList = workModel.commentList;
    _commentVC.workObjectId = workModel.workObjectId;
    [_popCommentView show];
    
}
/**
 *  隐藏评论
 */
- (void)hideTheCommentVC {
    [_popCommentView hide];
}

#pragma mark - gesture
- (void)handlePraiseAlert:(UIGestureRecognizer *)gesture {
    [alertTheAction removeFromSuperview];
}

#pragma mark - Servers
/**
 *  云代码调用
 *
 *  @param inputDic 传入inputData
 *  @param success  返回成功字典
 *  @param fail     返回是字符串
 */
- (void)getWorkInfoWithDic:(NSDictionary *)inputDic success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
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
