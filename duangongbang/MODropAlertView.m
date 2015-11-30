//
//  MODropAlertView.m
//  MODropAlertDemo
//
//  Created by Ahn JungMin on 2014. 7. 1..
//  Copyright (c) 2014년 Ahn JungMin. All rights reserved.
//

#import "MODropAlertView.h"
#import "UIImage+ImageEffects.h"

#define kUserBlueColor [UIColor colorWithRed:56.0f / 255.f green:134.0f / 255.f blue:190.0f / 255.f    alpha:1.0f]
#define kUserGreenColor [UIColor colorWithRed:41.0f / 255.f green:203.0f / 255.f blue:136.0f / 255.f       alpha:1.0f]

//      当前屏幕的宽度
#define kMainScreenWidth  ([UIScreen mainScreen].applicationFrame.size.width)
#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define kFontColor 0x333333

static const CGFloat kAlertButtonBottomMargin = 10;
static const CGFloat kAlertButtonSideMargin = 15;
static const CGFloat kAlertButtonHeight = 30;

static const CGFloat kAlertTitleLabelHeight = 30;
static const CGFloat kAlertTitleLabelTopMargin = 30;

static const CGFloat kAlertTitleLabelFontSize = 24;

static NSString* kAlertOKButtonNormalColor = @"#FFFFFF";
static NSString* kAlertOKButtonHighlightColor = @"#DDDDDD";
static NSString* kAlertCancelButtonNormalColor = @"#FFFFFF";
static NSString* kAlertCancelButtonHighlightColor = @"#DDDDDD";

@implementation MODropAlertView {
    
@private
    NSString *okButtonTitleStr;
    NSString *cancelButtonTitleString;
    NSString *titleStr;
    NSString *descrptionString;
    
    UIImageView *backgroundView;
    UIView *alertView;
    
    UILabel *titleLabel;
    UILabel *descriptionLabel;
    
    UIButton *okButton;
    UIButton *cancelButton;
    
    DropAlertViewType kType;
    UIColor *okButtonColor;
    UIColor *cancelButtonColor;
    blk successBlockCallback;
    blk failureBlockCallback;
}

#pragma mark - Initialized Drop Alert Methods
- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:nil
                          okButtonColor:nil
                      cancelButtonColor:nil
                              alertType:DropAlertDefault];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                     cancelButtonTitle:(NSString *)cancelButtonTitle
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:cancelButtonTitle
                          okButtonColor:nil
                      cancelButtonColor:nil
                              alertType:DropAlertDefault];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                         okButtonColor:(UIColor *)okBtnColor
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:nil
                          okButtonColor:okBtnColor
                      cancelButtonColor:nil
                              alertType:DropAlertCustom];
}
- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                     cancelButtonTitle:(NSString *)cancelButtonTitle
                         okButtonColor:(UIColor *)okBtnColor
                     cancelButtonColor:(UIColor *)cancelBtnColor
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:cancelButtonTitle
                          okButtonColor:okBtnColor
                      cancelButtonColor:cancelBtnColor
                              alertType:DropAlertCustom];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                     cancelButtonTitle:(NSString *)cancelButtonTitle
                         okButtonColor:(UIColor *)okBtnColor
                     cancelButtonColor:(UIColor *)cancelBtnColor
                             alertType:(DropAlertViewType)alertType
{
    self = [super init];
    if (self) {
        okButtonTitleStr = okButtonTitle;
        cancelButtonTitleString = cancelButtonTitle;
        descrptionString = description;
        titleStr = title;
        kType = alertType;
        okButtonColor = okBtnColor;
        cancelButtonColor = cancelBtnColor;
        [self initDropAlert];
    }
    return self;
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                          successBlock:(blk)successBlock
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:nil
                          okButtonColor:nil
                      cancelButtonColor:nil
                           successBlock:successBlock
                           failureBlock:nil
                              alertType:DropAlertDefault];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                     cancelButtonTitle:(NSString *)cancelButtonTitle
                          successBlock:(blk)successBlock
                          failureBlock:(blk)failureBlock
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:cancelButtonTitle
                          okButtonColor:nil
                      cancelButtonColor:nil
                           successBlock:successBlock
                           failureBlock:failureBlock
                              alertType:DropAlertDefault];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                         okButtonColor:(UIColor *)okBtnColor
                          successBlock:(blk)successBlock
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:nil
                          okButtonColor:okButtonColor
                      cancelButtonColor:nil
                           successBlock:successBlock
                           failureBlock:nil
                              alertType:DropAlertCustom];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                     cancelButtonTitle:(NSString *)cancelButtonTitle
                         okButtonColor:(UIColor *)okBtnColor
                     cancelButtonColor:(UIColor *)cancelBtnColor
                          successBlock:(blk)successBlock
                          failureBlock:(blk)failureBlock
{
    return [self initDropAlertWithTitle:title
                            description:description
                          okButtonTitle:okButtonTitle
                      cancelButtonTitle:cancelButtonTitle
                          okButtonColor:okButtonColor
                      cancelButtonColor:cancelButtonColor
                           successBlock:successBlock
                           failureBlock:failureBlock
                              alertType:DropAlertCustom];
}

- (instancetype)initDropAlertWithTitle:(NSString *)title
                           description:(NSString *)description
                         okButtonTitle:(NSString *)okButtonTitle
                     cancelButtonTitle:(NSString *)cancelButtonTitle
                         okButtonColor:(UIColor *)okBtnColor
                     cancelButtonColor:(UIColor *)cancelBtnColor
                          successBlock:(blk)successBlock
                          failureBlock:(blk)failureBlock
                             alertType:(DropAlertViewType)alertType
{
    self = [super init];
    if (self) {
        okButtonTitleStr = okButtonTitle;
        cancelButtonTitleString = cancelButtonTitle;
        descrptionString = description;
        titleStr = title;
        kType = alertType;
        okButtonColor = okBtnColor;
        cancelButtonColor = cancelBtnColor;
        successBlockCallback = successBlock;
        failureBlockCallback = failureBlock;
        [self initDropAlert];
    }
    return self;
}

- (void)initDropAlert
{
    self.frame = [self mainScreenFrame];
    self.opaque = YES;
    self.backgroundColor = [UIColor clearColor];
    
    [self makeBackgroundBlur];
    [self makeAlertPopupView];
    
    [self makeAlertButton:cancelButtonTitleString ? YES : NO];
    [self makeAlertTitleLabel];
    [self makeAlertDescriptionLabel];
    
    [self moveAlertPopupView];
}

#pragma mark - View Layout Methods
- (void)makeBackgroundBlur
{
    backgroundView = [[UIImageView alloc]initWithFrame:[self mainScreenFrame]];
    
    backgroundView.userInteractionEnabled = YES;
    
    backgroundView.multipleTouchEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle:)];
    
    [backgroundView addGestureRecognizer:tap];
    
    UIImage *image = [UIImage convertViewToImage];
    UIImage *blurSnapshotImage = nil;
    blurSnapshotImage = [image applyBlurWithRadius:12.0
                                         tintColor:[UIColor colorWithWhite:0.05
                                                                     alpha:0.8]
                             saturationDeltaFactor:1.8
                                         maskImage:nil];
    
    backgroundView.image = blurSnapshotImage;
    backgroundView.alpha = 0;
    
    [self addSubview:backgroundView];
}

- (void)handle:(UITapGestureRecognizer *)sender{
    
    DropAlertButtonType buttonType;
    
    LOG(@"shoushi111111111");
    
    buttonType = DropAlertNULL;
    
    [self dismiss:buttonType];
    
}

- (void)makeAlertPopupView
{
    CGRect frame = CGRectMake(0, 0, kMainScreenWidth * 0.8, kMainScreenWidth * 0.4);
    CGRect screen = [self mainScreenFrame];
    
    alertView = [[UIView alloc]initWithFrame:frame];
    
    alertView.center = CGPointMake(CGRectGetWidth(screen)/2, CGRectGetHeight(screen)/2);
    
    [[alertView layer] setShadowOffset:CGSizeMake(0, 0)];
    [[alertView layer] setShadowRadius:5];
    [[alertView layer] setShadowOpacity:1];
    [[alertView layer] setShadowColor:[UIColor blackColor].CGColor];
    
    alertView.layer.masksToBounds = YES;
    alertView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    [self addSubview:alertView];
}

- (void)makeAlertTitleLabel
{
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(alertView.frame) - kAlertButtonSideMargin, kAlertTitleLabelHeight)];
    titleLabel.center = CGPointMake(CGRectGetWidth(alertView.frame)/2, kAlertTitleLabelTopMargin);
    titleLabel.text = titleStr;
    titleLabel.textColor = [UIColor darkGrayColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.font = [titleLabel.font fontWithSize:kAlertTitleLabelFontSize];
    
    [alertView addSubview:titleLabel];
}

- (void)makeAlertDescriptionLabel
{
    descriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth * 0.624, kMainScreenWidth * 0.05)];
    descriptionLabel.center = CGPointMake(kMainScreenWidth * 0.4,
                                          kMainScreenWidth * 0.125);
    descriptionLabel.text = descrptionString;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.textColor = HexRGBAlpha(kFontColor, 1);
    descriptionLabel.font = [descriptionLabel.font fontWithSize:kMainScreenWidth * 0.048];
    
    // Line Breaking
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    
    [descriptionLabel setTextAlignment:NSTextAlignmentLeft];
    [descriptionLabel sizeToFit];
    
    [alertView addSubview:descriptionLabel];
}

- (void)makeAlertButton:(BOOL)hasCancelButton
{
    okButton = [[UIButton alloc]init];
    
    okButton.layer.borderColor = HexRGBAlpha(0xDDDDDD, 1.0).CGColor;
    
    okButton.layer.borderWidth = 0.5;
    
    [okButton.layer setMasksToBounds:YES];
    
    if (hasCancelButton) {
        cancelButton = [[UIButton alloc]init];
        
        
        cancelButton.layer.borderColor = HexRGBAlpha(0xDDDDDD, 1.0).CGColor;
        
        cancelButton.layer.borderWidth = 0.5;
        
        [cancelButton.layer setMasksToBounds:YES];
        
        [okButton setFrame:CGRectMake(0, 0, kMainScreenWidth * 0.4 + 1, kMainScreenWidth * 0.15 + 0.5)];
        [cancelButton setFrame:CGRectMake(0, 0, kMainScreenWidth * 0.4 + 1, kMainScreenWidth * 0.15 + 0.5)];
        
        [okButton setCenter:CGPointMake(kMainScreenWidth * 0.2,
                                        kMainScreenWidth * 0.325)];
        [cancelButton setCenter:CGPointMake(kMainScreenWidth * 0.6,
                                            kMainScreenWidth * 0.325)];
        
        if (cancelButtonColor) {
            [cancelButton setBackgroundImage:[UIImage imageWithColor:cancelButtonColor] forState:UIControlStateNormal];
        } else {
            [cancelButton setBackgroundImage:[UIImage imageWithColor:[self colorFromHexString:kAlertCancelButtonNormalColor]] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageWithColor:[self colorFromHexString:kAlertCancelButtonHighlightColor]] forState:UIControlStateHighlighted];
        }
        
        [cancelButton setTitle:cancelButtonTitleString
                      forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[cancelButton.titleLabel.font fontWithSize:kMainScreenWidth * 0.048]];
        [cancelButton setTitleColor:HexRGBAlpha(kFontColor, 1) forState:UIControlStateNormal];
        [cancelButton addTarget:self
                         action:@selector(pressAlertButton:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self setShadowLayer:cancelButton.layer];
        
        [alertView addSubview:cancelButton];
        
    } else {
        [okButton setFrame:CGRectMake(0, 0, CGRectGetWidth(alertView.frame) - (kAlertButtonSideMargin * 2), kAlertButtonHeight)];
        [okButton setCenter:CGPointMake(CGRectGetWidth(alertView.frame)/2, CGRectGetHeight(alertView.frame) - CGRectGetHeight(okButton.frame)/2 - kAlertButtonBottomMargin)];
    }
    [self setShadowLayer:okButton.layer];
    
    if (okButtonColor) {
        [okButton setBackgroundImage:[UIImage imageWithColor:okButtonColor] forState:UIControlStateNormal];
    } else {
        [okButton setBackgroundImage:[UIImage imageWithColor:[self colorFromHexString:kAlertOKButtonNormalColor]] forState:UIControlStateNormal];
        [okButton setBackgroundImage:[UIImage imageWithColor:[self colorFromHexString:kAlertOKButtonHighlightColor]] forState:UIControlStateHighlighted];
    }
    
    [okButton setTitle:okButtonTitleStr
              forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[okButton.titleLabel.font fontWithSize:kMainScreenWidth * 0.048]];
    [okButton setTitleColor:HexRGBAlpha(kFontColor, 1) forState:UIControlStateNormal];
    [okButton addTarget:self
                 action:@selector(pressAlertButton:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [alertView addSubview:okButton];
}

#pragma mark - View Animation Methods
- (void)moveAlertPopupView
{
    CGRect screen = [self mainScreenFrame];
    CATransform3D move = CATransform3DIdentity;
    CGFloat initAlertViewYPosition = (CGRectGetHeight(screen) + CGRectGetHeight(alertView.frame)) / 2;
    
    move = CATransform3DMakeTranslation(0, -initAlertViewYPosition, 0);
    move = CATransform3DRotate(move, 40 * M_PI/180, 0, 0, 1.0f);
    
    alertView.layer.transform = move;
}

- (void)show
{
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    
    if( [self.delegate respondsToSelector:@selector(alertViewWillAppear:)] ) {
        [self.delegate alertViewWillAppear:self];
    }
    
    [self showAnimation];
}

- (void)showAnimation
{
    [UIView animateWithDuration:0.3f animations:^{
        backgroundView.alpha = 1.0f;
    }];
    
    
    [UIView animateWithDuration:1.0f
                          delay:0.0f
         usingSpringWithDamping:0.4f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CATransform3D init = CATransform3DIdentity;
                         alertView.layer.transform = init;
                         
                     }
                     completion:^(BOOL finished) {
                         if( [self.delegate respondsToSelector:@selector(alertViewDidAppear:)] && finished) {
                             [self.delegate alertViewDidAppear:self];
                         }
                     }];
}

- (void)dismiss:(DropAlertButtonType)buttonType
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertViewWilldisappear:buttonType:)] ) {
        [self.delegate alertViewWilldisappear:self buttonType:buttonType];
    }
    [self dismissAnimation:buttonType];
}

- (void)dismissAnimation:(DropAlertButtonType)buttonType
{
    blk cb;
    switch (buttonType) {
        case DropAlertButtonOK:
            successBlockCallback ? cb = successBlockCallback: nil;
            break;
        case DropAlertButtonFail:
            failureBlockCallback ? cb = failureBlockCallback: nil;
            break;
        case DropAlertNULL:
            cb = nil;
        default:
            break;
    }
    [UIView animateWithDuration:0.8f
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         CGRect screen = [self mainScreenFrame];
                         CATransform3D move = CATransform3DIdentity;
                         CGFloat initAlertViewYPosition = CGRectGetHeight(screen);
                         
                         move = CATransform3DMakeTranslation(0, initAlertViewYPosition, 0);
                         move = CATransform3DRotate(move, -40 * M_PI/180, 0, 0, 1.0f);
                         alertView.layer.transform = move;
                         
                         backgroundView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (cb) {
                             cb();
                         }
                         else if (self.delegate && [self.delegate respondsToSelector:@selector(alertViewDidDisappear:buttonType:)] && finished) {
                             [self.delegate alertViewDidDisappear:self buttonType:buttonType];
                         }
                     }];
    
}

#pragma mark - Button Methods
- (IBAction)pressAlertButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    DropAlertButtonType buttonType;
    BOOL blockFlag = false;
    
    if( [button isEqual:okButton] ) {
        LOG(@"Pressed Button is OkButton");
        buttonType = DropAlertButtonOK;
        if (successBlockCallback) {
            blockFlag = true;
        }
    }
    else {
        LOG(@"Pressed Button is CancelButton");
        buttonType = DropAlertButtonFail;
        if (failureBlockCallback) {
            blockFlag = true;
        }
    }
    
    if ( !blockFlag && [self.delegate respondsToSelector:@selector(alertViewPressButton:buttonType:)]) {
        [self.delegate alertViewPressButton:self buttonType:buttonType];
    }
    
    [self dismiss:buttonType];
    
}

#pragma mark - Util Methods
- (CGRect)mainScreenFrame
{
    return [UIScreen mainScreen].bounds;
}

- (void)setShadowLayer:(CALayer *)layer
{
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowRadius = 0.6;
    layer.shadowOpacity = 0.3;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end