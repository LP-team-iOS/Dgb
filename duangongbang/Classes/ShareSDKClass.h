//
//  ShareSDKClass.h
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/4.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯SDK
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK
#import "WXApi.h"
//新浪微博SDK
#import "WeiboSDK.h"

#define kDuangongbangUrl    @"http://www.duangongbang.com"

#define kShareSDKAppKey     @"64567549928a"

#define kWeiboAppKey        @"3885643280"
#define kWeiboAppSecret     @"852c32e2ec88bc3a5a19fca2ff6a9b5b"

#define kQQAppKey           @"1103394179"
#define kQQAppSecret        @"gB08taeAYw8wtdqb"

#define kWeChatAppId        @"wx6abdb6b28ecf7116"
#define kWeChatAppSecret    @"43ca2d2d7c17d80fc917a6414f8550d9"

@interface ShareSDKClass : NSObject
/**
 *  注册分享
 */
+ (void)shareSDKRegistApp;
/**
 *  分享事件
 *
 *  @param image 分享包含的图片
 *  @param text  分享的文字内容
 *  @param title 分享标题
 *  @param type  分享信息的类型
 */
+ (void)shareWithImage:(UIImage *)image contentText:(NSString *)text title:(NSString *)title type:(SSDKContentType )type view:(UIView *)view;

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
+ (void)shareWithImage:(UIImage *)image contentText:(NSString *)text title:(NSString *)title type:(SSDKContentType )type view:(UIView *)view url:(NSString *)url;

@end
