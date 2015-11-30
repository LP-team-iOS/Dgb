//
//  ShareSDKClass.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/4.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "ShareSDKClass.h"
#import "SVProgressHUD.h"

#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>

@implementation ShareSDKClass

+ (void)shareSDKRegistApp {
    
    [ShareSDK registerApp:kShareSDKAppKey activePlatforms:@[@(SSDKPlatformTypeWechat),@(SSDKPlatformTypeQQ),@(SSDKPlatformTypeSinaWeibo)] onImport:^(SSDKPlatformType platformType) {
        
        switch (platformType) {
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
            case SSDKPlatformTypeSinaWeibo:
                [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                break;
            default:
                break;
        }
        
    }onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo){
        
        
        switch (platformType)
        {
            case SSDKPlatformTypeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                [appInfo SSDKSetupSinaWeiboByAppKey:kWeiboAppKey
                                          appSecret:kWeiboAppSecret
                                        redirectUri:kDuangongbangUrl
                                           authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:kWeChatAppId
                                      appSecret:kWeChatAppSecret];
                break;
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:kQQAppKey
                                     appKey:kQQAppSecret
                                   authType:SSDKAuthTypeBoth];
                break;
            default:
                break;
        }
        
    }];
}

#pragma mark - 简单分享

/**
 *  分享
 *
 *  @param image 分享图片
 *  @param text  分享内容
 *  @param title 分享标题
 *  @param type  分享类型
 *  @param view  分享触发控件
 */

+ (void)shareWithImage:(UIImage *)image contentText:(NSString *)text title:(NSString *)title type:(SSDKContentType )type view:(UIView *)view {
    
    //创建分享参数
 
    
    NSArray* imageArray = @[image];
    
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:imageArray
                                            url:[NSURL URLWithString:kDuangongbangUrl]
                                          title:title
                                           type:type];
        
        //1.1、QQ空间不支持SSDKContentTypeImage这种类型，所以需要定制下。
        [shareParams SSDKSetupQQParamsByText:text
                                       title:title
                                         url:[NSURL URLWithString:kDuangongbangUrl]
                                  thumbImage:nil
                                       image:image
                                        type:SSDKContentTypeWebPage
                          forPlatformSubType:SSDKPlatformSubTypeQZone];
    //1.2、设置分享编辑页面样式（optional）
        
//        [SSUIEditorViewStyle setiPhoneNavigationBarBackgroundColor:UIColorFromRGB(xMainBlueColor)];
//        [SSUIEditorViewStyle setTitleColor:[UIColor whiteColor]];
//        [SSUIEditorViewStyle setShareButtonLabelColor:[UIColor whiteColor]];
//        [SSUIEditorViewStyle setCancelButtonLabelColor:[UIColor whiteColor]];
//        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:UIColorFromRGB(xMainBlueColor)];
    //    [SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //    [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
    //    [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor whiteColor]];
    //    [SSUIShareActionSheetStyle setItemNameColor:[UIColor whiteColor]];
    //    [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
    //    [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
//        [SSUIShareActionSheetStyle setPageIndicatorTintColor:UIColorFromRGB(xMainBlueColor)];
        //2、分享
        [ShareSDK showShareActionSheet:view
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                               
                           case SSDKResponseStateBegin:
                           {
//                               [theController showLoadingView:YES];
                               break;
                           }
                           case SSDKResponseStateSuccess:
                           {
                               [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                               {
                                   [SVProgressHUD showErrorWithStatus:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"];
                                   break;
                               }
                               else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                               {
                                   [SVProgressHUD showErrorWithStatus:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"];
                                   break;
                               }
                               else
                               {
                                   [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
                                   break;
                               }
                               break;
                           }
                           case SSDKResponseStateCancel:
                           {
                               [SVProgressHUD showErrorWithStatus:@"分享已取消"];
                               break;
                           }
                           default:
                               break;
                       }
                       
                       if (state != SSDKResponseStateBegin)
                       {
                           
                       }
                       
                   }];
        
    }
    
}
/**
 *  分享
 *
 *  @param image 分享图片
 *  @param text  分享内容
 *  @param title 分享标题
 *  @param type  分享类型
 *  @param view  分享触发控件
 *  @param url   点击分享的链接
 */
+ (void)shareWithImage:(UIImage *)image contentText:(NSString *)text title:(NSString *)title type:(SSDKContentType )type view:(UIView *)view url:(NSString *)url {
    //创建分享参数
    
    
    NSArray* imageArray = @[image];
    
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:type];
        
        //1.1、QQ空间不支持SSDKContentTypeImage这种类型，所以需要定制下。
        [shareParams SSDKSetupQQParamsByText:text
                                       title:title
                                         url:[NSURL URLWithString:url]
                                  thumbImage:nil
                                       image:image
                                        type:SSDKContentTypeWebPage
                          forPlatformSubType:SSDKPlatformSubTypeQZone];
        //1.2、设置分享编辑页面样式（optional）
        
//        [SSUIEditorViewStyle setiPhoneNavigationBarBackgroundColor:UIColorFromRGB(xMainBlueColor)];
//        [SSUIEditorViewStyle setTitleColor:[UIColor whiteColor]];
//        [SSUIEditorViewStyle setShareButtonLabelColor:[UIColor whiteColor]];
//        [SSUIEditorViewStyle setCancelButtonLabelColor:[UIColor whiteColor]];
        //        [SSUIShareActionSheetStyle setActionSheetBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        //    [SSUIShareActionSheetStyle setActionSheetColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
        //    [SSUIShareActionSheetStyle setCancelButtonBackgroundColor:[UIColor colorWithRed:21.0/255.0 green:21.0/255.0 blue:21.0/255.0 alpha:1.0]];
        //    [SSUIShareActionSheetStyle setCancelButtonLabelColor:[UIColor whiteColor]];
        //    [SSUIShareActionSheetStyle setItemNameColor:[UIColor whiteColor]];
        //    [SSUIShareActionSheetStyle setItemNameFont:[UIFont systemFontOfSize:10]];
        //    [SSUIShareActionSheetStyle setCurrentPageIndicatorTintColor:[UIColor colorWithRed:156/255.0 green:156/255.0 blue:156/255.0 alpha:1.0]];
        //        [SSUIShareActionSheetStyle setPageIndicatorTintColor:UIColorFromRGB(xMainBlueColor)];
        //2、分享
        [ShareSDK showShareActionSheet:view
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                               
                           case SSDKResponseStateBegin:
                           {
                               //                               [theController showLoadingView:YES];
                               break;
                           }
                           case SSDKResponseStateSuccess:
                           {
                               [SVProgressHUD showSuccessWithStatus:@"分享成功"];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                               {
                                   [SVProgressHUD showErrorWithStatus:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"];
                                   break;
                               }
                               else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                               {
                                   [SVProgressHUD showErrorWithStatus:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"];
                                   break;
                               }
                               else
                               {
                                   [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
                                   break;
                               }
                               break;
                           }
                           case SSDKResponseStateCancel:
                           {
                               [SVProgressHUD showErrorWithStatus:@"分享已取消"];
                               break;
                           }
                           default:
                               break;
                       }
                       
                       if (state != SSDKResponseStateBegin)
                       {
                           
                       }
                       
                   }];
        
    }
}

@end
