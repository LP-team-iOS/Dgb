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

#import <UIKit/UIKit.h>
#import "EMChatManagerDefs.h"
#import "DirectAcceptedDetailViewController.h"

@protocol ChatCommand <NSObject>
- (void)wt_ChatCommand:(NSString *)noticeText timeString:(NSString *)timeString;
@end


@protocol ChatViewControllerDelegate <NSObject>

- (NSString *)avatarWithChatter:(NSString *)chatter;
- (NSString *)nickNameWithChatter:(NSString *)chatter;

@end

@interface ChatViewController : UIViewController



@property (nonatomic, assign) id <ChatCommand> ChatCommand_delelgate;


@property (strong, nonatomic, readonly) NSString *chatter;
@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (nonatomic) BOOL isInvisible;
@property (nonatomic, assign) id <ChatViewControllerDelegate> delelgate;
@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (strong, nonatomic) NSString *name;//聊天对象name
@property (strong, nonatomic) NSString *isSender_yes_headimage;//我的头像
@property (strong, nonatomic) NSString *isSender_no_headimage;//聊天对象头像
@property (strong, nonatomic) NSString *isMy_Nickname;//我的bmob名字

@property (strong, nonatomic) NSString *isChatGroup_WorkTitle;//工作标题
@property (strong, nonatomic) NSString *GroupOwnerId;//GroupOwnerId

@property (strong, nonatomic) NSString *popTopush;//GroupOwnerId
@property (strong, nonatomic) NSString *Consultingid;//GroupOwnerId
@property (nonatomic) BOOL isPresented;
//多人聊天

@property (nonatomic, strong) NSString *workTitle;
@property (nonatomic, strong) NSDictionary *selfWorkDic;
@property (nonatomic ,strong) NSString *workOrderObjectId;
@property (nonatomic ,strong) NSString *workObjectId;
//@property (nonatomic ,strong) NSString *motai;




- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;
- (instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)type;

- (void)reloadData;

- (void)hideImagePicker;

#pragma mark - sendMessage
-(void)sendTextMessage:(NSString *)textMessage;



-(void)sendImageMessage:(UIImage *)image;
//-(void)sendAudioMessage:(EMChatVoice *)voice;
//-(void)sendVideoMessage:(EMChatVideo *)video;
//-(void)sendLocationLatitude:(double)latitude
//                  longitude:(double)longitude
//                 andAddress:(NSString *)address;
-(void)addMessage:(EMMessage *)message;
- (EMMessageType)messageType;
#pragma mark - Methods

- (void)updateWorkGroupNotice:(NSString *)newNotice timeString:(NSString *)timeString;

@end
