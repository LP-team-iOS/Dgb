//
//  MYViewController.m
//  duangongbang
//
//  Created by chen on 15/11/2.
//  Copyright © 2015年 duangongbang. All rights reserved.
//


#import "MYViewController.h"
#import "DGBListViewController.h"
#import "MyResumeViewController.h"
#import "TOWebViewController.h"
#import "LoginViewController.h"


#import "MYTableViewCell.h"
#import "UserCenterInfo.h"
#import "ShareDataSource.h"

#import <QuartzCore/QuartzCore.h>

//照片捕捉相关类
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "VPImageCropperViewController.h"


#import "UIImage+ImageEffects.h"
#import "UIImageView+WebCache.h"


#import "SVProgressHUD.h"


#define ORIGINAL_MAX_WIDTH 640.0f

#define kCornerRadii 4

typedef enum : NSUInteger {
    MYInfoView = 00,
    MYCollectionView = 01,
    MYModifyPsw = 10,
//    MYFeedBack = 11,
    MYUserTerms = 11,
    MYUserHelp = 12,
    MYAboutUs = 13,
    // MYUpdate = 20,
    MYLogOut = 20,
} SecondView;

@interface MYViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,VPImageCropperDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>
{
    NSDictionary *_dic;
    __strong UserCenterInfo *_userCenterInfo;
}



@property (nonatomic, assign) BOOL nibRegistered;
@property (nonatomic, strong) NSArray *personStrings;
@property (nonatomic, strong) NSArray *enterpriseStrings;
@property (nonatomic, strong) NSArray *personStringsLogOut;
@property (nonatomic, strong) NSArray *enterpriseStringsLogOut;

@property (nonatomic, assign) BOOL personMode;
@property (nonatomic, strong) NSArray *currentArray;

//程序共有的数据：例如和程序共生死的单例，工厂类，建造类


@end

@implementation MYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self loginAndLoadUserInfo:nil];
    // Do any additional setup after loading the view from its nib.
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    [self setHidesBottomBarWhenPushed:NO];
    //被踢下线后，注销原界面的账户信息
    if ([ShareDataSource sharedDataSource].myData == nil) {
        [BmobUser logout];
        [USER_DEFAULT setObject:@"" forKey:kMyInfoKey];
        [ShareDataSource sharedDataSource].myData = nil;
        _currentArray = _personMode? _personStringsLogOut:_enterpriseStringsLogOut;
        [_mainTableView reloadData];
        _nameLabel.text = @"";

        _userHeadImageView.image = [UIImage imageNamed:@"Head_Image.png"];
        UIImage *image = _userHeadImageView.image;
        UIImage *blurImg =nil;
        blurImg = [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];
        _blurImage.image = blurImg;

    }

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark - uitableviewdatasources
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 14)];
    view.backgroundColor = RGB(243, 243, 243, 1);
    return view;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == _currentArray.count - 1) {
        return [[UIView alloc]initWithFrame:CGRectZero];
    }
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    
    view.backgroundColor = RGB(243, 243, 243, 1);
    return view;
}


- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _currentArray.count;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray *)_currentArray[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    static NSString *simpleIdentify = @"jobCell";
    _nibRegistered = NO;
    //    if (!_nibRegistered) {
    //        _nibRegistered = YES;
    //
    //        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:simpleIdentify];
    //    }
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MYTableViewCell class]) owner:nil options:nil];
    MYTableViewCell *nib = views.firstObject;
    nib.bounds = CGRectMake(0, 0, _mainTableView.frame.size.width, 54);
    NSAssert(nib, @"不能创建cell");
    NSString *imageName = ((NSArray *)_currentArray[indexPath.section])[indexPath.row];
    
    if ([imageName isEqualToString:@"检查更新"]) {
        nib.myButton.enabled = NO;
        nib.myButton.hidden = NO;
        [nib.myButton setTitle:@"version 3.2" forState:UIControlStateNormal];
        
        //        nib.version s
        //...
    }else if([imageName isEqualToString:@"商家信息"]){
        nib.myButton.hidden = NO;
        [nib.myButton setTitle:@"未认证 >" forState:UIControlStateNormal];
    }
    UIFont *aFont = [UIFont fontWithName:kFontName size:9];
    [nib.myButton.titleLabel setFont:aFont];
    
    UIFont *font = [UIFont fontWithName:kFontName size:12];
    
    nib.myImageView.image = [UIImage imageNamed:imageName];
    NSAssert(font, @"找不到字体");
    [nib.myTextLabel setFont:font];
    nib.myTextLabel.text = imageName;
    
    NSArray *arr = (NSArray *)_currentArray.lastObject;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [nib setRoundingCornersByRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(kCornerRadii, kCornerRadii)];
        [nib setRoundingCornersByRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(kCornerRadii, kCornerRadii)];
        
    };
    
    if (indexPath.section == (_currentArray.count-1) && indexPath.row == (arr.count - 1)){
        [nib setRoundingCornersByRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(4, 4)];
    }
    
    //    NSAssert(nib.imageView.image, @"不能正确找到png图标");
    nib.selectionStyle = UITableViewCellSelectionStyleNone;
    return nib;
    
}

#pragma mark - uitableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self setHidesBottomBarWhenPushed:YES];
    
    [_mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    DGBListViewController *dgbListVC;
    TOWebViewController *webViewController;
    if (_personMode) {
        //        NSString *selectedRowString = (NSArray *)_personStrings[indexPath.section][indexPath.row];
        NSUInteger choice = indexPath.section * 10 + indexPath.row;
        switch (choice) {
                
            case MYInfoView:{
                if (![BmobUser getCurrentUser]) {
                    [self chackIsLoginAndAlert];
                    return;
                }
                MyResumeViewController *myResumeVC = [[MyResumeViewController alloc] initWithNibName:@"MyResumeViewController" bundle:nil];
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:myResumeVC animated:YES];
                
            }
                break;
            case MYCollectionView:
                if (![BmobUser getCurrentUser]) {
                    [self chackIsLoginAndAlert];
                    return;
                }
                dgbListVC = [[DGBListViewController alloc] initWithNibName:@"DGBListViewController" bundle:nil];
                dgbListVC.listStates = UITableViewListCollections;
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:dgbListVC animated:YES];
                break;
            case MYLogOut:{
                [self signOut];
            }
                break;
                //修改密码
            case MYModifyPsw:{
                if (![BmobUser getCurrentUser]) {
                    //                    [self chackIsLoginAndAlert];
                    [self goToModifyPsw];
                }else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"将跳转到登录页，确定注销吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alert.tag = 7001;
                    [alert show];
                }
                
            }
                break;
                //清除缓存
                //            case 2:{
                //                NSString *string = [NSString stringWithFormat:@"缓存大小为%.2fMB，确定要清理缓存吗？",[self calculateAllCache]];
                //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                //                [alertView setTag:1002];
                //                [alertView show];
                //            }
                //                break;
            case MYUserHelp://用户帮助
                webViewController = [[TOWebViewController alloc] initWithURLString:kUserHelper];
                webViewController.navigationButtonsHidden = YES;
                webViewController.webViewStyle = ToWebViewOnlyWeb;
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:webViewController animated:YES];
                break;
            case MYUserTerms://用户条款
                LOG(@"用户条款");
                webViewController = [[TOWebViewController alloc] initWithURLString:kUserItem];
                webViewController.navigationButtonsHidden = YES;
                webViewController.webViewStyle = ToWebViewOnlyWeb;
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:webViewController animated:YES];
                break;
            case MYAboutUs://关于我们
                webViewController = [[TOWebViewController alloc] initWithURLString:kAboutUs];
                webViewController.navigationButtonsHidden = YES;
                webViewController.webViewStyle = ToWebViewOnlyWeb;
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:webViewController animated:YES];
                break;
                
            default:
                break;
        }
    }
//        [self setHidesBottomBarWhenPushed:NO];
    
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"相机权限受限" message:@"请前往设置将短工邦相机权限打开" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 LOG(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 LOG(@"Picker View Controller is presented");
                             }];
        }
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case 7000:
            if (buttonIndex == 1) {
                [self gotoLoginUp];
            }
            break;
            //修改密码
        case 7001:{
            if (buttonIndex == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([ShareDataSource sharedDataSource].myData) {
                        
                        [BmobUser logout];
                        [USER_DEFAULT setObject:@"" forKey:kMyInfoKey];
                        [ShareDataSource sharedDataSource].myData = nil;
                        _currentArray = _personMode? _personStringsLogOut:_enterpriseStringsLogOut;
                        [_mainTableView reloadData];
                        _nameLabel.text = @"";
                        
                        _userHeadImageView.image = [UIImage imageNamed:@"Head_Image.png"];
                        UIImage *image = _userHeadImageView.image;
                        UIImage *blurImg =nil;
                        blurImg = [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];
                        _blurImage.image = blurImg;
                    }
                    [self goToModifyPsw];
                });
            }
        }
            break;
        default:
            break;
    }
}

- (void)configTableView
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    //    _mainTableView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0);
}

#pragma mark - congigure

- (void)config
{
    
    _userHeadImageView.layer.cornerRadius = 55.5f;
    [_userHeadImageView.layer setMasksToBounds:YES];
    
    /**
     * 有nsarray 保存文本，再导入到nsdic，在显示到cell上。
     */
    //        [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _mainTableView.layer.cornerRadius = 2;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    UIImage *image = [UIImage imageNamed:@"Head_Image"];
    //    UIImage *maskimage = [UIImage imageNamed:@"渐变叠加"];
    [_blurImage setImage:[image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil]];
    [_userHeadImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeadImg:)];
    [_userHeadImageView addGestureRecognizer:tap];
    
    _personStrings = @[@[@"我的信息", @"我的收藏"],
                       @[@"修改密码", @"用户条款", @"用户帮助", @"关于我们"],
                       @[@"注销帐号"]];
    _personStringsLogOut = @[@[@"我的信息", @"我的收藏"],
                             @[@"修改密码", @"用户条款", @"用户帮助", @"关于我们"],
                             @[@"登录帐号"]];
    
    _enterpriseStrings = @[@[@"商家信息"],
                           @[@"我要求职"],
                           @[@"修改密码", @"用户条款", @"用户帮助", @"关于我们"],
                           @[@"注销帐号"]];
    
    _enterpriseStringsLogOut = @[@[@"商家信息"],
                                 @[@"我要求职"],
                                 @[@"修改密码", @"用户条款", @"用户帮助", @"关于我们"],
                                 @[@"登录帐号"]];
    
    UIImage *aImage = [UIImage imageNamed:@"我的信息"];
    NSAssert((aImage != nil), @"测试不通过");
    
    _personMode = YES;
    if (_personMode) {
        _vImage.hidden = YES;
        _currentArray = [BmobUser getCurrentUser]? _personStrings:_personStringsLogOut;
    }else{
        _labelCenterCons.constant = _vImage.frame.size.width/2.0;
        _currentArray = [BmobUser getCurrentUser]? _enterpriseStrings:_enterpriseStringsLogOut;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAndLoadUserInfo:) name:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
    
    [_nameLabel setFont:[UIFont fontWithName:kFontName size:15]];
    
}

#pragma mark - methods

/**
 *  登录成功后调用此方法。这里是下载用户头像和其他个人信息。
 *
 *  @param object
 */
- (void)loginAndLoadUserInfo:(id)object{
    BmobUser *bUser = [BmobUser getCurrentUser];
    if ( bUser) {
        _currentArray = _personMode? _personStrings:_enterpriseStrings;
        [_mainTableView reloadData];
        //{"Type":"GetResume","Version":"3","UserObjectId":"dc05b02b67"}
        _dic = [NSDictionary dictionaryWithObjectsAndKeys:@"GetResume", @"Type", kCloudVersion, @"Version",  bUser ?  bUser.objectId : @"" ,@"UserObjectId", nil];
        [CommonServers callAccountWithDict:_dic success:^(NSDictionary *obj){
            if (obj) {
                
                [USER_DEFAULT setObject:obj forKey:kMyInfoKey];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    _userCenterInfo = [UserCenterInfo initWithObject:obj];
                    
                    [self showUserInfo:_userCenterInfo];
                });
            }
            
        }fail:^(NSString *err){
            [SVProgressHUD showErrorWithStatus:err];
        }];
    }
}

- (void)showUserInfo:(UserCenterInfo *)object{
    @try {
        [_userHeadImageView sd_setImageWithURL:[NSURL URLWithString:object.headImgUrl] placeholderImage:[UIImage imageNamed:@"Head_Image.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            UIImage *img = image;
            UIImage *blurImage =nil;
            blurImage = [img applyBlurWithRadius:8 tintColor:[UIColor colorWithWhite:0.3 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
            _blurImage.image = blurImage;
        }];
        
        self.nameLabel.text = object.nickName;
        
        //        NSMutableAttributedString *strLevel = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"LV%@",object.lv]];
        //
        //        [strLevel addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontName size:12.0] range:NSMakeRange(0, 2)];
        //        [strLevel addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontName size:24.0] range:NSMakeRange(2, strLevel.length - 2)];
        //        _lbLevel.attributedText = strLevel;
        
    }
    @catch (NSException *exception) {
        [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
    }
    @finally {
        
    }
}


/**
 *  1.如果未登录则直接[self gotoLoginUp]，已登录则询问是否注销,用户选择注销便[self gotoLoginUp]
 2.应用了delegate
 3.这里和修改密码的业务不同，修改密码也需要注销。
 
 */
- (void)signOut{
    if ([BmobUser getCurrentUser]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定注销吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 7000;
        [alert show];
    }else{
        [self gotoLoginUp];
    }
    
    //    [self.navigationController pushViewController:logVC animated:YES];
    
}

- (void)gotoLoginUp{
    
    if ([ShareDataSource sharedDataSource].myData) {
        [BmobUser logout];
        [USER_DEFAULT setObject:@"" forKey:kMyInfoKey];
        [ShareDataSource sharedDataSource].myData = nil;
        _currentArray = _personMode? _personStringsLogOut:_enterpriseStringsLogOut;
        [_mainTableView reloadData];
        _nameLabel.text = @"";
        
        _userHeadImageView.image = [UIImage imageNamed:@"Head_Image.png"];
        UIImage *image = _userHeadImageView.image;
        UIImage *blurImg =nil;
        blurImg = [image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];
        _blurImage.image = blurImg;
        
    }
    UINavigationController *nav = [[UINavigationController alloc] init];
    LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [nav pushViewController:logVC animated:NO];
    [self.tabBarController presentViewController:nav animated:YES completion:^{
        //        [settingView removeFromSuperview];
    }];
}


- (void)chackIsLoginAndAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去登录", nil];
    alertView.tag = 7000;
    [alertView show];
}

- (void)goToModifyPsw{
    UINavigationController *nav = [[UINavigationController alloc] init];
    LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [nav pushViewController:logVC animated:NO];
    
    [self.tabBarController presentViewController:nav animated:YES completion:^{
        //                        [settingView removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_SCROLL_TO_RESET_PASSWORD object:nil];
    }];

}

- (void)changeHeadImg:(UITapGestureRecognizer *)sender{
    if (![BmobUser getCurrentUser]) {
        [self chackIsLoginAndAlert];
        return;
    }
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}



#pragma mark - camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    NSData *imageHead = UIImageJPEGRepresentation(editedImage, 0.1);
    
    BmobFile *headImageFile = [[BmobFile alloc] initWithFileName:@"crop_head_img.jpg" withFileData:imageHead];
    
    [SVProgressHUD showWithStatus:@"头像上传中"];
    
    [headImageFile saveInBackground:^(BOOL isSuccessful, NSError *error){
        if (isSuccessful) {
            
            //{"Type":"UpdateUserHeadImg","Version":"3","UserObject":"3c018af4d1","HeadImgURL":"M01/9D/A2/oYYBAFVfGW2ADYFKAACjPkhqO_8558.jpg"}
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"UpdateUserHeadImg", @"Type", kCloudVersion, @"Version", [BmobUser getCurrentUser].objectId, @"UserObjectId", headImageFile.url, @"HeadImgURL", nil];
            
            [CommonServers callAccountWithDict:dict success:^(NSDictionary *obj){
                if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                        _userHeadImageView.image = editedImage;
                        _blurImage.image = [editedImage applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.7] saturationDeltaFactor:1.8 maskImage:nil];
                    });
                }else{
                    [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
                }
            }fail:^(NSString *err){
                [SVProgressHUD showErrorWithStatus:err];
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
        }
    }withProgressBlock:^(float progress){
        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"头像上传中...%d%%",(int)(progress*100.0)] maskType:SVProgressHUDMaskTypeBlack];
    }];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}



#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}


#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) LOG(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}



- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
}
@end

/**
 *  扩展类功能时可能需要知道的
 1.用[BmobUser getCurrentUser]判断是否已登录，nil为未登录
 2.                        NSObject *a = [ShareDataSource sharedDataSource].myData;
 NSObject *b = [BmobUser getCurrentUser];
 这两个对象不是同一个对象，但其包含的信息相同，例如手机号。
 */

