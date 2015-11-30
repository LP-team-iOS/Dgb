//
//  MyResumeViewController.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/7/23.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "MyResumeViewController.h"
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobFile.h>
#import "UIImageView+WebCache.h"
#import "CommonServers.h"
#import "LJWKeyboardHandlerHeaders.h"
#import "UIView+Border.h"
#import "SVProgressHUD.h"
#import "SchoolViewController.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

/**
 *  {"Static":"success","Value":"没有传入数据","SchoolName":"惠州学院","SchoolObjectId":"bPx3999X","Email":"343024262@qq.com","Address":"惠州学院","HeadImgURL":"http://file.bmob.cn/M01/8D/86/oYYBAFW014SACRtjAACTm35tivc506.jpg","Intro":"我就是我","WorkExp":"","AreaName":"惠城区","AreaObjectId":"yAq6111J","VIP":"-1","Sex":"男","Age":99,"Height":188,"Phone":"18824865098","Nickname":"小妞","Name":"短工邦技术客服","Lv":"2","UserStatic":["companyBasicResume","basicResume","companyAuthentication"],"CityObjectId":"Cbqr444B","CityName":"惠州市","Custom":{"Classifies":["DQFtYSSn","hFL7433j","txSmRBBD"],"FreeDays":[0]}}
 */
#define kResumeSchoolName @"SchoolName"
#define kResumeSchoolObjectId @"SchoolObjectId"
#define kResumeEmail @"Email"
#define kResumeAdddress @"Address"
#define kResumeHeadImgUrl @"HeadImgURL"
#define kResumeIntro @"Intro"
#define kResumeWorkExp @"WorkExp"
#define kResumeAreaName @"AreaName"
#define kResumeAreaObjectId @"AreaObjectId"
#define kResumeVIP @"VIP"
#define kResumeSex @"Sex"
#define kResumeAge @"Age"
#define kResumeHeight @"Height"
#define kResumePhone @"Phone"
#define kResumeNickName @"Nickname"
#define kResumeName @"Name"
#define kResumeLv @"Lv"
#define kResumeUserStatic @"UserStatic"
#define kResumeCityObjectId @"CityObjectId"
#define kResumeCityName @"CityName"
#define kResumeCustom @"Custom"
#define kResumeFreeDays @"FreeDays"


#define ORIGINAL_MAX_WIDTH 640.0f

typedef NS_ENUM(NSInteger, UITextfieldTag) {
    UITextFieldPassword = 11,
    UITextFieldName,
    UITextFieldNickName,
    UITextFieldYearOld,
    UITextFieldHeight,
    UITextFieldFindJodWord,
    UITextFieldWorkEx,
};
static NSInteger const WORD_NUMS = 30;

@interface MyResumeViewController ()<UINavigationControllerDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,VPImageCropperDelegate,UIActionSheetDelegate>{
    NSString *_theSex;
    NSMutableArray *_weekDates;
    NSMutableDictionary *resumeDic;
    BmobUser *bUser;
    UIBarButtonItem *_setItem;
    
    NSString *_schoolName;
    NSString *_schoolObjectId;
    
    NSString *_headImgUrl;
    
    NSArray *_freeDays;
    
    BOOL isEditing;
    
    BOOL isChangeHeadImage;
    
    __weak IBOutlet UIScrollView *_mainSrollView;
    IBOutlet UIView *_resumeView;
    __weak IBOutlet UIView *_resumeViewTopView;
    __weak IBOutlet UIView *_resumeViewOtherView;
    __weak IBOutlet UIView *_resumeHeaderView;
    __weak IBOutlet UIView *_resumeSexView;
    __weak IBOutlet UIView *_resumeSchoolView;
    __weak IBOutlet UIView *_resumeFindJodWordView;
    __weak IBOutlet UIView *_resumeWorkExView;
    __weak IBOutlet UITextField *_txfNickName;
    __weak IBOutlet UITextField *_txfName;
    __weak IBOutlet UIButton *_btnSexBoy;
    __weak IBOutlet UIButton *_btnSexGirl;
    __weak IBOutlet UITextField *_txfYearOld;
    __weak IBOutlet UITextField *_txfHeight;
    __weak IBOutlet UIButton *_btnSchool;
    __weak IBOutlet UITextView *_txfFindJobWord;
    __weak IBOutlet UILabel *_lbFindJobWordNum;
    __weak IBOutlet UILabel *_lbWorkExpNum;
    __weak IBOutlet UILabel *_lbTheSchool;
    
    __weak IBOutlet UIButton *_monButton;
    __weak IBOutlet UIButton *_tuesButton;
    __weak IBOutlet UIButton *_webButton;
    __weak IBOutlet UIButton *_thurButton;
    __weak IBOutlet UIButton *_friButton;
    __weak IBOutlet UIButton *_satButton;
    __weak IBOutlet UIButton *_sunButton;
    
    __weak IBOutlet UITextView *_txfWorkEx;
    
    __weak IBOutlet UIImageView *_resumeHeadIma;
    
    __weak IBOutlet NSLayoutConstraint *_monCenter;
    __weak IBOutlet NSLayoutConstraint *_tuesCenter;
    __weak IBOutlet NSLayoutConstraint *_wedCenter;
    __weak IBOutlet NSLayoutConstraint *_friCenter;
    __weak IBOutlet NSLayoutConstraint *_satCenter;
    __weak IBOutlet NSLayoutConstraint *_sunCenter;

}

@end

@implementation MyResumeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlackColor);
    //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action: @selector(showDismissTheResume)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerLJWKeyboardHandler];
    
    bUser = [ShareDataSource sharedDataSource].myData;
    
    isEditing = NO;
    
    //设置编辑按钮
    _setItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action: @selector(changeAndUpdateResume:)];
    
    _setItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = _setItem;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"基本信息";
    
    /**
     *  {"Type":"GetResume","Version":"3","UserObjectId":"dc05b02b67"}
     */
    bUser = [ShareDataSource sharedDataSource].myData;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"GetResume",@"Type",kCloudVersion,@"Version", bUser ? bUser.objectId : @"" ,@"UserObjectId", nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [CommonServers callCloudWithAPIName:kCloudAccount andDic:dic success:^(id obj){
            if (obj) {
                [SVProgressHUD dismiss];
                if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                    [self performSelector:@selector(showMyInfoToView:) withObject:obj afterDelay:NO];
                }
            }
        }fail:^(NSString *err){
            [SVProgressHUD showErrorWithStatus:err];
        }];
    });
    
    _weekDates = [[NSMutableArray alloc] init];
    [_resumeView setFrame:CGRectMake(0, 0, mainScreenWidth, 825)];
    
    [_mainSrollView addSubview:_resumeView];
    
    [_mainSrollView setContentSize:_resumeView.frame.size];
    
    [self setShadowWithView:_resumeViewTopView];
    [self setShadowWithView:_resumeViewOtherView];
    
    [_btnSexBoy setViewCornerWithRadius:13.0];
    [_btnSexGirl setViewCornerWithRadius:13.0];
    
    [_resumeSexView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeHeaderView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeSchoolView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeFindJodWordView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeWorkExView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    
    [self setTextFieldStyleWithTXF:_txfName];
    [self setTextFieldStyleWithTXF:_txfNickName];
    [self setTextFieldStyleWithTXF:_txfYearOld];
    [self  setTextFieldStyleWithTXF:_txfHeight];
    
    CGFloat widthCenter = ((mainScreenWidth - 64.0) / 7);
    //利用constant设置星期的位置
    _monCenter.constant = widthCenter*3;
    _tuesCenter.constant = widthCenter*2;
    _wedCenter.constant = widthCenter*1;
    _friCenter.constant = -widthCenter*1;
    _satCenter.constant = -widthCenter*2;
    _sunCenter.constant = -widthCenter*3;
    
    [self viewSetCornerRadius:_monButton withRadius:12.0];
    [self viewSetCornerRadius:_tuesButton withRadius:12.0];
    [self viewSetCornerRadius:_webButton withRadius:12.0];
    [self viewSetCornerRadius:_thurButton withRadius:12.0];
    [self viewSetCornerRadius:_friButton withRadius:12.0];
    [self viewSetCornerRadius:_satButton withRadius:12.0];
    [self viewSetCornerRadius:_sunButton withRadius:12.0];
    
    [_btnSexBoy setViewCornerWithRadius:13.0];
    [_btnSexGirl setViewCornerWithRadius:13.0];
    _btnSexBoy.selected = YES;
    _btnSexGirl.selected = NO;
    [_btnSexGirl setTag:12];
    [_btnSexBoy setTag:11];
    [_btnSexBoy addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSexGirl addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
    _resumeHeadIma.userInteractionEnabled = YES;
    [_resumeHeadIma addGestureRecognizer:tap];
    
    [_txfWorkEx setTag:UITextFieldWorkEx];
    [_txfFindJobWord setTag:UITextFieldFindJodWord];
    
    [_monButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_tuesButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_webButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_thurButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_friButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_satButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_sunButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnSchool addTarget:self action:@selector(chooseSchool:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseAndShowSchool:) name:KEY_KVO_CHANGE_THE_CHOOSEN_SCHOOL object:nil];
    
    //[self performSelector:@selector(showMyInfoToView:) withObject:nil afterDelay:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_CHANGE_THE_CHOOSEN_SCHOOL object:nil];
}

- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    
    isChangeHeadImage = YES;
    
    _resumeHeadIma.image = editedImage;
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController{
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
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

#pragma mark - UINavigationViewControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}


#pragma mark camera utility
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

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"赐一条求职宣言吧"] || [textView.text isEqualToString:@"说说你的工作经历"]) {
        textView.text = @"";
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    if ([textView.text isEqualToString:@"/n"]) {
        FIRST_RESPONDER;
    }
    if (textView.tag == UITextFieldFindJodWord) {
        if (_txfFindJobWord.text.length >= WORD_NUMS) {
            _txfFindJobWord.text = [_txfFindJobWord.text substringToIndex:WORD_NUMS];
        }else{
            _lbFindJobWordNum.text = [NSString stringWithFormat:@"%u",WORD_NUMS - _txfFindJobWord.text.length];
        }
    }
    if (textView.tag == UITextFieldWorkEx) {
        if (_txfWorkEx.text.length >= WORD_NUMS) {
            _txfWorkEx.text = [_txfWorkEx.text substringToIndex:WORD_NUMS];
        }else{
            _lbWorkExpNum.text = [NSString stringWithFormat:@"%u",WORD_NUMS - _txfWorkEx.text.length];
        }
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView{
//    if (textView.tag == UITextFieldFindJodWord) {
//        if (_txfWorkEx.text.length >= WORD_NUMS) {
//            _txfWorkEx.text = [_txfWorkEx.text substringToIndex:WORD_NUMS];
//            _lbWorkExpNum.text = [NSString stringWithFormat:@"0"];
//        }
//    }
//    if (textView.tag == UITextFieldWorkEx) {
//        if (_txfFindJobWord.text.length >= WORD_NUMS) {
//            _txfFindJobWord.text = [_txfFindJobWord.text substringToIndex:WORD_NUMS];
//            _lbFindJobWordNum.text = [NSString stringWithFormat:@"0"];
//        }
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        FIRST_RESPONDER;
        return NO;
    }
    
    return YES;
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//        self.fd_interactivePopDisabled = NO;
        [self backPop];
    }
}

#pragma mark - methods
- (void)showMyInfoToView:(id)sender{
    _txfName.text = [sender objectForKey:kResumeName];
    _txfNickName.text = [sender objectForKey:kResumeNickName];
    
    _theSex = [sender objectForKey:kResumeSex];
    if ([_theSex isEqualToString:@"男"]) {
        [_btnSexBoy setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_btnSexBoy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSexGirl setBackgroundColor:[UIColor clearColor]];
        [_btnSexGirl setTitleColor:UIColorFromRGB(xAlertColor) forState:UIControlStateNormal];
        _btnSexGirl.selected = NO;
        _btnSexBoy.selected = YES;
    }else{
        [_btnSexGirl setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_btnSexGirl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSexBoy setBackgroundColor:[UIColor clearColor]];
        [_btnSexBoy setTitleColor:UIColorFromRGB(xAlertColor) forState:UIControlStateNormal];
        _btnSexGirl.selected = YES;
        _btnSexBoy.selected = NO;
    }
    
    [_resumeHeadIma sd_setImageWithURL:[sender objectForKey:kResumeHeadImgUrl]];
    _txfYearOld.text = [NSString stringWithFormat:@"%@",[sender objectForKey:kResumeAge]];
    _txfHeight.text = [NSString stringWithFormat:@"%@",[sender objectForKey:kResumeHeight]];
    _lbTheSchool.text = [sender objectForKey:kResumeSchoolName];
    _txfFindJobWord.text = [sender objectForKey:kResumeIntro];
    _txfWorkEx.text = [sender objectForKey:kResumeWorkExp];
    
    _lbWorkExpNum.text = [NSString stringWithFormat:@"%u",WORD_NUMS - _txfWorkEx.text.length];
    _lbFindJobWordNum.text = [NSString stringWithFormat:@"%u",WORD_NUMS - _txfFindJobWord.text.length];
    
    _schoolObjectId = [sender objectForKey:kResumeSchoolObjectId];
    
    _headImgUrl = [sender objectForKey:kResumeHeadImgUrl];
    
    _weekDates = [NSMutableArray arrayWithArray:[sender objectForKey:kResumeFreeDays]];
//    _weekDates = [NSMutableArray arrayWithObjects:@1,@2, nil];
    [self weekdayButtonStyleWithButton:_monButton array:_weekDates];
    [self weekdayButtonStyleWithButton:_tuesButton array:_weekDates];
    [self weekdayButtonStyleWithButton:_webButton array:_weekDates];
    [self weekdayButtonStyleWithButton:_thurButton array:_weekDates];
    [self weekdayButtonStyleWithButton:_friButton array:_weekDates];
    [self weekdayButtonStyleWithButton:_satButton array:_weekDates];
    [self weekdayButtonStyleWithButton:_sunButton array:_weekDates];
    
}

- (void)selectAndChangeStates:(UIButton *)sender{
    //    UIButton *btn = (UIButton *)sender;
    if (sender.tag == 11) {
        _theSex = @"男";
        [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSexGirl setBackgroundColor:[UIColor clearColor]];
        [_btnSexGirl setTitleColor:UIColorFromRGB(xBaseBlack) forState:UIControlStateNormal];
        _btnSexGirl.selected = NO;
        _btnSexBoy.selected = YES;
    }else if (sender.tag == 12){
        _theSex = @"女";
        [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSexBoy setBackgroundColor:[UIColor clearColor]];
        [_btnSexBoy setTitleColor:UIColorFromRGB(xBaseBlack) forState:UIControlStateNormal];
        _btnSexGirl.selected = YES;
        _btnSexBoy.selected = NO;
    }
    if (sender.tag >= 0 && sender.tag < 7) {
        if (sender.isSelected) {
            sender.selected = NO;
            [sender setBackgroundColor:[UIColor clearColor]];
            [sender setTitleColor:UIColorFromRGB(xBaseBlack) forState:UIControlStateNormal];
            
            [_weekDates removeObject:[NSNumber numberWithInteger:sender.tag]];
        }else {
            sender.selected = YES;
            [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [_weekDates addObject:[NSNumber numberWithInteger:sender.tag]];
        }
    }else {
        
    }
}

- (void)weekdayButtonStyleWithButton:(UIButton *)btn array:(NSArray *)array{
    if (array.count > 0) {
        for (NSInteger i = 0; i < array.count; i++) {
            if (btn.tag == [[NSString stringWithFormat:@"%@",[array objectAtIndex:i]] integerValue]) {
                btn.selected = YES;
                [btn setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
    
}
- (void)setShadowWithView:(UIView *)view{
    view.layer.masksToBounds = NO;
    
    //view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    view.layer.shadowRadius = 3.0;
    
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    view.layer.shadowOpacity = 0.1f;
}
- (void)viewSetCornerRadius:(UIView *)view withRadius:(CGFloat)radiu{
    view.layer.cornerRadius = radiu;
    view.layer.masksToBounds = YES;
}

/**
 *  更改txf样式（边距、边框）
 *
 *  @param textField UITextField
 *
 *  @return UITextField
 */
- (void)setTextFieldStyleWithTXF:(UITextField *)textField{
    UITextField *txf = textField;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 20)];
    txf.leftView = paddingView;
    txf.leftViewMode = UITextFieldViewModeAlways;
    txf.layer.borderColor = UIColorFromRGB(xBoderColor1).CGColor;
    txf.layer.borderWidth = 0.5f;
    txf.layer.masksToBounds = YES;
}

- (void)showDismissTheResume{
    if (isEditing) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"还没有填写完整的个人简历，确定要离开吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }else {
        [self backPop];
    }
}

- (void)backPop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeAndUpdateResume:(id)sender {
    
    if (isEditing) {
        
        if (_txfName.text.length < 1) {
            [SVProgressHUD showErrorWithStatus:@"请输入姓名"];
            return;
        }
        if (_txfNickName.text.length < 1) {
            [SVProgressHUD showErrorWithStatus:@"昵称不能为空"];
            return;
        }
        if (_txfHeight.text.length < 1) {
            [SVProgressHUD showErrorWithStatus:@"请填写身高选项"];
            return;
        }
        if (_txfYearOld.text.length < 1) {
            [SVProgressHUD showErrorWithStatus:@"请填写年龄选项"];
            return;
        }
        if ([_lbTheSchool.text isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"请选择学校"];
            return;
        }
        if (_resumeHeadIma.image == nil) {
            [SVProgressHUD showErrorWithStatus:@"请设置头像"];
            return;
        }
        
        BmobFile *headImageFile = [[BmobFile alloc] initWithFileName:@"crop_head_img.jpg" withFileData:UIImageJPEGRepresentation(_resumeHeadIma.image, 0.1)];
//        
//        [SVProgressHUD showWithStatus:@"头像上传中"];
//
        if (isChangeHeadImage) {
            isChangeHeadImage = NO;
            
            [headImageFile saveInBackground:^(BOOL isSuccessful, NSError *error){
                if (isSuccessful) {
                    
                    //{"Type":"UpdateUserHeadImg","Version":"3","UserObject":"3c018af4d1","HeadImgURL":"M01/9D/A2/oYYBAFVfGW2ADYFKAACjPkhqO_8558.jpg"}
                    
                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"UpdateUserHeadImg", @"Type", kCloudVersion, @"Version", bUser.objectId, @"UserObjectId", headImageFile.url, @"HeadImgURL", nil];
                    
                    [CommonServers callAccountWithDict:dict success:^(NSDictionary *obj){
                        if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                        }else{
                            [SVProgressHUD showErrorWithStatus:kDataErrorWarning];
                        }
                    }fail:^(NSString *err){
                        [SVProgressHUD showErrorWithStatus:err];
                    }];
                    
                    
                    /**
                     *  {"Phone":"18824864763","Age":23,"Type":"UpdateResume","FreeDays":["0","1"],"WorkExp":"经验","SchoolName":"惠州学院","Height":170,"Name":"陈文超","Nickname":"mc","SchoolObjectId":"bPx3999X","Intro":"呵呵","Version":"220","HeadImgURL":"","UserObjectId":"4dac0354b2","Sex":"男"}
                     */
                    bUser = [BmobUser getCurrentUser];
                    NSDictionary *dicUpdate = [NSDictionary dictionaryWithObjectsAndKeys:
                                               kCloudVersion, @"Version",
                                               @"UpdateResume", @"Type",
                                               bUser.objectId, @"UserObjectId",
                                               _txfNickName.text, kResumeNickName,
                                               _txfName.text, kResumeName,
                                               _theSex, kResumeSex,
                                               headImageFile.url, kResumeHeadImgUrl,
                                               @([[NSString stringWithFormat:@"%@",_txfYearOld.text] intValue]), kResumeAge,
                                               @([[NSString stringWithFormat:@"%@",_txfHeight.text] intValue]), kResumeHeight,
                                               _lbTheSchool.text, kResumeSchoolName,
                                               _schoolObjectId, kResumeSchoolObjectId,
                                               _txfFindJobWord.text, kResumeIntro,
                                               _txfWorkEx.text, kResumeWorkExp,
                                               _weekDates, kResumeFreeDays,
                                               [bUser objectForKey:kResumePhone], kResumePhone, nil];
                    [SVProgressHUD showWithStatus:@"更新中"];
                    [CommonServers callAccountWithDict:dicUpdate success:^(NSDictionary *obj){
                        if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                            [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"Value"]];
                            _resumeView.userInteractionEnabled = NO;
                            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
                            [_setItem setTitle:@"编辑"];
                            
                            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//                            self.fd_interactivePopDisabled = NO;
                            
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
            
        }else {
            
            /**
             *  {"Phone":"18824864763","Age":23,"Type":"UpdateResume","FreeDays":["0","1"],"WorkExp":"经验","SchoolName":"惠州学院","Height":170,"Name":"陈文超","Nickname":"mc","SchoolObjectId":"bPx3999X","Intro":"呵呵","Version":"220","HeadImgURL":"","UserObjectId":"4dac0354b2","Sex":"男"}
             */
            bUser = [BmobUser getCurrentUser];
            BmobFile *headFile = [bUser objectForKey:@"HeadImg"];
            NSDictionary *dicUpdate = [NSDictionary dictionaryWithObjectsAndKeys:
                                       kCloudVersion, @"Version",
                                       @"UpdateResume", @"Type",
                                       bUser.objectId, @"UserObjectId",
                                       _txfNickName.text, kResumeNickName,
                                       _txfName.text, kResumeName,
                                       _theSex, kResumeSex,
                                       headFile.url, kResumeHeadImgUrl,
                                       @([[NSString stringWithFormat:@"%@",_txfYearOld.text] intValue]), kResumeAge,
                                       @([[NSString stringWithFormat:@"%@",_txfHeight.text] intValue]), kResumeHeight,
                                       _lbTheSchool.text, kResumeSchoolName,
                                       _schoolObjectId, kResumeSchoolObjectId,
                                       _txfFindJobWord.text, kResumeIntro,
                                       _txfWorkEx.text, kResumeWorkExp,
                                       _weekDates, kResumeFreeDays,
                                       [bUser objectForKey:kResumePhone], kResumePhone, nil];
            [SVProgressHUD showWithStatus:@"更新中"];
            [CommonServers callAccountWithDict:dicUpdate success:^(NSDictionary *obj){
                if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                    [SVProgressHUD showSuccessWithStatus:[obj objectForKey:@"Value"]];
                    _resumeView.userInteractionEnabled = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
                    [_setItem setTitle:@"编辑"];
                    
                    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//                    self.fd_interactivePopDisabled = NO;
                    
                }
            }fail:^(NSString *err){
                [SVProgressHUD showErrorWithStatus:err];
            }];
            
        }
        
    }else {
        [_setItem setTitle:@"保存"];
        _resumeView.userInteractionEnabled = YES;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//        self.fd_interactivePopDisabled = YES;
    }
    
    isEditing = !isEditing;
}

- (void)updateResume {
    
}

- (void)chooseSchool:(id)sender{
    SchoolViewController *schoolVC = [[SchoolViewController alloc]initWithNibName:@"SchoolViewController" bundle:nil];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:schoolVC animated:YES];
}

#pragma mark - KVO
- (void)chooseAndShowSchool:(NSNotification *)notification{
    _lbTheSchool.text = [notification.object objectForKey:@"SchoolName"];
    _schoolObjectId = [notification.object objectForKey:@"SchoolObjectId"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
