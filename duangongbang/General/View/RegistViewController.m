//
//  RegistViewController.m
//  duangongbang
//
//  Created by ljx on 15/6/6.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "RegistViewController.h"
#import "UIView+Position.h"
#import "UINavigationController+MoveBottomBlackLine.h"
#import "UIView+Border.h"
#import "SVProgressHUD.h"
#import "LJWKeyboardHandlerHeaders.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SchoolViewController.h"
#import "GetFilters.h"
#import "CommonServers.h"
#import <BmobSDK/BmobFile.h>
#import <BmobSDK/BmobUser.h>
#import "ForgotPSAndResetViewController.h"
#import <AVFoundation/AVFoundation.h>

static NSInteger const WORD_NUMS = 30;
static CGFloat const ORIGINAL_MAX_WIDTH = 640.0;
static NSString * const CHOOSELABEL_ARRAY_KVO_KEY = @"CHOOSELABEL_ARRAY";

typedef NS_ENUM(NSInteger, TableOrScrollViewTag){
    UIScrollViewMain = 1,
    UIScrollViewResume,
    UITableViewLeft,
    UITableViewRight,
};

typedef NS_ENUM(NSInteger, UITextfieldTag) {
    UITextFieldPassword = 11,
    UITextFieldName,
    UITextFieldNickName,
    UITextFieldYearOld,
    UITextFieldHeight,
    UITextFieldFindJodWord,
    UITextFieldWorkEx,
};


@interface RegistViewController ()<UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,VPImageCropperDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    
    NSMutableArray *chooseLabelArray;
    NSMutableArray *chooseLabelObjectIdArray;//存放选中标签objectId
    NSArray *rightArray;
    NSArray *rightArrayId;
    NSArray *leftArray;
    NSDictionary *dicClassify;
    
    NSMutableArray *weekDates;
    
    NSString *_theSex;
    
    NSString *_schoolObjectId;
    
    __weak IBOutlet UIScrollView *_mainScrollView;
    
    __weak IBOutlet UIView *_pointFirstFG;
    __weak IBOutlet UIView *_pointSecondFG;
    __weak IBOutlet UIView *_pointThirdFG;
    
    __weak IBOutlet UIView *_pointThirdBG;
    __weak IBOutlet UIView *_pointSecondBG;
    __weak IBOutlet UIView *_pointFirstBG;
    
    IBOutlet UIView *_mainView;
    IBOutlet UIView *_resumeView;
    IBOutlet UIView *_chooseView;
    IBOutlet UIView *_passwordView;
    
    __weak IBOutlet UIControl *_passviewTopView;
    __weak IBOutlet UITextField *_txfPassword;
    __weak IBOutlet UIButton *_btnFinistPassword;
    
    __weak IBOutlet UIView *_resumeViewTopView;
    __weak IBOutlet UIView *_resumeViewOtherView;
    __weak IBOutlet UIView *_resumeViewBottomView;
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
    
    __weak IBOutlet UIView *_resumeviewBottomView;
    
    __weak IBOutlet UIImageView *_resumeHeadIma;
    __weak IBOutlet UIButton *_btnResumeviewFinish;
    
    __weak IBOutlet UIView *_chooseViewBottomView;
    __weak IBOutlet UIView *_chooseViewTopView;
    
    __weak IBOutlet UIButton *_btnFirstChoose;
    __weak IBOutlet UIButton *_btnSecondChoose;
    __weak IBOutlet UIButton *_btnThirdChoose;
    
    __weak IBOutlet UITableView *_tableViewLeft;
    __weak IBOutlet UITableView *_tableViewRight;
    
    __weak IBOutlet UIButton *_btnChooseFinish;
    
    __weak IBOutlet NSLayoutConstraint *_monCenter;
    __weak IBOutlet NSLayoutConstraint *_tuesCenter;
    __weak IBOutlet NSLayoutConstraint *_wedCenter;
    __weak IBOutlet NSLayoutConstraint *_friCenter;
    __weak IBOutlet NSLayoutConstraint *_satCenter;
    __weak IBOutlet NSLayoutConstraint *_sunCenter;
    __weak IBOutlet NSLayoutConstraint *_constantNavTop;
}

@end

@implementation RegistViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlueColor);
    //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action: @selector(showDismissTheResume)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.navigationController moveBottomBlackLine];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [_mainScrollView addSubview:_passwordView];
    [_mainScrollView addSubview:_chooseView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"第一步先设置账号密码";
    
    [self setAllView];
    [self registerLJWKeyboardHandler];
    _constantNavTop.constant = 0.0;
    
    [_btnFirstChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSecondChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_btnThirdChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooicesChange:) name:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
    
    NSString *strPath = [[[NSBundle mainBundle] pathForResource:kCategoryJsonFileName ofType:@"json"] copy];
    
    NSString *parseJson = [[[NSString alloc] initWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil] copy];
    NSDictionary *categoryDic = [[NSJSONSerialization JSONObjectWithData:[parseJson dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil] copy];
    
    
    chooseLabelArray = [[NSMutableArray alloc] init];
    chooseLabelObjectIdArray = [[NSMutableArray alloc] init];
    
    dicClassify = [GetFilters getAllClassisfyWithArray:[categoryDic objectForKey:@"Classify"]];
    leftArray = [dicClassify objectForKey:kClassifyName];
    rightArray = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:0];
    rightArrayId = [[dicClassify objectForKey:kClassifyObjectIdArray] objectAtIndex:0];
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_CHANGE_THE_CHOOSEN_SCHOOL object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIScrollviewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_mainScrollView.contentOffset.x == 0.0) {
        [_pointFirstFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_pointSecondFG setBackgroundColor:UIColorFromRGB(xHeadViewGrayColor)];
        [_pointThirdFG setBackgroundColor:UIColorFromRGB(xHeadViewGrayColor)];
    }else if (_mainScrollView.contentOffset.x == mainScreenWidth){
        [_pointFirstFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_pointSecondFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_pointThirdFG setBackgroundColor:UIColorFromRGB(xHeadViewGrayColor)];
    }else if (_mainScrollView.contentOffset.x == mainScreenWidth * 2){
        [_pointFirstFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_pointSecondFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [_pointThirdFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
    }
    if (scrollView.tag == UIScrollViewMain) {
        
    }
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (tableView.tag) {
        case UITableViewLeft:
            rightArray = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:indexPath.row];
            rightArrayId = [[dicClassify objectForKey:kClassifyObjectIdArray] objectAtIndex:indexPath.row];
            [_tableViewRight reloadData];
            break;
        case UITableViewRight:
            if (chooseLabelArray.count < 3 || [chooseLabelArray containsObject:[rightArray objectAtIndex:indexPath.row]]) {
                if ([chooseLabelArray containsObject:[rightArray objectAtIndex:indexPath.row]]) {
                    NSArray *temp = [[NSArray arrayWithArray:chooseLabelArray] copy];
                    [chooseLabelArray removeObjectAtIndex:[temp indexOfObject:[rightArray objectAtIndex:indexPath.row]]];
                    [chooseLabelObjectIdArray removeObjectAtIndex:[temp indexOfObject:[rightArray objectAtIndex:indexPath.row]]];
                    
                }else{
                    [chooseLabelArray addObject:[rightArray objectAtIndex:indexPath.row]];
                    [chooseLabelObjectIdArray addObject:[rightArrayId objectAtIndex:indexPath.row]];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
                
                LOG(@"%@",chooseLabelArray);
            }else{
                [SVProgressHUD showErrorWithStatus:@"最多选择3个"];
            }
            
            break;
    }
}
#pragma mark - UITableviewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //设置选中
    if (tableView.tag == UITableViewLeft) {
        return leftArray.count;
    }else{
        
        return rightArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    UIView *back = [[UIView alloc] initWithFrame:cell.frame];
    back.backgroundColor = UIColorFromRGB(xTableViewGrayColor);
    cell.selectedBackgroundView = back;
    cell.textLabel.font = [UIFont fontWithName:kFontName size:12.0];
    cell.textLabel.textColor = UIColorFromRGB(xFontColor1);
    cell.layer.masksToBounds = YES;
    //设置选中时的背景
    switch (tableView.tag) {
        case UITableViewLeft:
            cell.backgroundColor = UIColorFromRGB(xTableViewGrayColor);
            back.backgroundColor = UIColorFromRGB(0xFFFFFF);
            cell.selectedBackgroundView = back;
            cell.textLabel.text = [leftArray objectAtIndex:indexPath.row];
            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addRightBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            break;
        case UITableViewRight:
            cell.textLabel.text = [rightArray objectAtIndex:indexPath.row];
            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addRightBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addLeftBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            break;
    }
    
    return cell;
}
#pragma mark - VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage{
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self backPop];
    }
}

#pragma mark - UIActionSheetDelegate
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
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
            _lbFindJobWordNum.text = [NSString stringWithFormat:@"%lu",WORD_NUMS - _txfFindJobWord.text.length];
        }
    }
    if (textView.tag == UITextFieldWorkEx) {
        if (_txfWorkEx.text.length >= WORD_NUMS) {
            _txfWorkEx.text = [_txfWorkEx.text substringToIndex:WORD_NUMS];
        }else{
            _lbWorkExpNum.text = [NSString stringWithFormat:@"%lu",WORD_NUMS - _txfWorkEx.text.length];
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
#pragma mark - button 

- (void)deleteChooseLabel:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    
    if (![btn.titleLabel.text isEqualToString:@""]) {
        NSArray *temp = [[NSArray arrayWithArray:chooseLabelArray] copy];
        [chooseLabelArray removeObjectAtIndex:[temp indexOfObject:btn.titleLabel.text]];
        [chooseLabelObjectIdArray removeObjectAtIndex:[temp indexOfObject:btn.titleLabel.text]];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
    }
}

#pragma mark - Methods
- (void)chooicesChange:(id)sender{
    _btnFirstChoose.enabled = YES;
    _btnSecondChoose.enabled = YES;
    _btnThirdChoose.enabled = YES;
    if (chooseLabelArray.count == 0) {
        _btnFirstChoose.enabled = NO;
        _btnSecondChoose.enabled = NO;
        _btnThirdChoose.enabled = NO;
        [_btnFirstChoose setTitle:@"" forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:@"" forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:@"" forState:UIControlStateNormal];
    }else if (chooseLabelArray.count == 1){
        [_btnFirstChoose setTitle:[chooseLabelArray objectAtIndex:0] forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:@"" forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:@"" forState:UIControlStateNormal];
    }else if (chooseLabelArray.count == 2){
        [_btnFirstChoose setTitle:[chooseLabelArray objectAtIndex:0] forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:[chooseLabelArray objectAtIndex:1] forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:@"" forState:UIControlStateNormal];
    }else if (chooseLabelArray.count == 3){
        [_btnFirstChoose setTitle:[chooseLabelArray objectAtIndex:0] forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:[chooseLabelArray objectAtIndex:1] forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:[chooseLabelArray objectAtIndex:2] forState:UIControlStateNormal];
    }
}

- (void)setAllView{
    
    weekDates = [[NSMutableArray alloc] init];
    UIScrollView *resumeScrollView = [[UIScrollView alloc] init];
    [_mainScrollView addSubview:resumeScrollView];
    [resumeScrollView addSubview:_resumeView];
    
    [_mainScrollView setTag:UIScrollViewMain];
    [_tableViewLeft setTag:UITableViewLeft];
    [_tableViewRight setTag:UITableViewRight];
    [resumeScrollView setTag:UIScrollViewResume];
    
    [_txfPassword setTag:UITextFieldPassword];
    [_txfName setTag:UITextFieldName];
    [_txfName setTag:UITextFieldNickName];
    [_txfYearOld setTag:UITextFieldYearOld];
    [_txfHeight setTag:UITextFieldHeight];
    [_txfFindJobWord setTag:UITextFieldFindJodWord];
    [_txfWorkEx setTag:UITextFieldWorkEx];
    
    [self viewSetCornerRadius:_pointFirstBG withRadius:8.0];
    [self viewSetCornerRadius:_pointSecondBG withRadius:8.0];
    [self viewSetCornerRadius:_pointThirdBG withRadius:8.0];
    
    [self viewSetCornerRadius:_pointFirstFG withRadius:5.0];
    [self viewSetCornerRadius:_pointSecondFG withRadius:5.0];
    [self viewSetCornerRadius:_pointThirdFG withRadius:5.0];
    
    [self setShadowWithView:_passviewTopView];
    [self setShadowWithView:_resumeViewTopView];
    [self setShadowWithView:_resumeViewOtherView];
    [self setShadowWithView:_resumeViewBottomView];
    [self setShadowWithView:_chooseViewTopView];
    [self setShadowWithView:_chooseViewBottomView];
    
    [_btnSexBoy setViewCornerWithRadius:13.0];
    [_btnSexGirl setViewCornerWithRadius:13.0];
    
    [_resumeSexView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeHeaderView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeSchoolView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeFindJodWordView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    [_resumeWorkExView addBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    
    [self setTextFieldStyleWithTXF:_txfPassword];
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
    
    CGFloat subHeight = mainScreenHeight-108;
    [_passwordView setFrame:CGRectMake(0, 0, mainScreenWidth, subHeight)];
    [resumeScrollView setFrame:CGRectMake(mainScreenWidth, 0, mainScreenWidth, subHeight)];
    [_chooseView setFrame:CGRectMake(mainScreenWidth * 2, 0, mainScreenWidth, subHeight)];
    
    [_resumeView setFrame:CGRectMake(0, 0, mainScreenWidth, 914.0)];
    resumeScrollView.contentSize = CGSizeMake(mainScreenWidth, 914.0);
    _mainScrollView.contentSize = CGSizeMake(mainScreenWidth, subHeight);
    
    //button Action
    [_btnFinistPassword addTarget:self action:@selector(finishSetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_passviewTopView addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchDown];
    [_btnResumeviewFinish addTarget:self action:@selector(finishResumeview:) forControlEvents:UIControlEventTouchUpInside];
    [_btnChooseFinish addTarget:self action:@selector(finishTabAndRegist:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeadImage)];
    [_resumeHeaderView addGestureRecognizer:imgTap];
    
    [_monButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_tuesButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_webButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_thurButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_friButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_satButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_sunButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    
    _theSex = @"男";
    _btnSexBoy.selected = YES;
    _btnSexGirl.selected = NO;
    [_btnSexGirl setTag:12];
    [_btnSexBoy setTag:11];
    [_btnSexBoy addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSexGirl addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnSchool addTarget:self action:@selector(chooseSchool:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseAndShowSchool:) name:KEY_KVO_CHANGE_THE_CHOOSEN_SCHOOL object:nil];
}

- (void)setShadowWithView:(UIView *)view{
    view.layer.masksToBounds = NO;
    
    //view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    view.layer.shadowRadius = 3.0;
    
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    view.layer.shadowOpacity = 0.1f;
}

- (void)showDismissTheResume {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"放弃编辑" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setTag:0];
    [alert show];
}

- (void)backPop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewSetCornerRadius:(UIView *)view withRadius:(CGFloat)radiu {
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

#pragma mark - UIButton
- (void)finishSetPassword:(id)sender{
    FIRST_RESPONDER;
    if (_txfPassword.text.length < 3) {
        [SVProgressHUD showErrorWithStatus:@"密码太短"];
        return;
    }
    if (![_txfPassword.text isEqualToString:@""]) {
        _mainScrollView.contentSize = CGSizeMake(mainScreenWidth * 2, mainScreenHeight - 108.0);
        [_mainScrollView setContentOffset:CGPointMake(mainScreenWidth, 0.0) animated:YES];
        [_pointSecondFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        self.title = @"然后填写简历内容";
    }else{
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
    }
}

- (void)finishResumeview:(id)sender{
    FIRST_RESPONDER;
    
    if (_txfPassword.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"请先设置密码"];
    }
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
    self.title = @"请选择你喜欢的兼职类型";
    _mainScrollView.contentSize = CGSizeMake(mainScreenWidth * 3, mainScreenHeight - 108.0);
    [_mainScrollView setContentOffset:CGPointMake(mainScreenWidth * 2, 0.0) animated:YES];
    [_pointThirdFG setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
    
}
- (void)finishTabAndRegist:(id)sender{
    if (_txfPassword.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"请先设置密码"];
    }
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
//    if (chooseLabelObjectIdArray.count < 1) {
//        [SVProgressHUD showErrorWithStatus:@"请至少选择一个"];
//        return;
//    }
    if (_resumeHeadIma.image == nil) {
        [SVProgressHUD showErrorWithStatus:@"请设置头像"];
        return;
    }
    
    /**
     *  {"DeviceId":"C4A458ED100DB0485105B2D74712D113","Phone":"18824864763","Age":23,"Classifies":["FfCC9445","6WWuY77O"],"Type":"SignUp","FreeDays":["6"],"WorkExp":"meiyou","SchoolName":"惠州学院","Height":170,"DeviceType":"android","password":"123456","Name":"mame","username":"test1","Nickname":"mc","SchoolObjectId":"bPx3999X","Intro":"我就是我","Version":"220","HeadImgURL":"http://newfile.codenow.cn:8080/fdac71b14c24416d9adabb5c2320f577.JPG?t=2&a=1f1cabee2d9d4c3bfa12968a07e578e3","Sex":"男"}
     */
    
    NSData *imageHead = UIImageJPEGRepresentation(_resumeHeadIma.image, 0.1);
    BmobFile *headImageFile = [[BmobFile alloc] initWithFileName:@"crop_head_img.jpg" withFileData:imageHead];
    
    [SVProgressHUD showWithStatus:@"头像上传中"];
    
    [headImageFile saveInBackground:^(BOOL isSuccessful, NSError *error){
        if (isSuccessful) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功！"];
            
//            NSMutableDictionary *registerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                 [USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY], @"DeviceId",//
//                                                 [USER_DEFAULT objectForKey:USER_PHONE], @"Phone",//
//                                                 @([[NSString stringWithFormat:@"%@",_txfYearOld.text] intValue]), @"Age",//
//                                                 chooseLabelObjectIdArray, @"Classifies",//
//                                                 @"SignUp", @"Type",//
//                                                 weekDates, @"FreeDays",//
//                                                 [_txfWorkEx.text isEqualToString:@""] ? @"" : _txfWorkEx.text, @"WorkExp",//
//                                                 _lbTheSchool.text, @"SchoolName",//
//                                                 @([[NSString stringWithFormat:@"%@",_txfHeight.text] intValue]), @"Height",//
//                                                 @"ios", @"DeviceType",//
//                                                 _txfPassword.text, @"password",//
//                                                 _txfName.text, @"Name",//
//                                                 [USER_DEFAULT objectForKey:USER_PHONE], @"username",//
//                                                 _txfNickName.text, @"Nickname",//
//                                                 _schoolObjectId, @"SchoolObjectId",
//                                                 [_txfFindJobWord.text isEqualToString:@""] ? @"" : _txfFindJobWord.text, @"Intro",
//                                                 kCloudVersion, @"Version",
//                                                 headImageFile.url, @"HeadImgURL",
//                                                 _theSex, @"Sex", nil];
//            if (![USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY]) {
////                [USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY]
//            }
            NSMutableDictionary *registerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 [USER_DEFAULT objectForKey:USER_PHONE], @"Phone",//
                                                 @([[NSString stringWithFormat:@"%@",_txfYearOld.text] intValue]), @"Age",//
                                                 chooseLabelObjectIdArray, @"Classifies",//
                                                 @"SignUp", @"Type",//
                                                 weekDates, @"FreeDays",//
                                                 [_txfWorkEx.text isEqualToString:@""] ? @"" : _txfWorkEx.text, @"WorkExp",//
                                                 _lbTheSchool.text, @"SchoolName",//
                                                 @([[NSString stringWithFormat:@"%@",_txfHeight.text] intValue]), @"Height",//
                                                 @"ios", @"DeviceType",//
                                                 _txfPassword.text, @"password",//
                                                 _txfName.text, @"Name",//
                                                 [USER_DEFAULT objectForKey:USER_PHONE], @"username",//
                                                 _txfNickName.text, @"Nickname",//
                                                 _schoolObjectId, @"SchoolObjectId",
                                                 [_txfFindJobWord.text isEqualToString:@""] ? @"" : _txfFindJobWord.text, @"Intro",
                                                 kCloudVersion, @"Version",
                                                 headImageFile.url, @"HeadImgURL",
                                                 _theSex, @"Sex",
                                                 [USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY], @"DeviceId",
                                                 nil];
            

            [CommonServers callAccountWithDict:registerDict success:^(NSDictionary *obj){
                LOG(@"申请详情 === %@",registerDict);
                if (obj) {
                    
                    if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                        [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                        [BmobUser loginWithUsernameInBackground:[USER_DEFAULT objectForKey:USER_PHONE] password:_txfPassword.text block:^(BmobUser *bUser, NSError *error){
                            if (bUser) {
                                [ShareDataSource sharedDataSource].myData = bUser;
                            }
                        }];
                        [self dismissViewControllerAnimated:YES completion:^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GET_WORK_LIST object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
                        }];
                    }
                    else if ([[obj objectForKey:@"Static"] isEqualToString:@"faile"]) 
                    {
                        NSLog(@"失败详情 == %@",[obj objectForKey:@"Value"]);
                    }
                }
                
            }fail:^(NSString *err){
                [SVProgressHUD showErrorWithStatus:@"注册失败，请重试！"];
                NSLog(@"err ======= %@",err);
            }];
            
        }else{
            
        }
    }withProgressBlock:^(float progress){
        [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"头像上传中...%d%%",(int)(progress*100.0)]];
    }];
    
    
}

- (void)selectAndChangeStates:(UIButton *)sender{
    //    UIButton *btn = (UIButton *)sender;
    if (sender.tag == 11) {
        _theSex = @"男";
        [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSexGirl setBackgroundColor:[UIColor clearColor]];
        [_btnSexGirl setTitleColor:UIColorFromRGB(xAlertColor) forState:UIControlStateNormal];
        _btnSexGirl.selected = NO;
        _btnSexBoy.selected = YES;
    }else if (sender.tag == 12){
        _theSex = @"女";
        [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnSexBoy setBackgroundColor:[UIColor clearColor]];
        [_btnSexBoy setTitleColor:UIColorFromRGB(xAlertColor) forState:UIControlStateNormal];
        _btnSexGirl.selected = YES;
        _btnSexBoy.selected = NO;
    }
    
    if (sender.tag >= 0 && sender.tag < 7) {
        
        if (sender.isSelected) {
            sender.selected = NO;
            [sender setBackgroundColor:[UIColor clearColor]];
            [sender setTitleColor:UIColorFromRGB(xBaseBlack) forState:UIControlStateNormal];
            
//            [weekDates removeObject:[NSNumber numberWithInteger:sender.tag]];
            [weekDates removeObject:[NSString stringWithFormat:@"%ld",sender.tag]];
        }else {
            sender.selected = YES;
            [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [weekDates addObject:[NSString stringWithFormat:@"%ld",sender.tag]];
            
//            [weekDates addObject:[NSNumber numberWithInteger:sender.tag]];
        }
    }else {
        
    }
    
}

- (void)chooseSchool:(id)sender{
    SchoolViewController *schoolVC = [[SchoolViewController alloc]initWithNibName:@"SchoolViewController" bundle:nil];
    [self.navigationController pushViewController:schoolVC animated:YES];
}

#pragma mark - gesture
- (void)changeHeadImage{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
    
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
