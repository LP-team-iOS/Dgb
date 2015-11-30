
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

#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "EMAlertView.h"
#import "SRRefreshView.h"
#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "MessageModelManager.h"
#import "LocationViewController.h"

#import "UIViewController+HUD.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "ChatViewController+Category.h"
//#import "ChatroomDetailViewController.h"
#import "EMCDDeviceManager.h"
#import "EMCDDeviceManagerDelegate.h"
#import "ConsultingViewController.h"
#import "DirectSupportAcceptedViewController.h"
#import "MainViewController.h"
//#import "EaseMob.h"

#define kThinToolBarHeight 32.5
#define KPageCount 20
#define KHintAdjustY    50
//LocationViewDelegate
@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SRRefreshDelegate, IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, EMCDDeviceManagerDelegate ,UIGestureRecognizerDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    
    NSMutableArray *_messages;
    BOOL _isScrollToBottom;
    
    NSString * context_wt;
}

@property (nonatomic) BOOL isChatGroup;

@property (nonatomic) EMConversationType conversationType;

@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isRobot;


#pragma mark - 送岗专区群聊
@property (nonatomic, strong) UIView *thinToolBar;

@end

@implementation ChatViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    EMConversationType type = isGroup ? eConversationTypeGroupChat : eConversationTypeChat;
    self = [self initWithChatter:chatter conversationType:type];
    if (self) {
    }
    
    return self;
}

- (instancetype)initWithChatter:(NSString *)chatter conversationType:(EMConversationType)type
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self) {
        _isPlayingAudio = NO;
        _chatter = chatter;
        _conversationType = type;
        _messages = [NSMutableArray array];
        //根据接收者的username获取当前会话的管理者
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:type];
        [_conversation markAllMessagesAsRead:YES];
    }
    
    return self;
}

- (BOOL)isChatGroup
{
    return _conversationType != eConversationTypeChat;
}

- (void)saveChatroom:(EMChatroom *)chatroom
{
    NSString *chatroomName = chatroom.chatroomSubject ? chatroom.chatroomSubject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId])
    {
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

- (void)joinChatroom:(NSString *)chatroomId
{
    [self showHudInView:self.view hint:NSLocalizedString(@"chatroom.joining",@"Joining the chatroom")];
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncJoinChatroom:chatroomId completion:^(EMChatroom *chatroom, EMError *error){
        if (weakSelf)
        {
            ChatViewController *strongSelf = weakSelf;
            [strongSelf hideHud];
            if (error && (error.errorCode != EMErrorChatroomJoined))
            {
                [strongSelf showHint:[NSString stringWithFormat:@"加入聊天室\'%@\'失败", chatroomId]];
            }
            else
            {
                [strongSelf saveChatroom:chatroom];
            }
        }
        else
        {
            if (!error || (error.errorCode == EMErrorChatroomJoined))
            {
                [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatroomId completion:^(EMChatroom *chatroom, EMError *error){
                    [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatroomId deleteMessages:YES append2Chat:YES];
                }];
            }
        }
    }];
}

#warning  back -------

- (void)back
{
       [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerBecomeActive];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = RGB(38, 40, 52, 1.0);
    

    self.navigationItem.title = self.name;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    [self.navigationItem setHidesBackButton:YES animated:NO];
    
//    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"detailBackIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        [self.navigationItem setLeftBarButtonItem:backItem];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
    }
    
    
#warning 以下三行代码必须写，注册为SDK的ChatManager的delegate
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    
    
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appHasGoneInForeground)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
    
    
    
    
    //别忘了删除监听
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    _isScrollToBottom = YES;
    
    [self setupBarButtonItem];
    
    _isChatGroup = [self isChatGroup];
    if (_isChatGroup) {
        [self.view addSubview:[self thinToolBar]];
    }

    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.chatToolBar];
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    //通过会话管理者获取已收发消息
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:KPageCount append:NO];
    

    if (_conversationType == eConversationTypeChatRoom)
    {
        [self joinChatroom:_chatter];
    }
    
}




- (void)setupBarButtonItem
{
//    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [backButton setImage:[UIImage imageNamed:@"detailBackIcon"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"detailBackIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
//    [self.navigationItem setLeftBarButtonItem:backItem];
//    [self.navigationItem setHidesBackButton:YES animated:NO];

//    if (self.isChatGroup) {
//        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//        [detailButton setImage:[UIImage imageNamed:@"detailBackIcon"] forState:UIControlStateNormal];
//        [detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
//    }
//    else{
//        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
//        [clearButton addTarget:self action:@selector(removeAllMessages:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    if (_isScrollToBottom) {
        [self scrollViewToBottom:NO];
    }
    else{
        _isScrollToBottom = YES;
    }
    self.isInvisible = NO;
    
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    self.isInvisible = YES;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _slimeView.delegate = nil;
    _slimeView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#warning 以下第一行代码必须写，将self从ChatManager的代理中移除
    [[EaseMob sharedInstance].chatManager removeDelegate:self];

    if (_conversation.conversationType == eConversationTypeChatRoom && !_isKicked)
    {
        //退出聊天室，删除会话
        NSString *chatter = [_chatter copy];
        [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatter completion:^(EMChatroom *chatroom, EMError *error){
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:YES append2Chat:YES];
        }];
    }
    
    if (_imagePicker)
    {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
    }
}

//- (void)back
//{
//    //判断当前会话是否为空，若符合则删除该会话
//    EMMessage *message = [_conversation latestMessage];
//    if (message == nil) {
//        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
//    }
//    
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)setIsInvisible:(BOOL)isInvisible
{
    _isInvisible =isInvisible;
    if (!_isInvisible)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messages)
        {
            if ([self shouldAckMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

#pragma mark - getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        
        CGFloat topOfTableView = 0;
        if (_isChatGroup) {
            topOfTableView = 64 + kThinToolBarHeight;
        }
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topOfTableView, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height - topOfTableView+2) style:UITableViewStylePlain];        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGBACOLOR(235, 235, 235, 1.0);//(248, 248, 248, 1);
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        
        ChatMoreType type = self.isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) type:type];
        _chatToolBar.moreView.backgroundColor = RGBACOLOR(240, 242, 247, 1);
        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
       
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

- (NSDate *)chatTagDate
{
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else{
            MessageModel *model = (MessageModel *)obj;
//            NSLog(@"%@",model);
//            model.image = [UIImage imageNamed:@"注册.png"];
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.name_wt.text = model.allname;
//            [cell.name_wt sizeToFit];
            if (model.isSender) {
                model.headImageURL = [NSURL URLWithString:self.isSender_yes_headimage];
                cell.name_wt.textAlignment = NSTextAlignmentRight;
                cell.name_wt.frame = CGRectMake(20, 0, self.view.frame.size.width - 37, 15);
            }
            else
            {
                model.headImageURL = [NSURL URLWithString:model.otherimageURL];//[NSURL URLWithString:self.isSender_no_headimage];
                cell.name_wt.textAlignment = NSTextAlignmentLeft;
                cell.name_wt.frame = CGRectMake(10, 0, self.view.frame.size.width - 20, 15);
            }
//
            cell.messageModel = model;
            
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    }
    else{
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    _chatTagDate = nil;
    EMMessage *firstMessage = [self.messages firstObject];
    if (firstMessage)
    {
        [self loadMoreMessagesFrom:firstMessage.timestamp count:KPageCount append:YES];
    }
    [_slimeView endRefresh];
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

- (void)reloadData{
    _chatTagDate = nil;
    self.dataSource = [[self formatMessages:self.messages] mutableCopy];
    [self.tableView reloadData];
    
    //回到前台时
    if (!self.isInvisible)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messages)
        {
            if ([self shouldAckMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        if ((messageModel.status != eMessageDeliveryState_Failure) && (messageModel.status != eMessageDeliveryState_Pending))
        {
            return;
        }
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
        [self chatVideoCellPressed:model];
    }else if ([eventName isEqualToString:kRouterEventMenuTapEventName]) {
        [self sendTextMessage:[userInfo objectForKey:@"text"]];
    }else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]) {
        [self chatHeadImagePressed:model];
    }
}
#pragma mark - 跳到用户资料详情界面
- (void)chatHeadImagePressed:(MessageModel *)model
{
//    UserProfileViewController *userprofile = [[UserProfileViewController alloc] initWithUsername:model.username];
//    [self.navigationController pushViewController:userprofile animated:YES];
}

//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model
{
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
//
        [self showHint:@"正在下载语音，稍后点击"];

        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        //发送已读回执
        if ([self shouldAckMessage:model.message read:YES])
        {
            [self sendHasReadResponseForMessages:@[model.message]];
        }
        __weak ChatViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak ChatViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.chatVoice.localPath completion:^(NSError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

// 位置的bubble被点击
-(void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatVideoCellPressed:(MessageModel *)model
{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.messageBody;
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
        if (localPath && localPath.length > 0)
        {
            //发送已读回执
            if ([self shouldAckMessage:model.message read:YES])
            {
                [self sendHasReadResponseForMessages:@[model.message]];
            }
            [self playVideoWithVideoPath:localPath];
            return;
        }
    }
    
    __weak ChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHudInView:weakSelf.view hint:@"正在获取视频..."];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            //发送已读回执
            if ([weakSelf shouldAckMessage:model.message read:YES])
            {
                [weakSelf sendHasReadResponseForMessages:@[model.message]];
            }
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHint:@"获取视频失败"];
        }
        
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model
{
    __weak ChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                //发送已读回执
                if ([self shouldAckMessage:model.message read:YES])
                {
                    [self sendHasReadResponseForMessages:@[model.message]];
                }
                NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    self.isScrollToBottom = NO;
                    if (image)
                    {
                        [self.messageReadManager showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return ;
                }
            }
            [weakSelf showHudInView:weakSelf.view hint:@"正在获取大图"];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    //发送已读回执
                    if ([weakSelf shouldAckMessage:model.message read:YES])
                    {
                        [weakSelf sendHasReadResponseForMessages:@[model.message]];
                    }
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            [weakSelf.messageReadManager showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [weakSelf showHint:@"获取大图失败"];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"获取缩略图失败"];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"获取缩略图失败"];
                }
            } onQueue:nil];
        }
    }
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}

- (void)didReceiveHasReadResponse:(EMReceipt*)receipt
{
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isReadAcked = YES;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    MessageModel *model = (MessageModel *)object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        if ([self->_delelgate respondsToSelector:@selector(nickNameWithChatter:)]) {
                            NSString *showName = [self->_delelgate nickNameWithChatter:model.username];
                            cellModel.nickName = showName?showName:cellModel.username;
                        }else {
                            cellModel.nickName = cellModel.username;
                        }
                        
                        if ([self->_delelgate respondsToSelector:@selector(avatarWithChatter:)]) {
                            cellModel.headImageURL = [NSURL URLWithString:[self->_delelgate avatarWithChatter:cellModel.username]];
                        }
                        
                        //Demo集成Parse,获取用户个人信息
//                        UserProfileEntity *user = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.username];
//                        
//                        if (user && user.imageUrl.length > 0) {
//                            model.headImageURL = [NSURL URLWithString:user.imageUrl];
//                        }
//                        
//                        if (user && user.nickname.length > 0) {
//                            model.nickName = user.nickname;
//                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                        });
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
//    NSLog(@"didFetchingMessageAttachment: %f", progress);
}
#warning 解析在线消息 ------------------
-(void)didReceiveMessage:(EMMessage *)message
{
    
//    Printing description of message:
//    {"messageId":"127022326423224844","messageType":0,"from":"1c7fa6854c","bodies":["{\"type\":\"txt\",\"msg\":\"txt\"}"],"ext":{"DGBMessage":{"MessageType":"CustomerServiceChat","HeadImgUrl":"http://file.bmob.cn/M02/35/F9/oYYBAFYolOmAFz6NAABprdtBOu4286.jpg","Content":"嘎嘎嘎嘎","BmobUserName":"邦邦客服"}},"isAcked":false,"to":"18770072566","timestamp":1447139490055,"requireEncryption":false}
    
//    NSDictionary *di = [NSDictionary dictionaryWithDictionary:message];
    
//    context_wt = []
    
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessage:message];
        if ([self shouldAckMessage:message read:NO])
        {
            [self sendHasReadResponseForMessages:@[message]];
        }
        if ([self shouldMarkMessageAsRead])
        {
            [self markMessagesAsRead:@[message]];
        }
    }
    
    
    BOOL needShowNotification = (message.messageType != eMessageTypeChat) ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        
        //        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        //        if (!isAppActivity) {
        //            [self showNotificationWithMessage:message];
        //        }else {
        //            [self playSoundAndVibration];
        //        }
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        switch (state) {
            case UIApplicationStateActive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateInactive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateBackground:
                [self showNotificationWithMessage:message];
                break;
            default:
                break;
        }
#endif
    }

}
- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    return ret;
}
- (void)playSoundAndVibration{
    
    //    NSTimeInterval timeInterval = [[NSDate date]
    //                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    //    if (timeInterval < kDefaultPlaySoundInterval) {
    //        //如果距离上次响铃和震动时间太短, 则跳过响铃
    //        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    //        return;
    //    }
    //
    //    //保存最后一次响铃时间
    //    self.lastPlaySoundDate = [NSDate date];
    //
    //    // 收到消息时，播放音频
//        [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    //    // 收到消息时，震动
//        [[EMCDDeviceManager sharedInstance] playVibration];
}
- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
   UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType)
        {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
    }
    //        NSString *title = [[UserProfileManager sharedInstance] getNickNameWithUsername:message.from];
    //        if (message.messageType == eMessageTypeGroupChat) {
    //            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    //            for (EMGroup *group in groupArray) {
    //                if ([group.groupId isEqualToString:message.conversationChatter]) {
    //                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
    //                    break;
    //                }
    //            }
    //        }
    //        else if (message.messageType == eMessageTypeChatRoom)
    //        {
    //            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
    //            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    //            NSString *chatroomName = [chatrooms objectForKey:message.conversationChatter];
    //            if (chatroomName)
    //            {
    //                title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, chatroomName];
    //            }
    //        }
    //
    //        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    //    }
    //    else{
    //        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    //    }
    //    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    
    
    
//    NSDictionary * t;
//    if(self.isChatGroup)
//    {
//        t = @{@"MessageType":kGroupChat,@"BmobUserName":self.isMy_Nickname,@"HeadImgUrl":self.isSender_yes_headimage,@"WorkTitle":self.isChatGroup_WorkTitle,@"Content":textMessage,@"GroupOwnerId":self.GroupOwnerId,@"SendedAt":timeString};
//    }
//    else
//    {
//        t = @{@"MessageType":kCustomerServiceChat,@"BmobUserName":self.isMy_Nickname,@"HeadImgUrl":self.isSender_yes_headimage,@"Content":textMessage,@"SendedAt":timeString};
//    }
    
    
    
    //    MessageModel *model = (MessageModel *)self.dataSource.lastObject;
    
    //    notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    
    if ([[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"MessageType"] isEqualToString:kGroupChat])
    {
//        notification.alertTitle = self.workTitle;
//        notification.alertAction = self.workOrderObjectId;
//        notification.alertLaunchImage = self.workObjectId;
//        
//        notification.userInfo = self.selfWorkDic;
        notification.alertBody = [[NSString alloc] initWithFormat:@"[%@]%@:%@",[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"WorkTitle"], [[message.ext objectForKey:@"DGBMessage"] objectForKey:@"BmobUserName"],[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"Content"]];
    }
    else
    {
    notification.alertBody = [[NSString alloc] initWithFormat:@"[客服]%@:%@", [[message.ext objectForKey:@"DGBMessage"] objectForKey:@"BmobUserName"],[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"Content"]];
//        notification.alertAction = kCustomerServiceChat;
//        notification.alertTitle = self.Consultingid;
    }
    
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    //    if (timeInterval < kDefaultPlaySoundInterval) {
    //        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    //    } else {
    //        notification.soundName = UILocalNotificationDefaultSoundName;
    //        self.lastPlaySoundDate = [NSDate date];
    //    }
    
    //    NSLog(@"%d",self.dataSource.count);
    //    NSLog(@"%@",self.isMy_Nickname);
    //    NSLog(@"%@",model.allname);
    
    //    MessageModel *model1 = (MessageModel *)self.dataSource[self.dataSource.count - 1];
    
    //    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    //    [userInfo setObject:[NSNumber numberWithInt:message.messageType] forKey:kMessageType];
    //    [userInfo setObject:message.conversationChatter forKey:kConversationChatter];
    //    notification.userInfo = userInfo;
    if ([[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"BmobUserName"] isEqualToString:self.isMy_Nickname]) {
    }
    else
    {
        
        static int num = 0;
        num ++;
        if (num == 3)
        {
            num = 0;
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    //发送通知
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#warning didReceiveCmdMessage

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    
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
    
    if (message.timestamp) {
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateStyle:NSDateFormatterMediumStyle];
//            [formatter setTimeStyle:NSDateFormatterShortStyle];
//            NSMutableDictionary *abbs = [[NSMutableDictionary alloc] init];
//            [abbs setValuesForKeysWithDictionary:[NSTimeZone abbreviationDictionary]];
//            [abbs setValue:@"Asia/Shanghai" forKey:@"CCD"];
//            [NSTimeZone setAbbreviationDictionary:abbs];
//            [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
//            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:message.timestamp];
//            NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
//        [[message.ext objectForKey:@"DGBMessage"] objectForKey:@"SendedAt"];
        
        NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a = [dat timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%.f", a];//转为字符型
        
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            NSMutableDictionary *abbs = [[NSMutableDictionary alloc] init];
            [abbs setValuesForKeysWithDictionary:[NSTimeZone abbreviationDictionary]];
            [abbs setValue:@"Asia/Shanghai" forKey:@"CCD"];
            [NSTimeZone setAbbreviationDictionary:abbs];
            [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
            NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeString integerValue]];
            NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

        [[message.ext objectForKey:@"DGBMessage"] setValue:confromTimespStr forKey:@"SendedAt"];
    }
    
    
    
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self.ChatCommand_delelgate wt_ChatCommand:[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"SelfWorkNoticeContent"] timeString:[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"SendedAt"]];
        
        UIApplicationState state1 = [[UIApplication sharedApplication] applicationState];
        switch (state1) {
            case UIApplicationStateActive:
                [self onlinemessage:message];
                break;
            case UIApplicationStateInactive:
                [self onlinemessage:message];
                break;
            case UIApplicationStateBackground:
                [self backgroundmessage:message];
                break;
            default:
                break;
        }
    }
}
//onlinemessage
- (void)onlinemessage:(EMMessage *)message
{
//    [self showHint:[NSString stringWithFormat:@"[%@]公告:%@",[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"WorkTitle"],[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"SelfWorkNoticeContent"]]];
  [self showHint:[NSString stringWithFormat:@"[%@]公告更新啦",[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"WorkTitle"]]];

}
//backgroundmessage
- (void)backgroundmessage:(EMMessage *)message
{
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    notification.alertTitle = @"wtbackgroundCmdMessage";
    notification.alertBody = [NSString stringWithFormat:@"[%@]公告:%@",[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"WorkTitle"],[[message.ext objectForKey:@"DGBMessage"] objectForKey:@"SelfWorkNoticeContent"]];
    notification.userInfo = [message.ext objectForKey:@"DGBMessage"];
    notification.alertLaunchImage = message.messageId;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}




- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [_conversation.chatter isEqualToString:conversationChatter]) {
        
        __weak ChatViewController *weakSelf = self;
        for (int i = 0; i < self.dataSource.count; i ++) {
            id object = [self.dataSource objectAtIndex:i];
            if ([object isKindOfClass:[MessageModel class]]) {
                MessageModel *currentModel = [self.dataSource objectAtIndex:i];
                EMMessage *currMsg = [currentModel message];
                if ([messageId isEqualToString:currMsg.messageId]) {
                    currMsg.deliveryState = eMessageDeliveryState_Failure;
                    MessageModel *cellModel = [MessageModelManager modelWithMessage:currMsg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView beginUpdates];
                        [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView endUpdates];
                        
                    });
                    
                    if (error && error.errorCode == EMErrorMessageContainSensitiveWords)
                    {
                        CGRect frame = self.chatToolBar.frame;
                        [self showHint:@"您的消息包含不当言论" yOffset:-frame.size.height + KHintAdjustY];
                    }
                    break;
                }
            }
        }
    }
}


- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if (![offlineMessages count])
    {
        return;
    }
    if ([self shouldMarkMessageAsRead])
    {
        [_conversation markAllMessagesAsRead:YES];
    }
    _chatTagDate = nil;
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:[self.messages count] + [offlineMessages count] append:NO];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (self.isChatGroup && [group.groupId isEqualToString:_chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
    [self stopAudioPlayingWithChangeCategory:YES];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error
{
    if (!error && self.isChatGroup && [_chatter isEqualToString:group.groupId])
    {
        self.title = group.groupSubject;
    }
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)didRemovedFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
    // 隐藏键盘
    [self keyBoardHidden];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    self.isInvisible = YES;
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
//    [self keyBoardHidden];
//    
//#if TARGET_IPHONE_SIMULATOR
//    [self showHint:@"模拟器不支持拍照"];
//#elif TARGET_OS_IPHONE
//    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
//    [self presentViewController:self.imagePicker animated:YES completion:NULL];
//    self.isInvisible = YES;
//#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
//    // 隐藏键盘
//    [self keyBoardHidden];
//    
//    LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
//    locationController.delegate = self;
//    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:@{@"chatter":self.chatter, @"type":[NSNumber numberWithInt:eCallSessionTypeAudio]}];
}

- (void)moreViewVideoCallAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter" object:@{@"chatter":self.chatter, @"type":[NSNumber numberWithInt:eCallSessionTypeVideo]}];
}

#pragma mark - LocationViewDelegate

-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
//    NSDictionary *ext = nil;
//    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter messageType:[self messageType] requireEncryption:NO ext:ext];
//    [self addMessage:locationMessage];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
//    [UIView animateWithDuration:0.3 animations:^{
    CGRect rect = self.tableView.frame;
    rect.origin.y = _isChatGroup? (64 + kThinToolBarHeight):0;
    rect.size.height = self.view.frame.size.height - toHeight - (_isChatGroup? (64 + kThinToolBarHeight - 2):-2);
    self.tableView.frame = rect;
//    }];
    [self scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

/**
 *  按下录音按钮开始录音
 */
//- (void)didStartRecordingVoiceAction:(UIView *)recordView
//{
//    if ([self canRecord]) {
//        DXRecordView *tmpView = (DXRecordView *)recordView;
//        tmpView.center = self.view.center;
//        [self.view addSubview:tmpView];
//        [self.view bringSubviewToFront:recordView];
//        int x = arc4random() % 100000;
//        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
//
//        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
//                                                                 completion:^(NSError *error)
//         {
//             if (error) {
////                 NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
//             }
//         }];
//    }
//}

/**
 *  手指向上滑动取消录音
 */
//- (void)didCancelRecordingVoiceAction:(UIView *)recordView
//{
//    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
//}

/**
 *  松开手指完成录音
 */
//- (void)didFinishRecoingVoiceAction:(UIView *)recordView
//{
//    __weak typeof(self) weakSelf = self;
//    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
//        if (!error) {
//            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
//                                                       displayName:@"audio"];
//            voice.duration = aDuration;
//            [weakSelf sendAudioMessage:voice];
//        }else {
//            [weakSelf showHint:@"说话时间太短"];
//            weakSelf.chatToolBar.recordButton.enabled = NO;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf hideHud];
//                weakSelf.chatToolBar.recordButton.enabled = YES;
//            });
//        }
//    }];
//}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    NSString *mediaType = info[UIImagePickerControllerMediaType];
//    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
//        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
//        [picker dismissViewControllerAnimated:YES completion:^{
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
//        }];
//        // video url:
//        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
//        // we will convert it to mp4 format
//        NSURL *mp4 = [self convert2Mp4:videoURL];
//        NSFileManager *fileman = [NSFileManager defaultManager];
//        if ([fileman fileExistsAtPath:videoURL.path]) {
//            NSError *error = nil;
//            [fileman removeItemAtURL:videoURL error:&error];
//            if (error) {
//
//            }
//        }
//        EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
//        [self sendVideoMessage:chatVideo];
//        
//    }else{
//        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
//        [picker dismissViewControllerAnimated:YES completion:^{
//            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
//        }];
//        [self sendImageMessage:orgImage];
//    }
//    self.isInvisible = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isShowPicker"];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.isInvisible = NO;
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
        [_conversation removeMessage:model.message];
        [self.messages removeObject:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:_longPressIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataSource removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    _longPressIndexPath = nil;
}

#pragma mark - private

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    NSIndexPath *indexPath = nil;
    if (playingModel) {
        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    }
    
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}

- (void)loadMoreMessagesFrom:(long long)timestamp count:(NSInteger)count append:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];
        if ([messages count] > 0) {
            NSInteger currentCount = 0;
            if (append)
            {
                [weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                NSArray *formated = [weakSelf formatMessages:messages];
                id model = [weakSelf.dataSource firstObject];
                if ([model isKindOfClass:[NSString class]])
                {
                    NSString *timestamp = model;
                    [formated enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                        if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                        {
                            [weakSelf.dataSource removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                currentCount = [weakSelf.dataSource count];
                [weakSelf.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                EMMessage *latest = [weakSelf.messages lastObject];
                weakSelf.chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)latest.timestamp];
            }
            else
            {
                weakSelf.messages = [messages mutableCopy];
                weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
            
            //从数据库导入时重新下载没有下载成功的附件
            for (EMMessage *message in messages)
            {
                [weakSelf downloadMessageAttachments:message];
            }
            
            NSMutableArray *unreadMessages = [NSMutableArray array];
            for (NSInteger i = 0; i < [messages count]; i++)
            {
                EMMessage *message = messages[i];
                if ([self shouldAckMessage:message read:NO])
                {
                    [unreadMessages addObject:message];
                }
            }
            if ([unreadMessages count])
            {
                [self sendHasReadResponseForMessages:unreadMessages];
            }
        }
    });
}

- (void)downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:@"获取缩略图失败"];
        }
    };
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if ([messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.attachmentDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
        }
    }
}

- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            if ([_delelgate respondsToSelector:@selector(nickNameWithChatter:)]) {
                NSString *showName = [_delelgate nickNameWithChatter:model.username];
                model.nickName = showName?showName:model.username;
            }else {
                model.nickName = model.username;
            }
            
            if ([_delelgate respondsToSelector:@selector(avatarWithChatter:)]) {
                model.headImageURL = [NSURL URLWithString:[_delelgate avatarWithChatter:model.username]];
            }
            
            //Demo集成Parse,获取用户个人信息
//            UserProfileEntity *user = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.username];
//            
//            if (user && user.imageUrl.length > 0) {
//                model.headImageURL = [NSURL URLWithString:user.imageUrl];
//            }
//            
//            if (user && user.nickname.length > 0) {
//                model.nickName = user.nickname;
//            }
            
            if (model) {
                [formatArray addObject:model];
            }
        }
    }
    
    return formatArray;
}

-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    
//    model.content =
    
    if ([_delelgate respondsToSelector:@selector(nickNameWithChatter:)]) {
        NSString *showName = [_delelgate nickNameWithChatter:model.username];
        model.nickName = showName?showName:model.username;
    }else {
        model.nickName = model.username;
    }
    
    if ([_delelgate respondsToSelector:@selector(avatarWithChatter:)]) {
        model.headImageURL = [NSURL URLWithString:[_delelgate avatarWithChatter:model.username]];
    }
    
    //Demo集成Parse,获取用户个人信息
//    UserProfileEntity *user = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.username];
//    
//    if (user && user.imageUrl.length > 0) {
//        model.headImageURL = [NSURL URLWithString:user.imageUrl];
//    }
//    
//    if (user && user.nickname.length > 0) {
//        model.nickName = user.nickname;
//    }

    if (model) {
        [ret addObject:model];
    }
    
    return ret;
}

-(void)addMessage:(EMMessage *)message
{
    [_messages addObject:message];
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.dataSource addObjectsFromArray:messages];
            
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (void)showRoomContact:(id)sender
{
    [self.view endEditing:YES];
//    if (self.conversationType == eConversationTypeGroupChat) {
//        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:_chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
//    }
//    else if (self.conversationType == eConversationTypeChatRoom)
//    {
//        ChatroomDetailViewController *detailController = [[ChatroomDetailViewController alloc] initWithChatroomId:_chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
//    }
}

- (void)removeAllMessages:(id)sender
{
    if (_dataSource.count == 0) {
        [self showHint:@"没有消息"];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        if (self.isChatGroup && [groupId isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_messages removeAllObjects];
            _chatTagDate = nil;
            [_dataSource removeAllObjects];
            [_tableView reloadData];
            [self showHint:@"没有消息"];
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        
        [EMAlertView showAlertWithTitle:@"提示"
                                message:@"请确定删除"
                        completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                            if (buttonIndex == 1) {
                                [weakSelf.conversation removeAllMessages];
                                [weakSelf.messages removeAllObjects];
                                weakSelf.chatTagDate = nil;
                                [weakSelf.dataSource removeAllObjects];
                                [weakSelf.tableView reloadData];
                            }
                        } cancelButtonTitle:@"取消"
                      otherButtonTitles:@"删除", nil];
    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"拷贝" action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessage:message];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
    }
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }



}

- (BOOL)shouldMarkMessageAsRead
{
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
    {
        return NO;
    }
    
    return YES;
}

- (EMMessageType)messageType
{
    EMMessageType type = eMessageTypeChat;
    switch (_conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

#pragma mark - public

- (void)hideImagePicker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.isInvisible = NO;
}

#pragma mark - send message

#warning 这里要改客服消息格式：DGBMessage:{"MessageType":"","BmobUserName":"","HeadImgUrl":"","Content":""}：MessageType":"GroupChat/CustomerServiceChat/SelfWorkNotice/Other"


-(void)sendTextMessage:(NSString *)textMessage
{
//    NSDictionary *ext = nil;
    
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", a];//转为字符型
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    NSMutableDictionary *abbs = [[NSMutableDictionary alloc] init];
//    [abbs setValuesForKeysWithDictionary:[NSTimeZone abbreviationDictionary]];
//    [abbs setValue:@"Asia/Shanghai" forKey:@"CCD"];
//    [NSTimeZone setAbbreviationDictionary:abbs];
//    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timeString integerValue]];
//    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

    NSDictionary * t;
    NSDictionary *text;
    if(self.isChatGroup)
    {
        t = @{
              @"MessageType":kGroupChat,
              @"BmobUserName":self.isMy_Nickname,
              @"HeadImgUrl":self.isSender_yes_headimage,
              @"WorkTitle":self.isChatGroup_WorkTitle,
              @"Content":textMessage,
              @"GroupOwnerId":self.GroupOwnerId,
              @"SendedAt":timeString
              };
        NSString *str = [NSString stringWithFormat:@"%@\n%@:%@",self.name, self.isMy_Nickname, textMessage];
        text = [NSDictionary dictionaryWithObjectsAndKeys:
                t,@"DGBMessage",
                @{@"GroupId":self.chatter, @"em_push_title":str},@"em_apns_ext",
                nil];
    }
    else
    {
        t = @{
              @"MessageType":kCustomerServiceChat,
              @"BmobUserName":self.isMy_Nickname,
              @"HeadImgUrl":self.isSender_yes_headimage,
              @"Content":textMessage,
              @"SendedAt":timeString
              };
        text = [NSDictionary dictionaryWithObjectsAndKeys:
                t,@"DGBMessage",
                nil];
    }

    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:_conversation.chatter
                                                           messageType:[self messageType]
                                                     requireEncryption:NO
                                                                   ext:text];
    [self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)image
{
//    NSDictionary *ext = nil;
//    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:image
//                                                            toUsername:_conversation.chatter
//                                                           messageType:[self messageType]
//                                                     requireEncryption:NO
//                                                                   ext:ext];
//    [self addMessage:tempMessage];
}
//
//-(void)sendAudioMessage:(EMChatVoice *)voice
//{
//    NSDictionary *ext = nil;
//    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice
//                                            toUsername:_conversation.chatter
//                                           messageType:[self messageType]
//                                     requireEncryption:NO ext:ext];
//    [self addMessage:tempMessage];
//}
//
//-(void)sendVideoMessage:(EMChatVideo *)video
//{
//    NSDictionary *ext = nil;
//    EMMessage *tempMessage = [ChatSendHelper sendVideo:video
//                                            toUsername:_conversation.chatter
//                                           messageType:[self messageType]
//                                     requireEncryption:NO ext:ext];
//    [self addMessage:tempMessage];
//}

- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}

- (void)markMessagesAsRead:(NSArray*)messages
{
    EMConversation *conversation = _conversation;
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [conversation markMessageWithId:message.messageId asRead:YES];
        }
    });
}

#pragma mark - EMCDDeviceManagerDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - EMChatManagerChatroomDelegate

- (void)chatroom:(EMChatroom *)chatroom occupantDidJoin:(NSString *)username
{
    CGRect frame = self.chatToolBar.frame;
    [self showHint:[NSString stringWithFormat:@"\'%@\'加入聊天室\'%@\'", username, chatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
}

- (void)chatroom:(EMChatroom *)chatroom occupantDidLeave:(NSString *)username
{
    CGRect frame = self.chatToolBar.frame;
    [self showHint:[NSString stringWithFormat:@"\'%@\'离开聊天室\'%@\'", username, chatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
}

- (void)beKickedOutFromChatroom:(EMChatroom *)chatroom reason:(EMChatroomBeKickedReason)reason
{
    if ([_chatter isEqualToString:chatroom.chatroomId])
    {
        _isKicked = YES;
        CGRect frame = self.chatToolBar.frame;
        [self showHint:[NSString stringWithFormat:@"被踢出聊天室\'%@\'", chatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didtapback
{
//
//    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"wtVersion"];

//        if ([self.popTopush isEqualToString:@"1"] || [self.popTopush isEqualToString:@"2"])
//        {
//    
//    //        MainViewController * miam = [[MainViewController alloc] init];
//    //        MessageViewController *  MessageView =[[MessageViewController alloc] init];
//    //        [self setHidesBottomBarWhenPushed:NO];
//            [self dismissViewControllerAnimated:YES completion:nil];
//    
//    
//    //        [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//        else
//        {
//            
//            if (![self.popTopush isEqualToString:@"1"] && ![self.popTopush isEqualToString:@"2"]) {
//                
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }
//            else
//            {
//            
//            }
//            [self.navigationController popViewControllerAnimated:YES];
//    
//        }
    [self popOrDissmissSelf];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"wtVersion"];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"wtVersion"];
}
- (void)didTapMoreButton
{
    if (_chatToolBar.inputTextView.text.length == 0) {
        return;
    }
    [self sendTextMessage:_chatToolBar.inputTextView.text];
}


#pragma mark - 群聊细工具条


- (UIView *)thinToolBar{
    _thinToolBar = [[UIView alloc]initWithFrame:CGRectMake(0, 64, Width, kThinToolBarHeight)];
    _thinToolBar.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, kThinToolBarHeight - 0.5, Width, 0.5)];
    lineView.backgroundColor = RGB(201, 201, 201, 1);
    [_thinToolBar addSubview:lineView];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, Width/2, kThinToolBarHeight)];
    UIButton *memberListBtn = [[UIButton alloc]initWithFrame:CGRectMake(Width - 64, 0, 32, 32)];
    
    [_thinToolBar addSubview:memberListBtn];
    memberListBtn.hidden = YES;
    
    
    titleLabel.font = [UIFont fontWithName:kFontName size:12];
    titleLabel.textColor = RGB(102, 102, 102, 1.0);
    titleLabel.text = self.name;
    [_thinToolBar addSubview:titleLabel];
    return _thinToolBar;
}

#pragma mark - Methods
- (void)popOrDissmissSelf{
    if (self.navigationController) {
        if (self.tabBarController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            if (self.isChatGroup) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }else if (self.isPresented){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
     [self sendChatCommand:nil];
}

- (void)updateWorkGroupNotice:(NSString *)newNotice timeString:(NSString *)timeString{

    NSDictionary *t = @{
                       @"MessageType":@"SelfWorkNotice",
                       @"BmobUserName":self.isMy_Nickname,
                       @"HeadImgUrl":self.isSender_yes_headimage,
                       @"WorkTitle":self.isChatGroup_WorkTitle,
                       @"SelfWorkNoticeContent":newNotice,
                       @"GroupOwnerId":self.GroupOwnerId,
                       @"SendedAt":timeString,
                       @"WorkTitle":self.workTitle,
                       @"SelfWorkDic":self.selfWorkDic,
                       @"WorkOrderObjectId":self.workOrderObjectId,
                       @"WorkObjectId":self.workObjectId,
                       };
    
    if([[t objectForKey:@"SelfWorkDic"] objectForKey:@"IntroPic"]==[NSNull null])
    {
        [[t objectForKey:@"SelfWorkDic"] setValue:@"1" forKey:@"IntroPic"];
    }
    if([t objectForKey:@"HeadImgUrl"]==[NSNull null])
    {
        [t  setValue:@"1" forKey:@"HeadImgUrl"];
    }
    //吴涛，下边你需要发送透传
    NSDictionary *w = @{@"DGBMessage":t};
    [self sendChatCommand:w];
}

- (void)sendChatCommand:(NSDictionary *)dict
{
    EMChatCommand *cmdChat = [[EMChatCommand alloc] init];
    cmdChat.cmd = @"wt";
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmdChat];
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:[[[dict objectForKey:@"DGBMessage"] objectForKey:@"SelfWorkDic"] objectForKey:@"GroupId"] bodies:@[body]];
    message.messageType = eConversationTypeGroupChat;// 设置为群聊消息
    if (dict) {
        message.ext = dict;
    }
    //
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [chatManager sendMessage:message progress:nil error:nil];
}



@end
