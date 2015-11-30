//
//  AppDelegate.m
//  duangongbang
//
//  Created by ljx on 15/4/23.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "AppDelegate.h"
#import "DGBTabBarViewController.h"
#import "KMCGeigerCounter.h"
#import "Reachability.h"
#import "UIViewController+Swizzled.h"
#import <BmobSDK/Bmob.h>
#import "LoginViewController.h"
#import "GuideViewController.h"
#import "ShareSDKClass.h"
//#import "ChangeSystemFonts.h"
#import "SVProgressHUD.h"
#import "AppDelegate+EaseMob.h"


@interface AppDelegate ()
@property (strong, nonatomic) Reachability *hostReach;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//
    //开启网络状况的监听
    SWIZZ_IT;
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(reachabilityChanged:)
     
                                                 name: kReachabilityChangedNotification
     
                                               object: nil];
    
    self.hostReach = [Reachability reachabilityWithHostName:@"www.duangongbang.com"];//可以以多种形式初始化
    
    [self.hostReach startNotifier]; //开始监听,会启动一个run loop
    
    [self registerNotification];
    
    [ShareSDKClass shareSDKRegistApp];
    
    //[self updateInterfaceWithReachability:self.hostReach];
    //[ChangeSystemFonts load];
    
    NSString *key = (NSString *)kCFBundleVersionKey;
    NSString *version = [NSBundle mainBundle].infoDictionary[key];
    NSString *saveVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if ([version isEqualToString:saveVersion]) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor blackColor];
        UINavigationController *nvc = [[UINavigationController alloc] init];
        DGBTabBarViewController *dgbTBVC = [[DGBTabBarViewController alloc] init];
        [nvc pushViewController:dgbTBVC animated:NO];
        self.window.rootViewController = nvc;
    }else{
        [[NSUserDefaults  standardUserDefaults] setObject:version forKey:key];
        [[NSUserDefaults  standardUserDefaults] synchronize];
        GuideViewController *loginVC = [[GuideViewController alloc] init];
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.backgroundColor = [UIColor blackColor];
        self.window.rootViewController = loginVC;
    }
    
    // Override point for customization after application launch.
    //注册推送，iOS 8的推送机制与iOS 7有所不同，这里需要分别设置
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc]init];
        categorys.identifier=@"com.duangongbang.duangongbangpush";
        
        UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys,nil]];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
        //注册远程推送
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }

    [self.window makeKeyAndVisible];

     [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    [NSThread sleepForTimeInterval:2.0];//设置启动页面时间
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_VIDEO_OUTSIDE_VIEW object:nil];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 消息推送-Notifications
//      获取成功调用

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    //注册成功后上传Token至服务器
    BmobInstallation  *currentIntallation = [BmobInstallation currentInstallation];
    [currentIntallation setDeviceTokenFromData:deviceToken];
    [currentIntallation saveInBackground];
    LOG(@"deviceToken=== ===%@",deviceToken);
    //  将deviceToken进行去尖括号和去空格操作
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    NSString *dToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    LOG(@"token == %@",deviceToken);
    [USER_DEFAULT setObject:dToken forKey:DEVICE_TOKEN_KEY];
    [USER_DEFAULT synchronize];

}
//      获取失败调用
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    LOG(@"_________%@",error);
}

//      入口注册
- (void)registerNotification{
    //  iOS8以上注册方法
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc]init];
        categorys.identifier = @"com.duangongbang.duangongbang";
        
        UIUserNotificationSettings *userNotifiSetting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys,nil]];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotifiSetting];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }else {
        //注册远程推送
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    
}

#pragma mark - NetworkWithNotification
- (void)checkNetworkWithNotification:(NSNotification *)note{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    switch (status)
    {
            
        case NotReachable:
            break;
            
        case ReachableViaWiFi:
        case ReachableViaWWAN:
            break;
            
        case kReachableVia2G:
            break;
            
        case kReachableVia3G:
            break;
            
        case kReachableVia4G:
            break;
    }
}
// 连接改变

- (void)reachabilityChanged: (NSNotification*)note{
    
    Reachability *curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    [self updateInterfaceWithReachability:curReach];
    
}


//处理连接改变后的情况

- (void)updateInterfaceWithReachability: (Reachability*)curReach

{
    
    //对连接改变做出响应的处理动作。
    
    NetworkStatus status=[curReach currentReachabilityStatus];
    
    if (status== NotReachable) { //没有连接到网络就弹出提实况
        
//        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"短工邦"
//                             
//                                                       message:@"网络不可用，请检查网络连接！"
//                             
//                                                      delegate:nil
//                             
//                                             cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        
//        [alert show];

        [SVProgressHUD showErrorWithStatus:@"网络不可用，请检查网络连接！"];
        
    }
//    else if (status == kReachableVia2G){
//        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"短工邦"
//                             
//                                                       message:@"当前网络为2G！"
//                             
//                                                      delegate:nil
//                             
//                                             cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        
//        [alert show];
//    }else if (status == kReachableVia3G){
//        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"短工邦"
//                             
//                                                       message:@"当前网络为3G！"
//                             
//                                                      delegate:nil
//                             
//                                             cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        
//        [alert show];
//    }else if (status == kReachableVia4G){
//        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"短工邦"
//                             
//                                                       message:@"当前网络为4G！"
//                             
//                                                      delegate:nil
//                             
//                                             cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        
//        [alert show];
//    }else if (status == ReachableViaWiFi || status == ReachableViaWWAN){
//        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"短工邦"
//                             
//                                                       message:@"当前网络为Wifi！"
//                             
//                                                      delegate:nil
//                             
//                                             cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        
//        [alert show];
//    }
    
}

@end
