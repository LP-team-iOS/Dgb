/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "AppDelegate+EaseMob.h"
#import "LoginViewController.h"
#import "DirectAcceptedDetailViewController.h"
#import "ChatViewController.h"

#import "MessageViewController.h"
#import "SVProgressHUD.h"
/**
 *  本类中做了EaseMob初始化和推送等操作
 */

@implementation AppDelegate (EaseMob)


- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerRemoteNotification];
    
    
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = @"remotepush_prohjl";
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"duangongbang#duangongbang"
                                       apnsCertName:@"remotepush_prohjl"
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:@YES}];
    
    // 登录成功后，自动去取好友列表
    // SDK获取结束后，会回调
    // - (void)didFetchedBuddyList:(NSArray *)buddyList error:(EMError *)error方法。
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    // 注册环信监听
    [self registerEaseMobNotification];
    [[EaseMob sharedInstance] application:application
            didFinishLaunchingWithOptions:launchOptions];
    
    [self setupNotifiers];
    
    //        application.applicationIconBadgeNumber = 0;
    
    BmobUser *bUser = [BmobUser getCurrentUser];
    if (bUser) {
        if (launchOptions) {
            
            NSDictionary*userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
            if(userInfo)
            {
                //原有字段
                NSString *g = [userInfo objectForKey:@"g"];
                NSString *f = [userInfo objectForKey:@"f"];
                if (g) {
                    
                    [self jumpToGroupChat:g];
                }else if (f){
                    
                    [self jumpToConsultingChat:f];
                }
                
                //扩展字段
                //            NSDictionary *e = [userInfo objectForKey:@"e"];
                //            if (e) {
                //
                //                [self jumpToGroupChat:[e objectForKey:@"GroupId"]];
                //
                //            }
            }
            
        }
        //        else{
        //            UIApplication *application = [UIApplication sharedApplication];
        //
        //            NSString * message = [NSString stringWithFormat:@"no launch Options badge number : %li", (long)application.applicationIconBadgeNumber];
        //            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"launchOptions is  nil" message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
        //
        //            [alert show];
        //        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"您尚未登录！"];
    }
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //    application.applicationIconBadgeNumber = 0;
    
    //    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    //    if (state == UIApplicationStateBackground) {
    //        BmobUser *bUser = [BmobUser getCurrentUser];
    //        if (bUser) {
    //
    //            if(userInfo)
    //            {
    //                //原有字段
    //                NSString *g = [userInfo objectForKey:@"g"];
    //                NSString *f = [userInfo objectForKey:@"f"];
    //                if (g) {
    //
    //                    [self jumpToGroupChat:g];
    //                }else if (f){
    //                    [self jumpToConsultingChat:f];
    //                }
    //            }
    //
    //        }else{
    //            [SVProgressHUD showErrorWithStatus:@"您尚未登录！"];
    //        }
    //    }
    //    LOG(@" 收到推送消息 ： %@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    //    if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]!=NULL) {
    //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"短工邦"
    //                                                        message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"关闭"
    //                                              otherButtonTitles:@"确定",nil];
    //        [alert show];
    //    }
}

// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - Present
//跳转至邦邦客服
- (void)jumpToConsultingChat:(NSString *)chatter{
    BmobUser *bUser = [BmobUser getCurrentUser];
    if (bUser) {
        if (chatter) {
            
            ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter conversationType:eConversationTypeChat];
            chatVc.name = @"邦邦客服";
            chatVc.title = @"邦邦客服";
            BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
            chatVc.isSender_yes_headimage = headImg.url;
            chatVc.isMy_Nickname = [bUser objectForKey:@"Name"];
            if (self.window.rootViewController.presentedViewController) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            }
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVc];
            chatVc.isPresented = YES;
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"消息格式不正确！"];
            
        }
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"未登录，登录后进入邦邦客服查看消息。"];
    }
    
    
    
}

//跳转至群聊界面
- (void)jumpToGroupChat:(NSString *)groupId{
    if (groupId == nil) {
        return;
    }
    if (self.window.rootViewController.presentedViewController) {
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *updatedAtString = [dateFormatter stringFromDate:aSelfWork.updatedAt];
                NSDictionary *aDic = @{
                                               @"GroupId":[aSelfWork objectForKey:@"GroupId"],
                                               @"GroupOwnerId":[aSelfWork objectForKey:@"GroupOwnerId"],
                                               @"updatedAt":updatedAtString,
                                               @"Notice":[aSelfWork objectForKey:@"Notice"]
                                               };
                
                NSMutableDictionary *aSelfWorkDic = [aDic mutableCopy];
                NSDictionary *workDic = [aSelfWork objectForKey:@"Work"];
                DirectAcceptedDetailViewController *dadvc = [[DirectAcceptedDetailViewController alloc]init];
                dadvc.workTitle         = [workDic objectForKey:@"Title"];
                dadvc.selfWorkDic       = aSelfWorkDic;
                
                dadvc.workObjectId      = [workDic objectForKey:@"objectId"];
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:dadvc];
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
            }
        }
    }];
}



#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    
#warning 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    //    [alert show];
}

// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber = 0;
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes =  UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}



#pragma mark - IChatManagerDelegate
// 开始自动登录回调
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    //    UIAlertView *alertView = nil;
    if (error) {
        
        self.window.rootViewController = [LoginViewController new];
        
    }
    else{
        // 旧数据转换 (如果您的sdk是由2.1.2版本升级过来的，需要家这句话)
        //        [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
        //获取数据库中的数据
        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
    }
    
}

// 结束自动登录回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    
    
    LOG(@"结束自动登录回调");
    
    if (error) {
        
        self.window.rootViewController = [LoginViewController new];
        
    }else{
        // 旧数据转换 (如果您的sdk是由2.1.2版本升级过来的，需要家这句话)
        //        [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
        //获取数据库中的数据
        //        [[EaseMob sharedInstance].chatManager load];
    }
}

// 好友申请回调
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    //    if (!username) {
    //        return;
    //    }
    //    if (!message) {
    //        message = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), username];
    //    }
    //    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":username, @"username":username, @"applyMessage":message, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleFriend]}];
    //    [[ApplyViewController shareController] addNewApply:dic];
    //    if (self.mainController) {
    //        [self.mainController setupUntreatedApplyCount];
    //    }
}

// 离开群组回调
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSString *tmpStr = group.groupSubject;
    //    NSString *str;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    
    //    if (reason == eGroupLeaveReason_BeRemoved) {
    //        str = [NSString stringWithFormat:NSLocalizedString(@"group.beKicked", @"you have been kicked out from the group of \'%@\'"), tmpStr];
    //    }
    //    if (str.length > 0) {
    //        TTAlertNoTitle(str);
    //    }
}

// 申请加入群组被拒绝回调
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
                                       error:(EMError *)error{
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:reason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!groupId || !username) {
        return;
    }
    
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), username, groupname, reason];
    }
    
    //    if (error) {
    //        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.sendApplyFail", @"send application failure:%@\nreason：%@"), reason, error.description];
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    //        [alertView show];
    //    }
    //    else{
    //        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"title":groupname, @"groupId":groupId, @"username":username, @"groupname":groupname, @"applyMessage":reason, @"applyStyle":[NSNumber numberWithInteger:ApplyStyleJoinGroup]}];
    //        [[ApplyViewController shareController] addNewApply:dic];
    //        if (self.mainController) {
    //            [self.mainController setupUntreatedApplyCount];
    //        }
    //    }
}

// 已经同意并且加入群组后的回调
- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    if(error)
    {
        return;
    }
    
    NSString *groupTag = group.groupSubject;
    if ([groupTag length] == 0) {
        groupTag = group.groupId;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed and joined the group of \'%@\'"), groupTag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}


// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error
{
    //    if (error) {
    //        TTAlertNoTitle(NSLocalizedString(@"apns.failToBindDeviceToken", @"Fail to bind device token"));
    //    }
}

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    //    _connectionState = connectionState;
    //    [self.mainController networkChanged:connectionState];
}

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //    NSError *parseError = nil;
    //    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
    //                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    //    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
    //                                                    message:str
    //                                                   delegate:nil
    //                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
    //                                          otherButtonTitles:nil];
    //    [alert show];
    
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//
//    //    MessageViewController * mian = [[MessageViewController alloc] init];
//    //    if ([[self getCurrentVC] isEqual:mian]) {
//    //        return;
//    //    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"wtVersion"] isEqualToString:@"1"]) {
//
//        BmobUser * bUser = [ShareDataSource sharedDataSource].myData;
//
//        if ([notification.alertAction isEqualToString:kCustomerServiceChat]) {
//
//            ChatViewController * charview = [[ChatViewController alloc] init];
//            //
//            //        if ([[self getCurrentVC] isEqual:charview]) {
//            //            return;
//            //        }
//
//            charview.popTopush = @"1";
//            BmobFile *headImg = [bUser objectForKey:@"HeadImg"];
//            charview.isSender_yes_headimage = headImg.url;
//            charview.isMy_Nickname = [bUser objectForKey:@"Name"];
//
//
////            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:charview];
////            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
//            [[self getCurrentVC] presentViewController:charview animated:YES completion:nil];
//
//        }
//        else
//        {
//
//            DirectAcceptedDetailViewController *  DirectAcceptedDetail = [[DirectAcceptedDetailViewController alloc] init];
//            //
//            //        if ([[self getCurrentVC] isEqual:DirectAcceptedDetail]) {
//            //            return;
//            //        }
//
//            DirectAcceptedDetail.workObjectId = notification.alertTitle;
//            DirectAcceptedDetail.popTopush = @"2";
//            DirectAcceptedDetail.workTitle = notification.alertTitle;
//            DirectAcceptedDetail.workObjectId = notification.alertLaunchImage;
//            DirectAcceptedDetail.workOrderObjectId = notification.alertAction;
//            DirectAcceptedDetail.selfWorkDic = notification.userInfo;
//            [[self getCurrentVC] presentViewController:DirectAcceptedDetail animated:YES completion:nil];
//
//        }
//
//    }
        
        
        //    @"MessageType":kGroupChat,
        //    @"BmobUserName":self.isMy_Nickname,
        //    @"HeadImgUrl":self.isSender_yes_headimage,
        //    @"WorkTitle":self.isChatGroup_WorkTitle,
        //    @"SelfWorkNoticeContent":newNotice,
        //    @"GroupOwnerId":self.GroupOwnerId,
        //    @"SendedAt":timeString,
        
        //    @"WorkTitle":self.workTitle,
        //    @"SelfWorkDic":self.selfWorkDic,
        //    @"WorkOrderObjectId":self.workOrderObjectId,
        //    @"WorkObjectId":self.workObjectId

        
    
    if ([notification.alertTitle isEqualToString:@"wtbackgroundCmdMessage"]) {
        
        if (notification.userInfo.count > 4) {
            
            DirectAcceptedDetailViewController *  DirectAcceptedDetail = [[DirectAcceptedDetailViewController alloc] init];
            DirectAcceptedDetail.workObjectId = [notification.userInfo objectForKey:@"WorkObjectId"];
            DirectAcceptedDetail.workTitle = [notification.userInfo objectForKey:@"WorkTitle"];
            DirectAcceptedDetail.workOrderObjectId = [notification.userInfo objectForKey:@"WorkOrderObjectId"];
            DirectAcceptedDetail.selfWorkDic = [notification.userInfo objectForKey:@"SelfWorkDic"];
            [[self getCurrentVC] presentViewController:DirectAcceptedDetail animated:YES completion:nil];
        }
        else
        {
            [self jumpToGroupChatwt:notification.alertLaunchImage];
        }
    }
        
    }
    application.applicationIconBadgeNumber = 0;
}

//跳转至群聊界面
- (void)jumpToGroupChatwt:(NSString *)groupId{
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
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *updatedAtString = [dateFormatter stringFromDate:aSelfWork.updatedAt];
                    NSDictionary *aDic = @{
    @"GroupId":[aSelfWork objectForKey:@"GroupId"],
    @"GroupOwnerId":[aSelfWork objectForKey:@"GroupOwnerId"],
    @"updatedAt":updatedAtString,
    @"Notice":[aSelfWork objectForKey:@"Notice"]};

NSMutableDictionary *aSelfWorkDic = [aDic mutableCopy];
                NSDictionary *workDic = [aSelfWork objectForKey:@"Work"];
                
                
                DirectAcceptedDetailViewController *dadvc = [[DirectAcceptedDetailViewController alloc]init];
                dadvc.workTitle         = [workDic objectForKey:@"Title"];
                dadvc.selfWorkDic       = aSelfWorkDic;
                dadvc.workObjectId      = [workDic objectForKey:@"objectId"];
                [[self getCurrentVC]  presentViewController:dadvc animated:YES completion:nil];
            }
        }
    }];
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
    
}
@end
