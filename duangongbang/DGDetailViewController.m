//
//  DGDetailViewController.m
//  duangongbang
//
//  Created by ljx on 15/5/16.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "DGDetailViewController.h"
#import "UILabel+StringFrame.h"
#import "WorkModel.h"
#import <BmobSDK/BmobCloud.h>
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import "TimeCaculate.h"
#import "UIImageView+WebCache.h"
#import <pop/POP.h>
#import "Masonry.h"
#import "UIImage+ImageEffects.h"
#import "SVProgressHUD.h"
#import "CompanyDetailViewController.h"
#import "HLAlertController.h"
#import "CommentViewController.h"
#import "AFPopupView.h"
#import "UIView+Border.h"
#import "CommonServers.h"
#import "ShareSDKClass.h"
#import "TOWebViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "LabelPlacing.h"
#import "LoginViewController.h"
#import "ChatViewController.h"
#import "MyResumeViewController.h"
#import "ContentModel.h"
#import "NotificationViewController.h"
#import "ConsultingViewController.h"
#import "DirectAcceptedDetailViewController.h"

typedef NS_ENUM(NSInteger, UIAlertViewDetailTag) {
    UIAlertViewDetailTagApply = 100,
    UIAlertViewDetailTagComment = 101,
    UIAlertViewDetailTagRecomment = 102,
    UIAlertViewDetailTagCustomService = 103,
};

static NSString * const notNeedPersonStr = @"该工作满人了";
static NSString * const isNotTrueWorkStr = @"该工作虚假的";
static NSString * const isInvalidWorkStr = @"该工作无效的";
static NSString * const iWantTalkSomeStr = @"我也要来发言";

static CGFloat const viewCornorRadius = 4.0;

#define kOpenDetailTimes @"detailTimesOpened"
#define kDeviceType @"DeviceType"
#define kType @"Type"
#define kVersion @"Version"
#define kWorkObjectId @"WorkObjectId"
#define kUserObjectId @"UserObjectId"
#define kContent @"Content"
#define kAdviseObjectId @"AdviseObjectId"
#define kCompanyUserObjectId @"CompanyUserObjectId"

#define kMargin 10.0
#define kImgWH 20.0
#define kBtnViewWH 29.0
#define kLabelHeight 7.0
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kToolHighLightColor 0x14618b
#define kResumeButtonWidrh 60
#define kResumeButtonHeight 60


@interface DGDetailViewController ()<UIGestureRecognizerDelegate,UIAlertViewDelegate,MFMessageComposeViewControllerDelegate>{
    WorkModel *workModel;
    NSDictionary *dic;
    BmobUser *bUser;
    UIView *toolView;
    UIView *praiseView;
    NSMutableDictionary *workPraise;
    NSMutableDictionary *comment;
    NSMutableDictionary *reComment;
    NSString *_userComment;
    UIAlertView *alertInput;

    
    __weak IBOutlet UIButton *_btnCommentShow;
    
    __strong AFPopupView *_popCommentView;
    
    __weak IBOutlet UIButton *_btnCompanyDetail;
    
    __weak IBOutlet UIView *_commentView;
    __weak IBOutlet UIView *_bottomView;
    __weak IBOutlet UIView *_knowView;
    __weak IBOutlet UIView *_detailView;
    __weak IBOutlet UIView *_headView;
    
    
    UIView *alertTheAction;
    UIImageView *imageViewAlert;
}

@property (weak, nonatomic) IBOutlet UIToolbar *myToolBar;

- (IBAction)back:(id)sender;
- (IBAction)praise:(id)sender;
- (IBAction)discuss:(id)sender;
- (IBAction)service:(id)sender;
- (IBAction)share:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *praiseItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeAndViewedTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundImgTop;


@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainSrcollView;
//@property (weak, nonatomic) IBOutlet PagingScrollView *toolScrollView;//2015.9.9resize -> toolBarView
@property (strong,nonatomic) UIView * toolBarView;// toolScrollView -> toolBarView
@property (strong,nonatomic) UIButton * ResumeButton;

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UILabel *lbLikeNum;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgVer;
@property (weak, nonatomic) IBOutlet UIImageView *imgPlaint;
@property (weak, nonatomic) IBOutlet UILabel *lbClickNotic;
@property (weak, nonatomic) IBOutlet UILabel *lbClickPersonNum;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *lbCompanyUserName;
@property (weak, nonatomic) IBOutlet UILabel *lbClassifyName;
@property (weak, nonatomic) IBOutlet UILabel *lbPriceUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbSex;
@property (weak, nonatomic) IBOutlet UILabel *lbPayMethod;
@property (weak, nonatomic) IBOutlet UILabel *lbWorkDateStr;
@property (weak, nonatomic) IBOutlet UILabel *lbStreetName;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@property (weak, nonatomic) IBOutlet UILabel *lbApplyKnowNormal;
@property (weak, nonatomic) IBOutlet UILabel *lbApplyKnowRed;
@property (weak, nonatomic) IBOutlet UIImageView *imgNotic;

@property (strong, nonatomic) CommentViewController *commentVC;
@property (strong, nonatomic) UILabel *praiseNum;
@property (weak, nonatomic) IBOutlet UIView *backViewAddShadow;
@property (strong, nonatomic) NSMutableArray *contentArray;

@end
@implementation DGDetailViewController
@synthesize praiseNum;
@synthesize workObjectId;
@synthesize mainViewPush;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:!mainViewPush];
    

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"praiseCount" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _contentArray = [[NSMutableArray alloc]init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger timesOpened = [defaults integerForKey:kOpenDetailTimes];
    if (timesOpened < 3) {
        alertTheAction = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainScreenWidth, mainScreenHeight + 20)];
        alertTheAction.backgroundColor = UIColorFromRGBAlpha(0x212121, 0.3);
        [self.tabBarController.view addSubview:alertTheAction];
        imageViewAlert = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Alert_Praise"]];
        imageViewAlert.contentMode = UIViewContentModeCenter;
        imageViewAlert.center = CGPointMake(mainScreenWidth/5 + mainScreenWidth/10, mainScreenHeight - 50.0);
        imageViewAlert.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePraiseAlert:)];
        [imageViewAlert addGestureRecognizer:tap];
        [alertTheAction addSubview:imageViewAlert];
    }
    
    [defaults setInteger:timesOpened+1 forKey:kOpenDetailTimes];
    [defaults synchronize];
    
    _commentVC = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
    
    /**
     * {"Type":"GetWork","Version":"3","WorkObjectId":"","UserObjectId":""}
     */
    
    [SVProgressHUD showWithStatus:kRefreshingShowText];
    
    bUser = [BmobUser getCurrentUser];
    
    dic = [NSDictionary dictionaryWithObjectsAndKeys:
           @"GetWork",kType,
           kCloudVersion,kVersion,
           workObjectId,kWorkObjectId,
           bUser ? bUser.objectId : @"",kUserObjectId,
           @"iOS",kDeviceType,
           nil];
    
    /**
     * 点赞：{"Type":"WorkPraise","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55"}
     * 评论：{"Type":"Comment","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55","Content":"感觉还行，继续加油"}
     * 回复：{"Type":"ReComment","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55","Content":"感觉还行，继续加油","AdviseObjectId":"f5ea273017"}
     */
    workPraise = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  @"WorkPraise",kType,
                  kCloudVersion,kVersion,
                  bUser ? bUser.objectId : @"",kUserObjectId,
                  workObjectId,kWorkObjectId,
                  nil];
    comment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
               @"Comment",kType,
               kCloudVersion,kVersion,
               bUser ? bUser.objectId : @"",kUserObjectId,
               workObjectId,kWorkObjectId,
               @"",kContent,
               nil];
    reComment = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                 @"ReComment",kType,
                 kCloudVersion,kVersion,
                 bUser ? bUser.objectId : @"",kUserObjectId,
                 workObjectId,kWorkObjectId,
                 @"",kContent,
                 @"",kAdviseObjectId,
                 nil];
    
    
    [self performSelector:@selector(getWorkDetail:) withObject:nil afterDelay:1.0];
    
    //添加详情页卡片圆角
    _headView.layer.cornerRadius = viewCornorRadius;
    _detailView.layer.cornerRadius = viewCornorRadius;
    _contentView.layer.cornerRadius = viewCornorRadius;
    _knowView.layer.cornerRadius = viewCornorRadius;
    _commentView.layer.cornerRadius = viewCornorRadius;
    _bottomView.layer.cornerRadius = viewCornorRadius;
    
    //添加AlertView
    alertInput = [[UIAlertView alloc] initWithTitle:@"评论" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertInput.tag = 1000;
    alertInput.delegate = self;

    //TODO: 添加详情页autolayout
    _imgHead.layer.cornerRadius = 28.0;
    _imgHead.layer.borderColor = UIColorFromRGB(0xf5f5f5).CGColor;
    _imgHead.layer.borderWidth = 2.0;
    [_imgHead.layer setMasksToBounds:YES];
    CGFloat viewHeight = 934.0;
    _mainView.frame = CGRectMake(0, 0, mainScreenWidth, viewHeight);
    [_mainView updateConstraints];
    [_mainView layoutIfNeeded];
    _mainSrcollView.frame = CGRectMake(0, 0, mainScreenWidth, mainScreenHeight);
    _mainSrcollView.contentSize = CGSizeMake(mainScreenWidth, viewHeight);
    [_mainSrcollView addSubview:_mainView];
    
    praiseNum = [[UILabel alloc] init];
    //自定义点赞的按钮的个数，并添加次数的通知
    praiseNum.frame = CGRectMake(0, 0, 10, 10);
    [praiseNum setTextAlignment:NSTextAlignmentCenter];
    praiseNum.textColor = [UIColor whiteColor];
    praiseNum.font = [UIFont systemFontOfSize:10.0f];
    
    praiseNum.center = CGPointMake(10, 10);
    praiseNum.text = @"";//点赞个数label
    
    
//    [_mainSrcollView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
    
    
    _imgReturnDissmiss.backgroundColor = UIColorFromRGB(kToolGrayColor);
    _backViewAddShadow.backgroundColor = UIColorFromRGB(kTooLBackColor);
//    _toolScrollView.backgroundColor = UIColorFromRGB(kTooLBackColor);//resize
    _toolBarView.backgroundColor = UIColorFromRGB(kTooLBackColor);
    
    _imgReturnDissmiss.layer.cornerRadius = 19.5;
    [_imgReturnDissmiss.layer setMasksToBounds:YES];
    [_imgReturnDissmiss setTag:11];
    
    [_btnCompanyDetail addTarget:self action:@selector(companyDetailHandle:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnCommentShow.layer.cornerRadius = 3.0;
    
    [_btnCommentShow addBorderWithColor:UIColorFromRGB(0xcccccc) andWidth:0.5];
    
    [_btnCommentShow addTarget:self action:@selector(showTheCommentVC) forControlEvents:UIControlEventTouchUpInside];
    
//    UITapGestureRecognizer *returnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolBtnShow:)];
//    returnTap.delegate = self;
    
    _imgReturnDissmiss.userInteractionEnabled = YES;
//    [_imgReturnDissmiss addGestureRecognizer:returnTap];

    UITapGestureRecognizer *noticTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNoticStr:)];
    noticTap.delegate = self;
    _imgNotic.userInteractionEnabled = YES;
    [_imgNotic addGestureRecognizer:noticTap];
    [self.view isExclusiveTouch];
    
    //KVO
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTheCommentVC) name:KEY_KVO_HIDE_COMMENTVC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWorkDetail:) name:KEY_KVO_GET_WORK_DETAIL object:nil];
    
    //创建简历按钮
    [self createResumeButton];

    _myToolBar.frame = CGRectMake(0, mainScreenHeight - 22, mainScreenWidth, 44);
    _myToolBar.barTintColor = [UIColor colorWithRed:48/255.0 green:50/255.0 blue:63/255.0 alpha:1.0];
    _myToolBar.translucent = NO;
    [self.view addSubview:_myToolBar];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    LOG(@"%@",_btnCommentShow);
}


//- (void)configTableView
//{
//    _lbContent.dataSource = self;
//    _lbContent.delegate = self;
//    _lbContent.backgroundColor = [UIColor clearColor];
//    
//}


#pragma mark - ResumeButton
- (void)createResumeButton
{
    _ResumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _ResumeButton.frame = CGRectMake(mainScreenWidth - 80, mainScreenHeight - 90, kResumeButtonWidrh, kResumeButtonHeight);

    [_ResumeButton setBackgroundImage:[UIImage imageNamed:@"resume"] forState:UIControlStateNormal];
    [_ResumeButton setTitle:@"我要\n报名" forState:UIControlStateNormal];
    _ResumeButton.titleLabel.textColor = [UIColor whiteColor];
    _ResumeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _ResumeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _ResumeButton.titleLabel.numberOfLines = 2;
    [self.view addSubview:_ResumeButton];
    
    [_ResumeButton addTarget:self action:@selector(ResumeButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)ResumeButtonAction
{
    bUser = [BmobUser getCurrentUser];
    if (bUser)
    {
        [self applyTheWork];
    }
    else
    {
        [self chackIsLoginAndAlert];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}
- (void)showInfoToView{
    

    _lbLikeNum.text = [NSString stringWithFormat:@"%@",workModel.viewedTimes];
    NSString *date = [TimeCaculate getUTCFormateDate:[workModel.createdAt substringToIndex:16]];
    _lbTime.text = [NSString stringWithFormat:@"发表于%@",date];
    _lbTitle.text = workModel.title;
    
    if ([workModel.vip isEqualToString:@"1"]) {
        _imgVer.image = [UIImage imageNamed:@"黄色V"];
    }else{
        _imgVer.image = nil;
    }
    [_imgHead sd_setImageWithURL:[NSURL URLWithString:workModel.headImgUrl] placeholderImage:[UIImage imageNamed:@"Head_Image.png"] completed:^(UIImage *image,NSError *err,SDImageCacheType cacheType,NSURL *imageURL){
        
        UIImage *img;
        if(image){
            img = image;
        }else{
            img = _imgHead.image;
        }
        UIImage *blurImage = nil;
        blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
        _imgBackground.image = blurImage;
        
    }];
    
    _lbCompanyUserName.text = workModel.companyUserName;
//    _lbClickNotic.text = workModel.textClickNotic;
//    _lbClickPersonNum.text = workModel.textPersonNumStr;
    _lbClickNotic.text = workModel.textPersonNumStr;
    
    NSNumber *need = workModel.needNum;
    NSNumber *pass = workModel.passNum;
    _lbClickPersonNum.text = [NSString stringWithFormat:@"%d/%d",[pass intValue],[need intValue]];
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"progress" initializer:^(POPMutableAnimatableProperty *prop){
        prop.writeBlock = ^(id obj, const CGFloat value[]) {
            _progressView.progress = (float)value[0] / [need floatValue];
        };
    }];
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];   //线性的时间函数
    anBasic.property = prop;    //自定义属性
    anBasic.fromValue = @(0);   //从0开始
    anBasic.toValue = @([pass floatValue]);
    anBasic.duration = kProgressTime;    //持续
    //anBasic.beginTime = CACurrentMediaTime() + 1.0f;    //延迟1秒开始
    [_progressView pop_addAnimation:anBasic forKey:@"progress"];
    
    _lbClassifyName.text = workModel.classifyName;
    _lbPriceUnit.text = workModel.priceAndUnit;
    _lbSex.text = workModel.sex;
    _lbPayMethod.text = workModel.payMethod;
    _lbWorkDateStr.text = workModel.workDateStr;
    _lbStreetName.text = workModel.streetName;
    
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
        _lbContent.text = muStr;
    }else {
        _lbContent.text = workModel.content;
    }
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:_lbContent.text];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:4];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [_lbContent.text length])];
    [_lbContent setAttributedText:attributedString1];
    //    [_lbContent sizeToFit];
    
    CGSize size = [_lbContent boundingRectWithSize:CGSizeMake(mainScreenWidth * 0.9 - 32, MAXFLOAT)];
    _lbContent.numberOfLines = 0;
    
    [_lbApplyKnowNormal setAttributedText:attributedString1];
    
    //    [_lbApplyKnowNormal sizeToFit];
    CGSize size2 = [_lbApplyKnowRed boundingRectWithSize:CGSizeMake(mainScreenWidth * 0.9 - 32, MAXFLOAT)];
    CGFloat newHeight = (size.height + size2.height)*8/6;
    
    [_lbContent updateConstraints];
    
    [_contentView updateConstraints];

    
    _mainView.frame = CGRectMake(0, 0, mainScreenWidth, 942 + newHeight - 60);
    
    _mainSrcollView.contentSize = CGSizeMake(mainScreenWidth,942 + newHeight - 60);
    [_mainView updateConstraints];
    
    _lbApplyKnowNormal.text = workModel.applyKnowNormal;

    
    [LabelPlacing thtLabelPlacingWith:_lbApplyKnowNormal];
    _lbApplyKnowNormal.textAlignment = NSTextAlignmentLeft;
    _lbApplyKnowRed.text = workModel.applyKnowRed;
    
    _lbApplyKnowRed.font = [UIFont fontWithName:kFontName size:10];
    
    [LabelPlacing thtLabelPlacingWith:_lbApplyKnowRed];
    
    if (workModel.commentList.count == 0) {
        _btnCommentShow.hidden = YES;
    }else {
        _btnCommentShow.hidden = NO;
    }
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_HIDE_COMMENTVC object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_GET_WORK_DETAIL object:nil];

}

- (void)showNoticStr:(UIGestureRecognizer *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:workModel.textClickNotic delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - gestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
//    if ([touch.view isKindOfClass:[UIView class]]){
//        
//        return NO;
//        
//    }
//    
    return YES;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 0) {
        if (scrollView.contentOffset.y <= 0) {
            _backgroundImgTop.constant = scrollView.contentOffset.y;
            _timeAndViewedTop.constant = scrollView.contentOffset.y + 20;
        }
    }
}

#pragma mark - 调用短信
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]) {
            controller.body = bodyOfMessage;
            controller.recipients = recipients;
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


- (void)noticWithMainThread
{
    [self performSelectorOnMainThread:@selector(setPraiseViewAndNum) withObject:workModel waitUntilDone:NO];
}

#pragma mark - praiseAndNum设置点赞个数
- (void)setPraiseViewAndNum{
    
    if (workModel) {
        if (workModel.praiseCount.intValue == 0)
        {
            _praiseItem.tintColor = [UIColor whiteColor];
        }
        else
        {
            [praiseNum setText:[NSString stringWithFormat:@"%d",[workModel.praiseCount intValue]]];
        }
    }
    else
    {
        [praiseNum setText:@"点赞"];
    }
}


#pragma mark - toolbarMethod
- (IBAction)back:(id)sender
{

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)praise:(id)sender
{
    if (bUser) {
        [self callInteractiveCloudWithDic:workPraise success:^(NSDictionary *obj){
            
            if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                _praiseItem.tintColor = [UIColor colorWithRed:255/255.0 green:182/255.0 blue:193/255.0 alpha:1.0];
                workModel.praiseCount = [obj objectForKey:@"PraiseCount"];
                [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"Value"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"praiseCount" object:nil];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticWithMainThread) name:@"praiseCount" object:workModel];
                
                
            }
            else if ([[obj objectForKey:@"Static"] isEqualToString:@"faile"]){
                [SVProgressHUD showErrorWithStatus:[obj objectForKey:@"Value"]];
                
            }
            
        }fail:^(NSString *err){
            
        }];
        
    }else{

        [self chackIsLoginAndAlert];
    }

}

- (IBAction)discuss:(id)sender
{
    if (!bUser) {
        [self chackIsLoginAndAlert];
        return;
    }
    
    HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"投诉选项" message:nil preferredStyle:HLAlertControllerStyleActionSheet];
    
    [alert addAction:[HLAlertAction actionWithTitle:notNeedPersonStr style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
        [self commentWithContent:@"人满" type:@"WorkComplain"];
    }]];
    [alert addAction:[HLAlertAction actionWithTitle:isNotTrueWorkStr style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
        [self commentWithContent:@"虚假" type:@"WorkComplain"];
    }]];
    [alert addAction:[HLAlertAction actionWithTitle:isInvalidWorkStr style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
        [self commentWithContent:@"无效" type:@"WorkComplain"];
    }]];
    [alert addAction:[HLAlertAction actionWithTitle:iWantTalkSomeStr style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
        [alertInput setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alertInput textFieldAtIndex:0].placeholder = @"评论：";
        [alertInput show];
    }]];
    
    [alert showWithViewController:self];
}

- (IBAction)service:(id)sender
{

    ConsultingViewController *consultVC = [[ConsultingViewController alloc]init];
    mainViewPush = NO;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:consultVC animated:YES];

}

- (IBAction)share:(id)sender
{
    [ShareSDKClass shareWithImage:[UIImage imageNamed:@"DGBIcon"] contentText:[NSString stringWithFormat:@"刚刚在短工邦看到一条工作信息“%@”，薪资%@，在%@工作，有兴趣的可以下载短工邦报名哦！%@%@", workModel.title, workModel.priceAndUnit, workModel.streetName, kWorkUrlPrefix, workModel.workObjectId] title:workModel.title type:SSDKContentTypeAuto view:nil url:[NSString stringWithFormat:@"%@%@",kWorkUrlPrefix,workModel.workObjectId]];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            UITextField *text = [alertView textFieldAtIndex:0];
            _userComment = text.text;
            if ([_userComment isEqualToString:@""]) {
                return;
            }
            [self commentWithContent:_userComment type:@"Comment"];
        }
    }else if (alertView.tag == 1001) {
        if (buttonIndex == 1) {
            UINavigationController *nav = [[UINavigationController alloc] init];
            LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [nav pushViewController:logVC animated:NO];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    
    
}

#pragma mark - gesture
- (void)handlePraiseAlert:(UIGestureRecognizer *)gesture {
    [alertTheAction removeFromSuperview];
}

- (void)companyDetailHandle:(UIGestureRecognizer *)gesture {
    if (workModel) {
        CompanyDetailViewController *companyVC = [[CompanyDetailViewController alloc] initWithNibName:@"CompanyDetailViewController" bundle:nil];
        companyVC.userObjectId = workModel.companyUserId;
        mainViewPush = NO;
        self.hidesBottomBarWhenPushed = YES;
//        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:companyVC];
        [self.navigationController pushViewController:companyVC animated:YES];
//        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - methods
- (void)commentWithContent:(NSString *)str type:(NSString *)type{
    /**
     *  {"Type":"Comment","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55","Content":"感觉还行，继续加油"}
     */
    bUser = [BmobUser getCurrentUser];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:bUser.objectId, @"UserObjectId", type, @"Type", kCloudVersion, @"Version", workModel.workObjectId, @"WorkObjectId", str, @"Content", nil];
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

- (void)applyTheWork {
    /**
     *  
     “ApplyWay”
     为空、Way1   打电话发短信
     Way2打电话
     Way3发短信
     Way4弹窗
     way5发送简历
     其它（弹窗：请更新版本查看）
     先调用WantWork，如果返回
     responseData.NextStep = "NeedLogin";表示需要登录，弹出登录对话框
     responseData.NextStep = "NO";表示被列入黑名单，弹出responseData.Value
     responseData.NextStep = "NeedResume";表示需要简历，弹出完善简历对话框
     responseData.Static = "faile";直接弹出responseData.Value
     
     //想要工作:"WantWork"
     function WantWork() {
     var Request = require("../cloud/V3_Interactive.js").V3_Request;
     tool.test(Request,{"inputData":{"Type":"WantWork","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55"}});
     }
     */
    
    /*发送简历：
    {"Step":1,
        "UserObjectId":"bf7dc21fb4",
        "WorkObjectId":"105f832181",
        "CompanyUserObjectId":"3c018af4d1",
        "Type":"WorkApply",
        "Version":"312",
        "CityObjectId":"ZUaK444F"}}
     */
    _ResumeButton.enabled = NO;
    NSMutableDictionary *resume = [NSMutableDictionary dictionaryWithObjectsAndKeys:
              @1,@"Step",
              bUser ? bUser.objectId : @"",kUserObjectId,
              workObjectId,kWorkObjectId,
              @"WorkApply",kType,
              kCloudVersion,kVersion,
              workModel.companyUserId,kCompanyUserObjectId,
              @"",@"CityObjectId",
              nil];
    /**
     "Step":2,"UserObjectId":"bf7dc21fb4","WorkObjectId":"105f832181","CompanyUserObjectId":"3c018af4d1","Type":"WorkApply","Version":"312","CityObjectId":"ZUaK444F"}}
     
     */
    NSMutableDictionary * sendResume = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @2,@"Step",
                                        bUser ? bUser.objectId : @"",kUserObjectId,
                                        workObjectId,kWorkObjectId,
                                        workModel.companyUserId,kCompanyUserObjectId,
                                        @"WorkApply",kType,
                                        kCloudVersion,kVersion,
                                        @"",@"CityObjectId",
                                        nil];
    
    if ([workModel.applyWay isEqualToString:@"Way5"]) {
        if (!bUser) {
            [self chackIsLoginAndAlert];
        }
        [self callInteractiveCloudWithDic:resume success:^(NSDictionary *obj) {
        if ([[obj objectForKey:@"Static"]isEqualToString:@"faile"]) {
                [SVProgressHUD showInfoWithStatus:[obj objectForKey:@"Value"]];
        }else {
        HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"确定要申请这个工作?" message:nil preferredStyle:HLAlertControllerStyleAlert];
        [alert addAction:[HLAlertAction actionWithTitle:@"确定" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
            [self callInteractiveCloudWithDic:sendResume success:^(NSDictionary *obj) {
                if ([[obj objectForKey:@"NextStep"] isEqualToNumber:@3])
                {
                    [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"Ticp"]];
                    NotificationViewController *notifVC = [[NotificationViewController alloc]init];
                    [self setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:notifVC animated:YES];
                }
                else if ([[obj objectForKey:@"NextStep"] isEqualToNumber:@1])
                {
                    HLAlertController *alert2 = [HLAlertController alertControllerWithTitle:@"没有填写完整的简历" message:nil preferredStyle:HLAlertControllerStyleAlert];
                    [alert2 addAction:[HLAlertAction actionWithTitle:@"前往修改" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                    MyResumeViewController * myResumeVC = [[MyResumeViewController alloc]init];
                        [self setHidesBottomBarWhenPushed:YES];
                        [self.navigationController pushViewController:myResumeVC animated:YES];
                    }]];
                    [alert2 showWithViewController:self];
                }
                else
                {
                    
                }
            
                } fail:^(NSString *err) {
                    LOG(@"发送简历失败,err = %@",err);
                }];
            }]];
                [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
            }]];
                [alert showWithViewController:self];
        }
        } fail:^(NSString *err) {
               LOG(@"发送简历失败,err = %@",err);
        }];

    }
    else if ([workModel.applyWay isEqualToString:@"Way1"]
             ||[workModel.applyWay isEqualToString:@"Way2"]
             ||[workModel.applyWay isEqualToString:@"Way3"]
             ||[workModel.applyWay isEqualToString:@"Way4"]
             ||[workModel.applyWay isEqualToString:@"Way7"]){
    [self applyTheWorkAndCallTheCloudWithType:@"WantWork" success:^(id object) {
        _ResumeButton.enabled = YES;
        if ([[object objectForKey:@"Static"] isEqualToString:@"faile"]) {
            [SVProgressHUD showErrorWithStatus:[object objectForKey:@"Value"]];
        }else {
            if ([[object objectForKey:@"NextStep"] isEqualToString:@"NeedLogin"]) {
                [SVProgressHUD showErrorWithStatus:@"请先登录"];
            }else if ([[object objectForKey:@"NextStep"] isEqualToString:@"NO"]) {
                [SVProgressHUD showErrorWithStatus:[object objectForKey:@"Value"]];
            }else if ([[object objectForKey:@"NextStep"] isEqualToString:@"NeedResume"]) {
                [SVProgressHUD showErrorWithStatus:@"请先完善简历"];
            }else {
                
                HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"您可以采用以下方式联系报名" message:nil preferredStyle:HLAlertControllerStyleAlert];
                LOG(@"workModel.applyway = %@",workModel.applyWay);
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

                }else if ([workModel.applyWay isEqualToString:@"Way7"]) {
                    /**
                     *  json.put("Step", step);//点击报名按钮   传入  1
                     json.put("UserObjectId", userId);
                     json.put("WorkObjectId", workId);
                     json.put("CompanyUserObjectId", cuserId);
                     jsonObject.put("Type", "SelfWorkApply");
                     jsonObject.put("Version", "xxx");
                     jsonObject.put("CityObjectId", "xxxxx");
                     jsonObject.put("DeviceType", "android");
                     */
                    NSMutableDictionary *RegistDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @1,@"Step",
                                               bUser ? bUser.objectId : @"",kUserObjectId,
                                               workObjectId,kWorkObjectId,
                                               workModel.companyUserId,kCompanyUserObjectId,
                                               @"SelfWorkApply",kType,
                                               kCloudVersion,kVersion,
                                               [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],@"CityObjectId",
                                               @"ios",@"DeviceType",
                                               nil];
                    
                    NSMutableDictionary *RegistDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               @2,@"Step",
                                               bUser ? bUser.objectId : @"",kUserObjectId,
                                               workObjectId,kWorkObjectId,
                                               workModel.companyUserId,kCompanyUserObjectId,
                                               @"SelfWorkApply",kType,
                                               kCloudVersion,kVersion,
                                               [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"],@"CityObjectId",
                                               @"ios",@"DeviceType",
                                               nil];
                    if (!bUser) {
                        [self chackIsLoginAndAlert];
                    }

                    [CommonServers callCloudWithAPIName:kCloudInteractive andDic:RegistDic success:^(id object) {
                        
                        HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"确定要申请这个工作?" message:nil preferredStyle:HLAlertControllerStyleAlert];
                        [alert addAction:[HLAlertAction actionWithTitle:@"确定" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                            [self callInteractiveCloudWithDic:RegistDic2 success:^(NSDictionary *obj) {
                                if ([[obj objectForKey:@"NextStep"] isEqualToNumber:@3])
                                {
                                    
                                    [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"Ticp"]];
                                    //跳转到申请页传入workorderid
                                    NotificationViewController * notificationVC = [[NotificationViewController alloc]init];
                                    notificationVC.workObjectId = workObjectId;
                                    notificationVC.workOrderObjectId = [obj objectForKey:@"WorkOrderObjectId"];
                                    LOG(@"坑爹1 = %@",notificationVC.workOrderObjectId);
                                    [self setHidesBottomBarWhenPushed:YES];
                                    [self.navigationController pushViewController:notificationVC animated:YES];
                                    
                                }
                                else if ([[obj objectForKey:@"NextStep"] isEqualToNumber:@1])
                                {
                                    if ([[object objectForKey:@"ReturnType"]isEqualToString:@"NeedResume"]) {
                                        HLAlertController *alert2 = [HLAlertController alertControllerWithTitle:@"没有填写完整的简历" message:nil preferredStyle:HLAlertControllerStyleAlert];
                                        [alert2 addAction:[HLAlertAction actionWithTitle:@"前往修改" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                                            MyResumeViewController * myResumeVC = [[MyResumeViewController alloc]init];
                                            [self.navigationController pushViewController:myResumeVC animated:YES];
                                        }]];
                                        [alert2 showWithViewController:self];
                                    }
                                
                                    else if ([[object objectForKey:@"ReturnType"]isEqualToString:@"EnterWork"])
                                    {
                                        //跳转群聊页面，workorderid,groupID(查询群聊消息)
                                        [SVProgressHUD showInfoWithStatus:[object objectForKey:@"Value"]];
                                        
                                        [self jumpToGroupChat:[object objectForKey:@"GroupId"]];
                                        
                                    }
                                    else if ([[object objectForKey:@"ReturnType"]isEqualToString:@"EnterApplyingPage"])
                                    {
                                        HLAlertController *alert3 = [HLAlertController alertControllerWithTitle:[object objectForKey:@"Value"] message:nil preferredStyle:HLAlertControllerStyleAlert];
                                        [alert3 addAction:[HLAlertAction actionWithTitle:@"前往" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                                            NotificationViewController * notificationVC = [[NotificationViewController alloc]init];
                                            notificationVC.workObjectId = workObjectId;
                                            notificationVC.workOrderObjectId = [object objectForKey:@"WorkOrderObjectId"];
                                            [self setHidesBottomBarWhenPushed:YES];
                                            [self.navigationController pushViewController:notificationVC animated:YES];
                                        }]];
                                        [alert3 addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                                            
                                        }]];
                                        [alert3 showWithViewController:self];
                                        
                                    }
                                    else if ([[obj objectForKey:@"NextStep"] isEqualToNumber:@2])
                                    {
                                        
                                    }else {
                                        
                                    }
                                    
                                }
                                else
                                {
                                    //
                                }

                            } fail:^(NSString *err) {
                                LOG(@"way7Step2 err = %@",err);
                            }];
                        }]];
                        [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
                            
                        }]];
                        [alert showWithViewController:self];

                    } fail:^(NSString *reason) {
                        LOG(@"way7err = %@",reason);
                    }];
                    
                }else {
                    
                    [SVProgressHUD showInfoWithStatus:@"请留意最新版本功能"];
                }

            }
        }
    }];
    
    
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"请留意最新版本功能"];
    }
    _ResumeButton.enabled = YES;

}

- (void)callThePhone:(NSString *)phone {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *callWebview = [[UIWebView alloc] init];
        NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [self.view addSubview:callWebview];
        [self applyTheWorkAndCallTheCloudWithType:@"WorkCall" success:^(id object) {
            if (object) {
                [self getWorkDetail:nil];
            }
        }];
    });
}

- (void)applyTheWorkAndCallTheCloudWithType:(NSString *)type success:(void (^)(id object))block {
    /**
     *  {"Type":"WorkCall","Version":"3","UserObjectId":"3c018af4d1","WorkObjectId":"ea325573f2"}
     */
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          type, @"Type",
                          kCloudVersion, @"Version",
                          bUser.objectId, @"UserObjectId",
                          workModel.workObjectId, @"WorkObjectId",
                          nil];
    [CommonServers callCloudWithAPIName:kCloudInteractive andDic:dict success:^(id object) {
        block(object);
    } fail:^(NSString *reason) {
        
    }];
}

- (void)showTheCommentVC {
    _popCommentView = [AFPopupView popupWithView:_commentVC.view];
    _commentVC.commentList = workModel.commentList;
    _commentVC.workObjectId = workModel.workObjectId;
    [_popCommentView show];
}

- (void)hideTheCommentVC {
    [_popCommentView hide];
}

- (void)getWorkDetail:(id)sender {
    @try {
        NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(detailStopRefreshing) userInfo:nil repeats:NO];
        [self getWorkInfoWithDic:dic success:^(NSDictionary *obj){

            [timer invalidate];
            [SVProgressHUD showSuccessWithStatus:kRefreshedFinish];
            NSDictionary * dict = [[NSDictionary alloc]initWithDictionary:[obj objectForKey:@"Work"]];
            NSString * isPraise = [dict objectForKey:@"IsPraise"];
            if ([isPraise isEqualToString:@"1"]) {
                _praiseItem.tintColor = [UIColor colorWithRed:255/255.0 green:182/255.0 blue:193/255.0 alpha:1.0];
            }
            
            workModel = [WorkModel initWithDic:[obj objectForKey:@"Work"]];
            
            
            [self performSelectorOnMainThread:@selector(showInfoToView) withObject:workModel waitUntilDone:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"praiseCount" object:nil];
            [workPraise setObject:workModel.workObjectId forKey:kWorkObjectId];
            [workPraise setObject:bUser ? bUser.objectId : @"" forKey:kUserObjectId];
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

- (void)chackIsLoginAndAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去登录", nil];
    alertView.tag = 1001;
    [alertView show];
}

#pragma mark - Servers
/**
 *  云代码调用
 *
 *  @param inputDic 传入inputData
 *  @param success  返回成功字典
 *  @param fail     返回是字符串
 */
- (void)callInteractiveCloudWithDic:(NSMutableDictionary *)inputDic success:(void (^)(NSDictionary *obj))success fail:(void (^)(NSString *err))fail{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:inputDic forKey:@"inputData"];

    [BmobCloud callFunctionInBackground:kCloudInteractive withParameters:dict block:^(id obj, NSError *err){

        if (obj) {
            success(obj);
        }
        if (err) {
            fail(kNetworkWarning);
        }
    }];
}

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



//跳转至群聊界面
- (void)jumpToGroupChat:(NSString *)groupId{
    if (groupId == nil) {
        return;
    }
    //查找SelfWork表
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"SelfWork"];
    //查找SelfWork表里面id为groupId的数据
    [bquery includeKey:@"Work"];
    [bquery whereKey:@"GroupId" equalTo:groupId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            //进行错误处理
        }else{
            //表里有id为groupId的数据
            BmobObject *aSelfWork = array.firstObject;
            if (aSelfWork) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                NSString *updatedAtString = [dateFormatter stringFromDate:aSelfWork.updatedAt];
                NSDictionary *aSelfWorkDic = @{
                                               @"GroupId":[aSelfWork objectForKey:@"GroupId"],
                                               @"GroupOwnerId":[aSelfWork objectForKey:@"GroupOwnerId"],
                                               @"updatedAt":updatedAtString,
                                               @"Notice":[aSelfWork objectForKey:@"Notice"]
                                               };
                NSDictionary *workDic = [aSelfWork objectForKey:@"Work"];
                DirectAcceptedDetailViewController *dadvc = [[DirectAcceptedDetailViewController alloc]init];
                dadvc.workTitle         = [workDic objectForKey:@"Title"];
                dadvc.selfWorkDic       = aSelfWorkDic;
                
                dadvc.workObjectId      = [workDic objectForKey:@"objectId"];
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:dadvc animated:YES];
            }
        }
    }];
}

@end
