//
//  LoginViewController.m
//  duangongbang
//
//  Created by 123 on 15/4/28.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "LoginViewController.h"
#import "ChooseLabelViewController.h"
#import "DGBTabBarViewController.h"
#import "AppDelegate.h"
#import "CityLocationViewController.h"
#import "VisitorChooseViewController.h"
#import "ChooseLabelViewController.h"
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"
#import "RegX.h"
#import "RegistViewController.h"
#import "LJWKeyboardHandlerHeaders.h"
#import "ForgotPSAndResetViewController.h"
#import "TOWebViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "NSString+Hash.h"

#define Ver_Num_Lenght 6
#define PleaceInputARightPhoneNum @"请输入正确的手机号码"
#define VerWrong @"验证失败，请检查验证码是否正确再次填写或重新获取"

@interface LoginViewController ()<UITextFieldDelegate>{
    BmobUser *bUser;
    
    BOOL justRegist;
    BOOL justForgot;
    BOOL flag;
    int requestVerNum;
    
    __weak IBOutlet UIImageView *_imageViewBackground;
    __weak IBOutlet UIButton *_btnLogin;
    
    __weak IBOutlet UIButton *_btnRegistVer;
    __weak IBOutlet UIButton *_btnForgotVer;
    
    __weak IBOutlet UIButton *_btnLoginTab;
    __weak IBOutlet UIButton *_btnRegistTab;
    __weak IBOutlet UIButton *_btnForgotTab;
    
    __weak IBOutlet UIButton *_btnForgotNextStep;
    
    __weak IBOutlet UIButton *_btnUserItem;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentLineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLineWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stateLineLeftEdge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroupImgLeftEdge;

@property (strong, nonatomic) IBOutlet UIView *viewLRFView;

@property (weak, nonatomic) IBOutlet UIView *viewLoginView;

@property (weak, nonatomic) IBOutlet UIView *viewRegistView;

@property (weak, nonatomic) IBOutlet UIView *viewForgotView;


@property (weak, nonatomic) IBOutlet PagingScrollView *mainScrollView;

@property (weak, nonatomic) IBOutlet UITextField *tfLoginPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfLoginPassWord;

@property (weak, nonatomic) IBOutlet UITextField *tfRegistPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfRegistVer;

@property (weak, nonatomic) IBOutlet UITextField *tfForgotPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfForgotVer;
@property (weak, nonatomic) IBOutlet UIButton *btnRegist;
@property (weak, nonatomic) IBOutlet UILabel *lbStateLine;

@end

@implementation LoginViewController
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    bUser = [ShareDataSource sharedDataSource].myData;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self registerLJWKeyboardHandler];

    //  UI设置
    
    _imageViewBackground.clipsToBounds = YES;
    
    [_tfLoginPhone addTarget:self action:@selector(chackTextLength:) forControlEvents:UIControlEventEditingChanged];
    [_tfRegistPhone addTarget:self action:@selector(chackTextLength:) forControlEvents:UIControlEventEditingChanged];
    [_tfForgotPhone addTarget:self action:@selector(chackTextLength:) forControlEvents:UIControlEventEditingChanged];
    
    [_btnLogin setImage:[UIImage imageNamed:@"LoginICON"] forState:UIControlStateNormal];
    [_btnLogin setTintColor:[UIColor whiteColor]];
    
    [_btnLogin addTarget: self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRegist addTarget:self action:@selector(registNextStep:) forControlEvents:UIControlEventTouchUpInside];
    [_btnForgotNextStep addTarget:self action:@selector(forgorNextStep:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRegistVer addTarget:self action:@selector(registSendVer:) forControlEvents:UIControlEventTouchUpInside];
    [_btnForgotVer addTarget:self action:@selector(forgotSendVer:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnUserItem addTarget:self action:@selector(showTheUserItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToForgotAndResetPassword:) name:KEY_KVO_SCROLL_TO_RESET_PASSWORD object:nil];
    
    [self setAllViewFrameAndStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(PagingScrollView *)scrollView{
    //  定位线根据视图滑动改变位置
    if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x < (mainScreenWidth - 48) * 2){
        _stateLineLeftEdge.constant = scrollView.contentOffset.x * (((mainScreenWidth - 64)/3)/(mainScreenWidth - 48)) + 32;
        _backgroupImgLeftEdge.constant = -scrollView.contentOffset.x / mainScreenWidth * 100;
    }
}

#pragma mark - TextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
//{
//    
//    if ([string isEqualToString:@"\n"])  //按会车可以改变
//        
//    {
//        return YES;
//    }
//    
//    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
//    if (_txfPhone == textField)
//    {
//        
//        if ([toBeString length] > 11) { //如果输入框内容大于11则弹出警告
//            
//            textField.text = [toBeString substringToIndex:11];
//            
//            return NO;
//            
//        }
//        
//    }
//    
//    return YES;
//    
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    
//    NSString * toBeString = textField.text;
//    if (_txfPhone == textField)
//    {
//        
//        if ([toBeString length] > 11) {
//            
//            textField.text = [toBeString substringToIndex:11];
//            
//        }
//        
//    }
//}

-(void)chackTextLength:(UITextField *)textField{
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        if (textField.text.length>11) {
            textField.text = [textField.text substringToIndex:11];
        }
    });
}

/**
 *  设置所有UI
 */
- (void)setAllViewFrameAndStyle{
    _segmentLineHeight.constant = 0.5f;
    
    //_viewLRFView.frame = CGRectMake(0, 0, mainScreenWidth * 3 - 96, _mainScrollView.frame.size.height);
    
    _viewLRFView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _mainScrollView.pageWidth = mainScreenWidth - 48;
    [_mainScrollView addSubview:_viewLRFView];
    
    NSString *vLRFView = [NSString stringWithFormat:@"V:|-0-[_viewLRFView(%f)]-0-|",mainScreenWidth * 272/320];
    NSString *hLRFView = [NSString stringWithFormat:@"H:|-0-[_viewLRFView(%f)]-0-|",mainScreenWidth * 3 - 96];
    
    NSArray *constraintsMainView_H = [NSLayoutConstraint constraintsWithVisualFormat:hLRFView options:0 metrics:nil views:NSDictionaryOfVariableBindings(_viewLRFView)];
    
    NSArray *constraintsMainView_V = [NSLayoutConstraint constraintsWithVisualFormat:vLRFView options:0 metrics:nil views:NSDictionaryOfVariableBindings(_viewLRFView)];
    
    [_mainScrollView addConstraints:constraintsMainView_H];
    [_mainScrollView addConstraints:constraintsMainView_V];
    
    _mainScrollView.contentSize = CGSizeMake(mainScreenWidth * 3 - 96, _mainScrollView.frame.size.height);
    
    _mainScrollView.aDelegate = self;
//    LOG(@"%@",_mainScrollView);
//    LOG(@"before%f----%f",_stateLineLeftEdge.constant,_stateLineWidth.constant);
//    LOG(@"after%f",_stateLineLeftEdge.constant);
    
    _tfLoginPhone = [self setTextFieldStyleWithTXF:_tfLoginPhone];
    _tfLoginPassWord = [self setTextFieldStyleWithTXF:_tfLoginPassWord];
    _tfRegistPhone = [self setTextFieldStyleWithTXF:_tfRegistPhone];
    _tfRegistVer = [self setTextFieldStyleWithTXF:_tfRegistVer];
    _tfForgotPhone = [self setTextFieldStyleWithTXF:_tfForgotPhone];
    _tfForgotVer = [self setTextFieldStyleWithTXF:_tfForgotVer];
    
    [self setViewShadowWithView:_viewLoginView];
    [self setViewShadowWithView:_viewRegistView];
    [self setViewShadowWithView:_viewForgotView];
    
    [_btnLoginTab addTarget:self action:@selector(selectTabAnScroll:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRegistTab addTarget:self action:@selector(selectTabAnScroll:) forControlEvents:UIControlEventTouchUpInside];
    [_btnForgotTab addTarget:self action:@selector(selectTabAnScroll:) forControlEvents:UIControlEventTouchUpInside];
}
/**
 *  设置子视图的阴影
 *
 *  @param view 目标视图
 */
- (void)setViewShadowWithView:(UIView *)view{
    view.layer.masksToBounds = NO;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowRadius = 0.0f;
    view.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowPath = shadowPath.CGPath;
}
- (void)changeStateLineWithFrame:(CGRect)sender{
    
    _lbStateLine.frame = sender;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - method


- (void)stopLogin{
    [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
    
}
/**
 *  更改txf样式（边距、边框）
 *
 *  @param textField UITextField
 *
 *  @return UITextField
 */
- (UITextField *)setTextFieldStyleWithTXF:(UITextField *)textField{
    
    UITextField *txf = textField;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 20)];
    txf.leftView = paddingView;
    txf.leftViewMode = UITextFieldViewModeAlways;
    txf.layer.borderColor = UIColorFromRGB(0xb5b5b5).CGColor;
    
    txf.layer.borderWidth = 0.5f;
    txf.layer.masksToBounds = YES;
    return txf;
}

- (void)countDownWithTime:(int)time
           countDownBlock:(void (^)(int timeLeft))countDownBlock
                 endBlock:(void (^)())endBlock{
    __block int timeout = time; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (endBlock) {
                    endBlock();
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                timeout--;
                if (countDownBlock) {
                    countDownBlock(timeout);
                }
            });
        }
    });
    dispatch_resume(_timer);
}

- (void)startCountWhenClickVerRequest{
    [self countDownWithTime:60 countDownBlock:^(int timeLeft) {
        int seconds = timeLeft % 60;
        NSString *strTime = [[NSString stringWithFormat:@"%.2ds",seconds] copy];
        _btnForgotVer.titleLabel.text = strTime;
        [_btnForgotVer setTitle:strTime forState:UIControlStateNormal];
        _btnRegistVer.titleLabel.text = strTime;
        [_btnRegistVer setTitle:strTime forState:UIControlStateNormal];
        _btnRegistVer.enabled = NO;
        _btnForgotVer.enabled = NO;
    } endBlock:^(void){
        _btnForgotVer.titleLabel.text = @"验证码";
        [_btnForgotVer setTitle:@"验证码" forState:UIControlStateNormal];
        _btnRegistVer.titleLabel.text = @"验证码";
        [_btnRegistVer setTitle:@"验证码" forState:UIControlStateNormal];
        _btnRegistVer.enabled = YES;
        _btnForgotVer.enabled = YES;
    }];
}

#pragma mark - button
- (void)showTheUserItem:(id)sender {
    TOWebViewController *webView = [[TOWebViewController alloc ] initWithURL:[NSURL URLWithString:kUserItem]];
    webView.webViewStyle = ToWebViewOnlyWeb;
    webView.navigationButtonsHidden = YES;
    [self.navigationController pushViewController:webView animated:YES];

}

- (void)registSendVer:(id)sender {
    if (![_tfRegistPhone.text isEqualToString:@""]) {
        if ([RegX validateMobile:_tfRegistPhone.text]) {
            
            BmobQuery *bquery = [BmobQuery queryForUser];
            [bquery whereKey:@"username" equalTo:_tfRegistPhone.text];
            [bquery countObjectsInBackgroundWithBlock:^(int number, NSError *err){
                if (err) {
                    [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
                }else{
                    if (number == 0) {
                        [SVProgressHUD show];
                        justRegist = YES;
                        [self startCountWhenClickVerRequest];
                        [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:_tfRegistPhone.text andTemplate:nil resultBlock:^(int number, NSError *err){
                            
                            if (err) {
                                LOG(@"bmobSMSrequestErr:%@",err);
                            }else{
                                [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
                                requestVerNum = number;
                            }
                            
                        }];
                        
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"该手机号已被注册~"];
                    }
                }
            }];
            
        }else{
            [SVProgressHUD showErrorWithStatus:PleaceInputARightPhoneNum];
            return;
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"手机号码不能为空"];
        return;
    }
    
}
- (void)forgotSendVer:(id)sender {
    if (![_tfForgotPhone.text isEqualToString:@""]) {
        if ([RegX validateMobile:_tfForgotPhone.text]) {
            
            BmobQuery *bquery = [BmobQuery queryForUser];
            [bquery whereKey:@"username" equalTo:_tfForgotPhone.text];
            [bquery countObjectsInBackgroundWithBlock:^(int number, NSError *err){
                if (err) {
                    [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
                }else{
                    if (number > 0) {
                        [SVProgressHUD show];
                        justRegist = YES;
                        [self startCountWhenClickVerRequest];
                        [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:_tfForgotPhone.text andTemplate:nil resultBlock:^(int number, NSError *err){
                            
                            if (err) {
                                LOG(@"bmobSMSrequestErr:%@",err);
                            }else{
                                [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
                                requestVerNum = number;
                            }
                            
                        }];
                        
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"该手机号未注册~"];
                    }
                }
            }];
            
        }else{
            [SVProgressHUD showErrorWithStatus:PleaceInputARightPhoneNum];
            return;
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"手机号码不能为空"];
        return;
    }
}

- (void)selectTabAnScroll:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            break;
        case 1:
            [_mainScrollView setContentOffset:CGPointMake(mainScreenWidth - 48.0, 0) animated:YES];
            break;
        case 2:
            [_mainScrollView setContentOffset:CGPointMake((mainScreenWidth - 48.0) * 2, 0) animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)touchBackView:(id)sender {
    
    FIRST_RESPONDER;
    
}

- (IBAction)btnHaveLook:(id)sender {
    if ([[USER_DEFAULT objectForKey:MY_CITY_KEY] isKindOfClass:[NSDictionary
                                                                class
                                                                ]]) {
        if ([USER_DEFAULT boolForKey:kIsCustom]) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
            }];
            return;
        }
        VisitorChooseViewController *visitorVC = [[VisitorChooseViewController alloc] init];
        visitorVC.thisViewIsPush = YES;
        [self.navigationController pushViewController:visitorVC animated:YES];
    }else{
        CityLocationViewController *cityVC = [[CityLocationViewController alloc] init];
        [self.navigationController pushViewController:cityVC animated:YES];
    }
}
- (void)registNextStep:(id)sender{
    
    if ([_tfRegistPhone.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不能为空"];
        return;
    }
    if ([self checkTheNetWorking]) {
        return;
    }
    [SVProgressHUD setStatus:@"验证中..."];
    //验证
    [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:_tfRegistPhone.text andSMSCode:_tfRegistVer.text resultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            
            [USER_DEFAULT setObject:_tfRegistPhone.text forKey:USER_PHONE];
            [USER_DEFAULT synchronize];
            
            CityLocationViewController *cityVC = [[CityLocationViewController alloc] initWithNibName:@"CityLocationViewController" bundle:nil];
            cityVC.beforeRigistView = YES;
            
            [self.navigationController pushViewController:cityVC animated:YES];
            
        } else {
            [SVProgressHUD showErrorWithStatus:VerWrong];
        }
    }];
}

- (void)forgorNextStep:(id)sender {
    if ([_tfForgotPhone.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"手机号码不能为空"];
    }
    if ([self checkTheNetWorking]) {
        return;
    }
    [SVProgressHUD setStatus:@"验证中..."];
    //验证
    [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:_tfForgotPhone.text andSMSCode:_tfForgotVer.text resultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            ForgotPSAndResetViewController *forgotVC = [[ForgotPSAndResetViewController alloc] initWithNibName:@"ForgotPSAndResetViewController" bundle:nil];
            forgotVC.phone = _tfForgotPhone.text;
            [USER_DEFAULT setObject:_tfForgotPhone.text forKey:USER_PHONE];
            [USER_DEFAULT synchronize];
            [self.navigationController pushViewController:forgotVC animated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:VerWrong];
        }
    }];
}

- (void)loginAction:(id)sender{
    FIRST_RESPONDER;
    if ([_tfLoginPhone.text isEqualToString:@""] && [_tfLoginPhone.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入用户名或密码"];
        return;
    }
    if ([RegX validateMobile:_tfLoginPhone.text]) {
        
        if ([self checkTheNetWorking]) {
            return;
        }
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopLogin) userInfo:nil repeats:NO];
        
        [SVProgressHUD showWithStatus:@"登录中"];
        
        [BmobUser loginWithUsernameInBackground:_tfLoginPhone.text password:_tfLoginPassWord.text block:^(BmobUser *user, NSError *err){
            [timer invalidate];
            if (user) {
                [SVProgressHUD showSuccessWithStatus:@"成功登录"];
                [ShareDataSource sharedDataSource].myData = user;
               
                
                if ([[USER_DEFAULT objectForKey:MY_CITY_KEY] isKindOfClass:[NSDictionary class]]) {
                    if ([USER_DEFAULT boolForKey:kIsCustom]) {
                         flag = YES;
                        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatLogin) userInfo:nil repeats:NO];
                        [self dismissViewControllerAnimated:YES completion:^{
                            flag = NO;
                            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
                        }];
                        
                    }else {
                        ChooseLabelViewController *chooseVC = [[ChooseLabelViewController alloc] init];
                        chooseVC.thisViewIsPush = YES;
                        [self.navigationController pushViewController:chooseVC animated:YES];
                    }
                }else{
                    CityLocationViewController *cityVC = [[CityLocationViewController alloc] init];
                    [self.navigationController pushViewController:cityVC animated:YES];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:@"用户名或密码不正确"];
            }
        }];
    }else{
        [SVProgressHUD showErrorWithStatus:PleaceInputARightPhoneNum];
    }
}

- (void)repeatLogin
{
    if (flag) {
        [self dismissViewControllerAnimated:YES completion:nil];
        DGBTabBarViewController *main = [[DGBTabBarViewController alloc] init];
        [self presentViewController:main animated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
        }];
    }
}

- (BOOL)checkTheNetWorking {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
        return YES;
    }else {
        
        return NO;
    }
}

#pragma mark - KVO
- (void)scrollToForgotAndResetPassword:(NSNotification *)notification {
    [_mainScrollView setContentOffset:CGPointMake((mainScreenWidth - 64) * 2, 0) animated:YES];
}

@end
