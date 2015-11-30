//
//  DirectAcceptedDetailViewController.m
//  duangongbang
//
//  Created by Macist on 15/11/5.
//  Copyright © 2015年 duangongbang. All rights reserved.
//
#import "DirectAcceptedDetailViewController.h"
#import "NotificationBoardCell.h"
#import "MyDetailView.h"
#import "TopViewCell.h"
#import "HeadViewCell.h"
#import "DetailViewCell.h"
#import "WorkViewCell.h"
#import "NeedKnownViewCell.h"
#import "CommentViewCell.h"
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
#import "SVProgressHUD.h"
#import "ChatViewController.h"
#import <BmobSDK/Bmob.h>
#import "ConsultingViewController.h"
#import "UIViewController+KeyboardAnimation.h"


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

#define kThinToolBarHeight 32.5
#define kCommentAlertViewTag 0
#define kLoginAndEnterAlertViewTag 1
#define kEnterAlertViewTag 2
#define kPostNoticeAletViewTag 3

static NSString * const notNeedPersonStr = @"该工作满人了";
static NSString * const isNotTrueWorkStr = @"该工作虚假的";
static NSString * const isInvalidWorkStr = @"该工作无效的";
static NSString * const iWantTalkSomeStr = @"我也要来发言";

@interface DirectAcceptedDetailViewController()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UITextViewDelegate,ChatCommand>
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
    //hjl
    CGFloat _numberOfPages;
    BOOL _isWorkInfoLoaded;
    BOOL _isOwnGroup;
    ChatViewController *_chatVC;
}

@property (strong,nonatomic ) UIButton     *parttimeSituation;
@property (nonatomic, strong) UIButton     *groupChat;
@property (nonatomic, strong) UIButton     *board;
@property (strong,nonatomic ) UIView       *topView;
@property (strong,nonatomic ) UIScrollView *mainScrollView;
@property (strong,nonatomic ) UITableView *tableView;
@property (strong,nonatomic ) UIView      *toolBarView;
@property (strong,nonatomic ) UITableView *detailTableView;
@property (strong,nonatomic ) AFPopupView *popCommentView;
@property (strong, nonatomic) CommentViewController *commentVC;
@property (nonatomic, weak) NotificationBoardCell *boardCell;

@end

@implementation DirectAcceptedDetailViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_isWorkInfoLoaded) {
        [self loadDataAfterViewLoaded];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //    [UIView animateWithDuration:0.5 animations:^{
    //        self.navigationController.navigationBar.hidden = NO;
    //    }];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    self.view.backgroundColor  = RGB(235, 235, 235, 1.0);
    [SVProgressHUD showWithStatus:kRefreshingShowText];
    
    
    [self configureAfterViewLoaded];
    [self configScrollView];
    [self configTopView];
    [self configChatView];//前提是scrollview已经创建好
    [self configTableView];
    [self configToolBar];
    [self configDetailTableView];
    //    [self registerLJWKeyboardHandler];
    [self an_subscribeKeyboardWithAnimations:^(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing) {
        //        self.chatInputBottomSpace.priority = isShowing ? 999 : 250;
        if (_boardCell.noticeTextView.isFirstResponder) {
            if (isShowing) {
                
                CGPoint boardCellOrigin = _boardCell.frame.origin;
                CGPoint boardCellOriginInView = [self.view convertPoint:boardCellOrigin fromView:_tableView];
                CGFloat moveUpViewLength = boardCellOriginInView.y - 20;
                self.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -moveUpViewLength);
                
                CGFloat moveUpBarLength = (CGRectGetHeight(keyboardRect) - moveUpViewLength);
                self.toolBarView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -moveUpBarLength);
                
                
            }else{
                self.toolBarView.transform = CGAffineTransformIdentity;
                self.view.transform = CGAffineTransformIdentity;
            }
        }
        [self.view layoutIfNeeded];
    } completion:nil];
    
    
    
    if (bUser) {
        [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请先登录！"];
        [self popOrDissmissSelf];
    }
    
    _commentVC = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    _userComment = [[NSString alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTheCommentVC) name:KEY_KVO_HIDE_COMMENTVC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWorkDetail:) name:KEY_KVO_GET_WORK_DETAIL object:nil];
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_HIDE_COMMENTVC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_GET_WORK_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];

}

/**
 *  配置tableView
 */
- (void)configTableView
{
    _tableView                    = [[UITableView alloc]initWithFrame:CGRectMake(Width, 64, Width, Height -64 - 44) style:UITableViewStylePlain];
    [_tableView setScrollEnabled:NO];
    _tableView.delegate           = self;
    _tableView.dataSource         = self;
    _tableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor    = RGB(235, 235, 235, 1.0);
    UINib *nib = [UINib nibWithNibName:@"NotificationBoardCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"notificationBoardCellIdentifier"];
    [_mainScrollView addSubview:_tableView];
    
}

/**
 *  配置scrollView
 */
- (void)configDetailTableView
{
    //    if (!_detailTableView) {
    _detailTableView                                = [[UITableView alloc]initWithFrame:CGRectMake(Width * 2, 0, Width, Height - 44) style:UITableViewStylePlain];
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
    _mainScrollView.contentSize                    = CGSizeMake(Width*_numberOfPages, Height);
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

- (void)tapToolBarAction{
    FIRST_RESPONDER;
}
- (void)configToolBar
{
    _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(Width, Height - 44, Width*2, 44)];
    _toolBarView.backgroundColor = RGB(48, 50, 63, 1.0);
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToolBarAction)];
    [tapGR setNumberOfTapsRequired:1];
    [_toolBarView addGestureRecognizer:tapGR];
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
    
    if (_isOwnGroup) {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.center = CGPointMake(Width/2, 44/2);
        editButton.bounds = CGRectMake(0, 0, 87, 28);
        editButton.layer.cornerRadius = 14;
        [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editButton.titleLabel setFont:[UIFont fontWithName:kFontName size:12]];
        [editButton setTitle:@"编辑公告" forState:UIControlStateNormal];
        [editButton setTitle:@"发布" forState:UIControlStateSelected];
        [editButton setBackgroundColor:RGB(252, 122, 130, 1)];
        editButton.tag = 206;
        [editButton addTarget:self action:@selector(toolbarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:editButton];
    }

    
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
    
    CGFloat buttonWidth = Width/_numberOfPages;
    _groupChat = [UIButton buttonWithType:UIButtonTypeCustom];
    _groupChat.frame = CGRectMake(0, 30, Width/_numberOfPages, 34);
    [_groupChat setTitleColor:RGB(150, 150, 150, 1.0) forState:UIControlStateNormal];
    [_groupChat setTitle:@"工作群聊" forState:UIControlStateNormal];
    //    _groupChat.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -70);
    _groupChat.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    [_groupChat setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _groupChat.selected = YES;
    [_groupChat addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_groupChat];
    
    _board = [UIButton buttonWithType:UIButtonTypeCustom];
    _board.frame = CGRectMake(buttonWidth, 30, Width/_numberOfPages, 34);
    [_board setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_board setTitle:@"公告板" forState:UIControlStateNormal];
    //    _board.titleEdgeInsets = UIEdgeInsetsMake(0, -70, 0, 0);
    _board.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    [_board setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_board addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_board];
    
    
    _parttimeSituation = [UIButton buttonWithType:UIButtonTypeCustom];
    _parttimeSituation.frame = CGRectMake(buttonWidth * 2, 30, Width/_numberOfPages, 34);
    [_parttimeSituation setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_parttimeSituation setTitle:@"工作详情" forState:UIControlStateNormal];
    //    _parttimeSituation.titleEdgeInsets = UIEdgeInsetsMake(0, -70, 0, 0);
    _parttimeSituation.titleLabel.font = [UIFont fontWithName:kFontName size:12];
    [_parttimeSituation setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [_parttimeSituation addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_parttimeSituation];
    
    [self.view addSubview:_topView];
}

- (void)buttonAction:(UIButton *)button
{
    if (button == _groupChat) {
        _groupChat.selected = YES;
        _board.selected = NO;
        _parttimeSituation.selected = NO;
        [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    else if (button == _board)
    {
        _groupChat.selected = NO;
        _board.selected = YES;
        _parttimeSituation.selected = NO;
        [_mainScrollView setContentOffset:CGPointMake(Width, 0) animated:YES];
        [self.detailTableView reloadData];
    }else{
        _groupChat.selected = NO;
        _board.selected = NO;
        _parttimeSituation.selected = YES;
        [_mainScrollView setContentOffset:CGPointMake(Width * 2, 0) animated:YES];
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
    if (scrollView == _boardCell.noticeTextView) {
        return;
    }
    
    static int indexOfPageThatNeedTopViewToHide = 2;
    CGFloat index = indexOfPageThatNeedTopViewToHide;
    CGFloat anchor = index * Width;
    CGFloat distance = anchor - _mainScrollView.contentOffset.x;
    distance = fabs(distance);
    if (distance < Width) {
        _topView.alpha = distance/Width;
    }
    
    CGFloat centerOfWindow = _mainScrollView.contentOffset.x + Width / 2;
    if (centerOfWindow  >= 0 && centerOfWindow  < Width) {
        _groupChat.selected    = YES;
        _board.selected = NO;
        _parttimeSituation.selected = NO;
        //        _groupChat.hidden = NO;
        //        _board.hidden = NO;
        //        _topView.hidden = NO;
    }
    else if (centerOfWindow  >= Width && centerOfWindow  < Width * 2  )
    {
        
        _groupChat.selected    = NO;
        _board.selected = YES;
        _parttimeSituation.selected = NO;
        
        //        _groupChat.hidden = YES;
        //        _board.hidden = YES;
        //        _topView.hidden = YES;
        
        FIRST_RESPONDER;
        
    }else{
        
        _groupChat.selected    = NO;
        _board.selected = NO;
        _parttimeSituation.selected = YES;
        FIRST_RESPONDER;
        
        if (!_isWorkInfoLoaded && centerOfWindow == Width * 2.5) {
            [self loadDataAfterViewLoaded];
        }
        
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
        return kThinToolBarHeight;
    }
    else
    {
        return 0;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView == _tableView) {
        UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, kThinToolBarHeight)];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, kThinToolBarHeight - 0.5, Width, 0.5)];
        lineView.backgroundColor = RGB(201, 201, 201, 1);
        [titleView addSubview:lineView];
        titleView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, Width-32, kThinToolBarHeight)];
        titleLabel.font = [UIFont fontWithName:kFontName size:12];
        titleLabel.textColor = RGB(102, 102, 102, 1.0);
        titleLabel.text = _workTitle;
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
        return [tableView fd_heightForCellWithIdentifier:@"notificationBoardCellIdentifier" cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
        }];
    }
    return 44;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _tableView) {
        NotificationBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationBoardCellIdentifier"];
        [self configureCell:cell AndTableView:tableView atIndexPath:indexPath];
        _boardCell = cell;
        [_boardCell.noticeTextView setEditable:NO];
        cell.noticeTextView.delegate = self;
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
        NotificationBoardCell *cell = (NotificationBoardCell *)Cell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = RGB(235, 235, 235, 1.0);
        cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
        cell.contentLabel.text = @"contentlabel";// dataDic[@"Ticp3"];
        cell.ticp2Label.text = @"ticp2label";//dataDic[@"Ticp2"];
        cell.dateLabel.text = [_selfWorkDic objectForKey:@"updatedAt"];//dataDic[@"OrderObjectUpdateTime"];updatedAt
        //        cell.resultLabel.text = [_selfWorkDic objectForKey:@"Notice"];
        [cell.noticeTextView setText:[_selfWorkDic objectForKey:@"Notice"]];//@"这是一条公告！";//dataDic[@"Ticp1"];
        [cell.bgView setImage:nil];
        [cell.bgView setBackgroundColor:[UIColor whiteColor]];
        cell.bgView.layer.cornerRadius = 4;
        
        cell.bgView.layer.shadowOffset = CGSizeMake(0,4);
        cell.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.bgView.layer.shadowOpacity = 0.20;
        
        
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

#pragma mark - UITextViewDelegate


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case kLoginAndEnterAlertViewTag:
            if (buttonIndex == 1) {
                [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
            }
            break;
        case kEnterAlertViewTag:
            if (buttonIndex == 1) {
                [self enterGroupChat];
            }
            break;
        case kCommentAlertViewTag:
            if (buttonIndex == 1) {
                UITextField *text = [alertView textFieldAtIndex:0];
                _userComment = text.text;
                if ([_userComment isEqualToString:@""]) {
                    return;
                }
                [self commentWithContent:_userComment type:@"Comment"];
            }
            break;
        default:
            break;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag) {
        case kLoginAndEnterAlertViewTag:
            if (buttonIndex == 0) {
                [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
            }else if(buttonIndex == 1){
                [self popOrDissmissSelf];
            }
            break;
        case kEnterAlertViewTag:
            if (buttonIndex == 0) {
                [self enterGroupChat];
            }else if(buttonIndex == 1){
                [self popOrDissmissSelf];
            }
            break;
        default:
            break;
    }
}
#pragma mark toolBar点击事件
- (void)toolbarButtonAction:(UIButton *)button
{
    NSInteger i = button.tag;
    switch (i) {
        case 200:
            [self popOrDissmissSelf];
            break;
        case 204:
            [self popOrDissmissSelf];
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
            alertInput.tag = kCommentAlertViewTag;
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
        case 206:
            //            alertInput = [[UIAlertView alloc]initWithTitle:@"请输入新公告" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发布", nil];
            //            alertInput.tag = kPostNoticeAletViewTag;
            //            alertInput.delegate = self;
            //            [alertInput setAlertViewStyle:UIAlertViewStylePlainTextInput];
            //            [alertInput textFieldAtIndex:0].placeholder = @"点击开始输入";
            //            [alertInput show];
            if (button.isSelected) {
                [button setSelected:NO];
                [button setBackgroundColor:RGB(252, 122, 130, 1)];
                [_boardCell.noticeTextView setEditable:NO];
                FIRST_RESPONDER;
                //                FIRST_RESPONDER;
                //此时是发布消息1、拿到字符串，比较与原来的是否相同，不相同则发布。,更新本地的值，发送透传消息。
                if ([_boardCell.noticeTextView.text isEqualToString:[_selfWorkDic objectForKey:@"Notice"]]) {
                    [SVProgressHUD showErrorWithStatus:@"公告内容没有改变~"];
                }else{
                    /**
                     *
                     jsonObject.put("Type", "UpdataSelfWorkNotice");
                     jsonObject.put("CityObjectId", "xxxx");
                     jsonObject.put("Version", "xxxx");
                     jsonObject.put("SelfWorkObjectId", selfWorkId);
                     jsonObject.put("NoticeContent", noticeContent);
                     json.put("inputData", jsonObject);
                     *
                     */
                    
                    
                    NSDictionary *updateNoticeDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"UpdataSelfWorkNotice", @"Type",
                                                     [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],@"CityObjectId",
                                                     kCloudVersion,@"Version",
                                                     [_selfWorkDic objectForKey:@"SelfWorkObjectId"], @"SelfWorkObjectId",
                                                     _boardCell.noticeTextView.text, @"NoticeContent",
                                                     nil
                                                     ];
                    [self updateCloudNoticeWithDic:updateNoticeDic success:^(NSDictionary *object) {
                        LOG(@"object:%@",object);
                        if ([[object valueForKey:@"Static"] isEqualToString:@"success"]) {
                            //mutable ,i know that.
                            [_selfWorkDic setValue:_boardCell.noticeTextView.text forKey:@"Notice"];
                            
                            NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
                            NSTimeInterval a = [dat timeIntervalSince1970];
                            NSString *timeString = [NSString stringWithFormat:@"%.f", a];//转为字符型
                            
                            [_selfWorkDic setValue:_boardCell.noticeTextView.text forKey:@"Notice"];
                            [_selfWorkDic setValue:timeString forKey:@"updatedAt"];

                            [_chatVC updateWorkGroupNotice:_boardCell.noticeTextView.text timeString:timeString];
                            
                            [SVProgressHUD showSuccessWithStatus:@"更新公告成功~"];
//                            chatVc.name = _workTitle;
//                            BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
//                            chatVc.isSender_yes_headimage = headImg.url;
//                            chatVc.isMy_Nickname = [bUser objectForKey:@"Nickname"];
//                            chatVc.isChatGroup_WorkTitle = _workTitle;
//                            chatVc.GroupOwnerId = [_selfWorkDic objectForKey:@"GroupOwnerId"];
//                            
//                            
//                            
//                            chatVc.workTitle = self.workTitle;
//                            chatVc.selfWorkDic = self.selfWorkDic;
//                            chatVc.workOrderObjectId = self.workOrderObjectId;
//                            chatVc.workObjectId = self.workObjectId;


                            
                        }
                        
                    } fail:^(NSString *reason) {
                        [SVProgressHUD showErrorWithStatus:reason];
                    }];
                }
            }else{
                [button setSelected:YES];
                [button setBackgroundColor:RGB(2, 168, 243, 1)];
                [_boardCell.noticeTextView setEditable:YES];
                [_boardCell.noticeTextView becomeFirstResponder];
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
        
        
    }else if ([workModel.applyWay isEqualToString:@"Way2"]) {
        [alert addAction:[HLAlertAction actionWithTitle:@"打电话" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
            [self callThePhone:workModel.companyUserPhone];
        }]];
        [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
            
        }]];
        
        
    }else if ([workModel.applyWay isEqualToString:@"Way3"]) {
        [alert addAction:[HLAlertAction actionWithTitle:@"发短信" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
            [self sendSMS:workModel.message recipientList:[NSArray arrayWithObjects:workModel.companyUserPhone, nil]];
        }]];
        [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
            
        }]];
        
        
    }else if ([workModel.applyWay isEqualToString:@"Way4"]) {
        [SVProgressHUD showErrorWithStatus:workModel.message];
        
    }else if ([workModel.applyWay isEqualToString:@"Way5"]) {
        [alert addAction:[HLAlertAction actionWithTitle:@"打电话" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
            [self callThePhone:workModel.companyUserPhone];
        }]];
        [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
            
        }]];
        
    }else {
        
        [SVProgressHUD showErrorWithStatus:@"请留意最新版本功能"];
    }
    [alert showWithViewController:self];
    
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


#pragma mark - gesture
- (void)handlePraiseAlert:(UIGestureRecognizer *)gesture {
    [alertTheAction removeFromSuperview];
}


#pragma mark 获取数据


- (void)configureAfterViewLoaded{
    bUser = [BmobUser getCurrentUser];
    
    if (bUser) {
        _isOwnGroup = ([bUser.objectId isEqualToString: [_selfWorkDic objectForKey:@"GroupOwnerId"]]);
    }
    
    dic2 = [NSDictionary dictionaryWithObjectsAndKeys:
            kCloudVersion,kVersion,
            @"GetWork",kType,
            bUser ? bUser.objectId : @"",kUserObjectId,
            _workObjectId,@"WorkObjectId",
            @"ios",kDeviceType,
            nil];
    _numberOfPages = 3;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popOrDissmissSelf) name:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];


}
- (void)loadDataAfterViewLoaded{
    
    //    [_tableView reloadData];
    
    /**
     *  {"inputData":{"Version":"321","Type":"GetWork","WorkObjectId":"4cd24dbe30","UserObjectId":"61acc57699","DeviceType":"android"}}
     */
    
    
    [self getWorkInfoWithDic:dic2 success:^(NSDictionary *object) {
        
        workModel = [WorkModel initWithDic:[object objectForKey:@"Work"]];
        UIImage *blurImage = nil;
        UIImage *img;
        UIImageView *imgBackground = [[UIImageView alloc]initWithFrame:CGRectMake(Width * 2, 0, Width, Height/2)];
        [imgBackground sd_setImageWithURL:[NSURL URLWithString:workModel.headImgUrl]];
        img = imgBackground.image;
        blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
        imgBackground.image = blurImage;
        [_mainScrollView insertSubview:imgBackground belowSubview:_detailTableView];
        
        _isWorkInfoLoaded = true;
        [self.detailTableView reloadData];
        [SVProgressHUD showSuccessWithStatus:kRefreshedFinish];
    } fail:^(NSString *reason) {
        LOG(@"reason === %@",reason);
        [SVProgressHUD showErrorWithStatus:kNetworkWarning];
    }];
}



- (void)detailStopRefreshing{
    [SVProgressHUD showErrorWithStatus:kNetworkWarning];
}

- (void)showInfoToView
{
    [_detailTableView reloadData];
}


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
}/**
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

- (void)updateCloudNoticeWithDic:(NSDictionary *)inputDic success:(void (^)(NSDictionary *object))success fail:(void (^)(NSString *reason))fail{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:inputDic forKey:@"inputData"];
    
    [BmobCloud callFunctionInBackground:kCloudMessage withParameters:dict block:^(id obj, NSError *err){
        
        if (obj) {
            success(obj);
        }
        if (err) {
            fail(kNetworkWarning);
        }
    }];
}


#pragma mark - AllAboutChatView
- (void)configChatView{
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Width, Height)];
    [self.mainScrollView addSubview:containerView];
    
    NSString *groupId = [_selfWorkDic objectForKey:@"GroupId"];
    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:groupId isGroup:YES];
    
    //    bUser = [ShareDataSource sharedDataSource].myData;
    bUser = [BmobUser getCurrentUser];
    chatVc.name = _workTitle;
    BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
    chatVc.isSender_yes_headimage = headImg.url;
    chatVc.isMy_Nickname = [bUser objectForKey:@"Nickname"];
    chatVc.isChatGroup_WorkTitle = _workTitle;
    chatVc.GroupOwnerId = [_selfWorkDic objectForKey:@"GroupOwnerId"];
    chatVc.ChatCommand_delelgate = self;
    
    
    chatVc.workTitle = self.workTitle;
    chatVc.selfWorkDic = self.selfWorkDic;
    chatVc.workOrderObjectId = self.workOrderObjectId;
    chatVc.workObjectId = self.workObjectId;
    
    
    [self addChildViewController:chatVc];
    [containerView addSubview:chatVc.view];
    [chatVc didMoveToParentViewController:self];
    _chatVC = chatVc;
    
}

- (void)popOrDissmissSelf{
    if (self.navigationController) {
        if (self.tabBarController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


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
             //             LOG(@"---保存Session ＝ %@--",SESSIONID);
             
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
             [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
             
             //             [weakSelf toMain];
             [self enterGroupChat];
         }else {
             
             switch (error.errorCode) {
                     
                     //                 case EMErrorServerNotReachable:
                     //                     //                     TTAlertNoTitle(@"连接服务器失败!");
                     //                     LOG(@"hx连接服务器失败!");
                     //                     break;
                     
                 case EMErrorTooManyLoginRequest:
                 {
                     //                     [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                     //                     [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
                     //                     [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                     
                     [self enterGroupChat];
                     
                 }
                     break;
                 case EMErrorInvalidUsername:
                     LOG(@"无效的username!");
                     [[EaseMob sharedInstance].chatManager registerNewAccount:[bUser objectForKey:kobjectId] password:@"QAZWSXEDC" error:&error];
                     [self loginEaseForRcid:[bUser objectForKey:kobjectId] md5Passwodrd:@"QAZWSXEDC"];
                     break;
                     //                 case EMErrorServerAuthenticationFailure:
                     //                     //                     TTAlertNoTitle(error.description);
                     //                     //                     [self.hud hide:YES];
                     //                     LOG(@"hxerror.description");
                     //                     break;
                     //                 case EMErrorServerTimeout:
                     //
                     //                     LOG(@"hx连接服务器超时!");
                     //                     break;
                     //                 case EMErrorNetworkNotConnected:
                     //                     LOG(@"网络未连接!");
                     //                     break;
                     
                 default:
                     LOG(@"hx登录失败");
                     if (error.description) {
                         [self showActionSheetWithTitle:error.description tag:kLoginAndEnterAlertViewTag];


                     }else{
                         [self showActionSheetWithTitle:@"未知错误." tag:kLoginAndEnterAlertViewTag];
                         
                     }
                     
                     
                     break;
             }
         }
     } onQueue:nil];
    
}

- (void)showActionSheetWithTitle:(NSString *)title tag:(NSInteger)tag{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"算了" destructiveButtonTitle:nil otherButtonTitles:@"我已经联网了，再试试", nil];
    [actionSheet setTintColor:RGB(102, 102, 102, 1)];
    [actionSheet tintColorDidChange];
    actionSheet.tag = tag;
    [actionSheet showInView:self.view];
}

- (void)enterGroupChat{
    NSString *groupId = [_selfWorkDic objectForKey:@"GroupId"];
    [[EaseMob sharedInstance].chatManager asyncJoinPublicGroup:groupId completion:^(EMGroup *group, EMError *error) {
        if (!error) {
            LOG(@"入群成功");
            
        }else if(error.errorCode == EMErrorGroupJoined)
        {
            LOG(@"已经入群");
        }else if(error.errorCode == EMErrorServerNotLogin){
            LOG(@"hx未登录");
            
            
            
            if (error.description) {
                [self showActionSheetWithTitle:error.description tag:kLoginAndEnterAlertViewTag];
                
                
            }else{
                [self showActionSheetWithTitle:@"未知错误." tag:kLoginAndEnterAlertViewTag];
                
            }
            
            
            
            //            [alertError show];
        }else{
            LOG(@"失败");
            
            
            
            if (error.description) {
                [self showActionSheetWithTitle:error.description tag:kEnterAlertViewTag];
                
                
            }else{
                [self showActionSheetWithTitle:@"未知错误." tag:kEnterAlertViewTag];
                
            }

            //
            //            [SVProgressHUD showErrorWithStatus:@"无法进入群聊，请检查网络连接并重新进入！"];
        }
    } onQueue:nil];
}

//
- (void)wt_ChatCommand:(NSString *)noticeText timeString:(NSString *)timeString{
    if (timeString) {
        [_boardCell.dateLabel setText:timeString];
    }else{
        
        
        
        NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a = [dat timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%.f", a];//转为字符型
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSMutableDictionary *abbs = [[NSMutableDictionary alloc] init];
        [abbs setValuesForKeysWithDictionary:[NSTimeZone abbreviationDictionary]];
        [abbs setValue:@"Asia/Shanghai" forKey:@"CCD"];
        [NSTimeZone setAbbreviationDictionary:abbs];
        [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeString integerValue]];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

        [_boardCell.dateLabel setText:confromTimespStr];
        
        //mutable ,i know that.
        [_selfWorkDic setValue:confromTimespStr forKey:@"updatedAt"];
    }
    [_boardCell.noticeTextView setText:noticeText];
    
    //mutable ,i know that.
    [_selfWorkDic setValue:_boardCell.noticeTextView.text forKey:@"Notice"];

//    [SVProgressHUD showSuccessWithStatus:@"公告已更新~"];
}



@end
