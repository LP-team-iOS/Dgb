//
//  DGSearchViewViewController.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/7/30.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "DGSearchViewViewController.h"
#import "JobTableViewCell.h"
#import "JobTableViewCell2.h"
#import "UIViewController+ScrollingNavbar.h"
#import "UIImage+ImageEffects.h"
#import "CommonServers.h"
#import <BmobSDK/BmobUser.h>
#import "MJRefresh.h"
#import "UIScrollView+EmptyDataSet.h"
#import "DGDetailViewController.h"
#import "MyRefresh.h"
#import "MyRefreshFooter.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "WorkModel.h"
#import "MyResumeViewController.h"
#import "DirectAcceptedDetailViewController.h"
#define kSkip @"Skip"
#define kLimit @"Limit"
#define kWordKey @"Key"
#define kWorkObjectId @"WorkObjectId"
#define kWorkOrderId @"WorkOrderObjectId"
@interface DGSearchViewViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate,UITextFieldDelegate>{
    NSMutableArray *_listData;
    NSMutableDictionary *_callCloudDic;
    BmobUser *bUser;
    WorkModel *workModel;
    NSInteger judge;//判断按钮点击
}
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewToMainViewConstraint;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (strong, nonatomic) IBOutlet UITableView *resultTableView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tipsBtn;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *btnBgView;

@end

@implementation DGSearchViewViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    bUser = [ShareDataSource sharedDataSource].myData;
    
    [_resultTableView registerNib:[UINib nibWithNibName:@"JobTableViewCell" bundle:nil] forCellReuseIdentifier:@"jobCell"];
    [_resultTableView registerNib:[UINib nibWithNibName:@"JobTableViewCell2" bundle:nil] forCellReuseIdentifier:@"jobCell2"];
    _resultTableView.delegate = self;
    _resultTableView.dataSource = self;

    _resultTableView.tableHeaderView  = _topView;
    _resultTableView.showsVerticalScrollIndicator = NO;
    _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    MyRefreshFooter *footer = [MyRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.refreshingTitleHidden = YES;
    footer.stateLabel.hidden = YES;
    _resultTableView.mj_footer = footer;
    _toolBar.translucent = NO;
    [self setAllButton];
    
    _btnBgView.layer.cornerRadius = 6.0f;
    [_btnBgView.layer masksToBounds];
    //收起键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)keyboardHide
{
    [_searchTextField resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [self stopFollowingScrollView];
}

- (void)setAllButton
{
    
    [_searchBtn addTarget:self action:@selector(searchWork) forControlEvents:UIControlEventTouchUpInside];

    [_verifyBtn addTarget:self action:@selector(verifyWork) forControlEvents:UIControlEventTouchUpInside];
    _searchTextField.delegate = self;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    if ([self isZhongWen:_searchTextField.text]) {
        [self searchWork];
    }else {
        [self verifyWork];
    }
    return YES;
}

-(BOOL)isZhongWen:(NSString *)Str
{
    int utfCode = 0;
    void *buffer = &utfCode;
    NSRange range = NSMakeRange(0, 1);
    //判断是不是中文开头的,buffer->获取字符的字节数据 maxLength->buffer的最大长度 usedLength->实际写入的长度，不需要的话可以传递NULL encoding->字符编码常数，不同编码方式转换后的字节长是不一样的，这里我用了UTF16 Little-Endian，maxLength为2字节，如果使用Unicode，则需要4字节 options->编码转换的选项，有两个值，分别是NSStringEncodingConversionAllowLossy和NSStringEncodingConversionExternalRepresentation range->获取的字符串中的字符范围,这里设置的第一个字符 remainingRange->建议获取的范围，可以传递NULL
    BOOL b = [Str getBytes:buffer maxLength:2 usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:NSStringEncodingConversionExternalRepresentation range:range remainingRange:NULL];
    if (b && (utfCode >= 0x4e00 && utfCode <= 0x9fa5))
        return YES;
    else
        return NO;
}

#pragma mark - UITableViewDataSources
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _listData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (Width > 320) {
        static NSString *simpleIdentify = @"jobCell2";
        JobTableViewCell2 *nib = (JobTableViewCell2 *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell2" owner:self options:nil]lastObject];
        }
        if ([[_listData objectAtIndex:indexPath.row] objectForKey:@"Hot"]) {
            [nib setSearchModelWithWork:[_listData objectAtIndex:indexPath.row]];
        }else {
            [nib setAllFrameWithWorkList:[_listData objectAtIndex:indexPath.row]];
        }

        nib.selectionStyle = UITableViewCellSelectionStyleNone;
        return nib;
    }else {
        static NSString *simpleIdentify = @"jobCell";
        JobTableViewCell *nib = (JobTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify];
        if (nib == nil) {
            nib = [[[NSBundle mainBundle]loadNibNamed:@"JobTableViewCell" owner:self options:nil]lastObject];
        }
        if ([[_listData objectAtIndex:indexPath.row] objectForKey:@"Hot"]) {
            [nib setSearchModelWithWork:[_listData objectAtIndex:indexPath.row]];
        }else {
            [nib setAllFrameWithWorkList:[_listData objectAtIndex:indexPath.row]];
        }
        nib.selectionStyle = UITableViewCellSelectionStyleNone;
        return nib;
    }

}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (judge == 0){
            if (_listData) {
                DGDetailViewController *dgVC = [[DGDetailViewController alloc] initWithNibName:@"DGDetailViewController" bundle:nil];
                [dgVC setWorkObjectId:[[_listData objectAtIndex:indexPath.row] objectForKey:@"objectId"]];
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:dgVC animated:YES];
                }
        }else {
            HLAlertController *alert = [HLAlertController alertControllerWithTitle:@"确定要申请这个工作?" message:nil preferredStyle:HLAlertControllerStyleAlert];
            
            [alert addAction:[HLAlertAction actionWithTitle:@"确定" style:HLAlertActionStyleDestructive handler:^(HLAlertAction *action) {
                NSString *orderID = _searchTextField.text;
                _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"SelfWorkCodeApply", @"Type",
                                 @2, @"Step",
                                 bUser ? bUser.objectId : @"", @"UserObjectId",
                                 workModel.objectId,kWorkObjectId,
                                 orderID,kWorkOrderId,
                                 [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"], @"CityObjectId",
                                 kCloudVersion,@"Version",
                                 nil];
                
                [CommonServers callCloudWithAPIName:kCloudInteractive andDic:_callCloudDic success:^(id obj){
                    if ([[obj objectForKey:@"Static"]isEqualToString:@"faile"]) {
                        [SVProgressHUD showInfoWithStatus:[obj objectForKey:@"Value"]];
                    }
                    else if([[obj objectForKey:@"Static"]isEqualToString:@"success"]){
                        if ([[obj objectForKey:@"ReturnType"]isEqualToString:@"EnterWork"])
                        {
                            //直接跳转到聊天室
                            [SVProgressHUD showInfoWithStatus:[obj objectForKey:@"Value"]];
                            [self jumpToGroupChat:[obj objectForKey:@"GroupId"]];
                            
                        }
                        else if ([[obj objectForKey:@"ReturnType"]isEqualToString:@"RejectWork"])
                        {
                            [SVProgressHUD showInfoWithStatus:[obj objectForKey:@"Value"]];
                            
                        }
                        else if ([[obj objectForKey:@"ReturnType"]isEqualToString:@"AddGroup"]){
                            //第一次验证验证码
                            [SVProgressHUD showInfoWithStatus:[obj objectForKey:@"Value"]];
                            [self jumpToGroupChat:[obj objectForKey:@"GroupId"]];
                            
                        }
                        else if ([[obj objectForKey:@"ReturnType"]isEqualToString:@"NeedResume"])
                        {
                            //需要完善简历
                            HLAlertController *alert2 = [HLAlertController alertControllerWithTitle:@"没有填写完整的简历" message:nil preferredStyle:HLAlertControllerStyleAlert];
                            [alert2 addAction:[HLAlertAction actionWithTitle:@"前往修改" style:HLAlertActionStyleDefault handler:^(HLAlertAction *action) {
                                MyResumeViewController * myResumeVC = [[MyResumeViewController alloc]init];
                                [self setHidesBottomBarWhenPushed:YES];
                                [self.navigationController pushViewController:myResumeVC animated:YES];
                            }]];
                            [alert2 showWithViewController:self];
                            
                        }else {
                            
                        }
                    }else {
                        
                    }
                }fail:^(NSString *err){
                    LOG(@"searchErr = %@",err);
                }];
            }]];
            
            [alert addAction:[HLAlertAction actionWithTitle:@"取消" style:HLAlertActionStyleCancel handler:^(HLAlertAction *action) {
                
            }]];
            [alert showWithViewController:self];
        }
}


#pragma mark - button 
- (IBAction)backpop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
//- (IBAction)tipspop:(id)sender
//{
//    LOG(@"什么是验证码");
//}

- (void)searchWork
{
    _listData = [[NSMutableArray alloc]init];
    judge = 0;
    /**
     *  {"Version":kCloudVersion,"Key":"派单","limit":5,"cityId":"Cbqr444B","Type":"SearchWork","method":"","skip":0,"areaId":"","UserObjectId":"61acc57699"}
     */
    _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     kCloudVersion, @"Version",
                     @"", @"Key",
                     @5, @"Limit",
                     [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"], @"CityObjectId",
                     @"SearchWork", @"Type",
                     @"", @"method",
                     @0, @"Skip",
                     @"", @"AreaId",
                     bUser ? bUser.objectId : @"", @"UserObjectId",
                     nil];


    FIRST_RESPONDER;
    if ([_searchTextField.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"请输入查询内容"];
        return;
    }
//    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];

    if (![_searchTextField.text isEqualToString:@""]) {
        [_callCloudDic setObject:_searchTextField.text forKey:kWordKey];
        [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id obj){
            if (obj) {
                _listData = [obj objectForKey:@"Works"];
                [_resultTableView.mj_footer endRefreshing];

                if (_listData.count == 0) {
                    [SVProgressHUD showInfoWithStatus:@"暂无数据"];
                }
                [_resultTableView reloadData];
            }
            [SVProgressHUD dismissWithDelay:0.2];
        }fail:^(NSString *err){
            LOG(@"searchERR = %@",err);
        }];
    }

}

- (void)verifyWork
{
    _listData = [[NSMutableArray alloc]init];
    judge = 1;
    /**
     *  jsonObject.put("Type", "SelfWorkCodeApply");
     jsonObject.put("Step", 1);
     jsonObject.put("UserObjectId", userId);
     jsonObject.put("WorkObjectId", workId);
     jsonObject.put("WorkOrderObjectId", orderId);
     jsonObject.put("CityObjectId", "xxxxxx");
     jsonObject.put("Version", "326");
     */
    bUser = [BmobUser getCurrentUser];
    if (!bUser) {
        [self checkIsLoginAndAlert];
        return;
    }
    
    if ([_searchTextField.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"请输入邀请码"];
        return;
    }
    NSString *orderID = _searchTextField.text;
    _callCloudDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     @"SelfWorkCodeApply", @"Type",
                     @1, @"Step",
                     bUser ? bUser.objectId : @"", @"UserObjectId",
                     @"",kWorkObjectId,
                     orderID,kWorkOrderId,
                     [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"], @"CityObjectId",
                     kCloudVersion,@"Version",
                     @"ios",kDeviceType,
                     nil];

    FIRST_RESPONDER;
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];
    if (![_searchTextField.text isEqualToString:@""]) {
        [CommonServers callCloudWithAPIName:kCloudInteractive andDic:_callCloudDic success:^(id obj){
            if ([[obj objectForKey:@"Static"] isEqualToString:@"success"]) {
                [_listData  addObject:[obj objectForKey:@"Work"]];
                workModel = [WorkModel initWithDic:[obj objectForKey:@"Work"]];

                if (_listData.count == 0) {
                    [SVProgressHUD showInfoWithStatus:obj[@"Value"]];
                }
                [_resultTableView reloadData];
                [SVProgressHUD dismissWithDelay:0.5];
            }else {
                [SVProgressHUD showInfoWithStatus:obj[@"Value"]];
            }
        }fail:^(NSString *err){
            
        }];
    }

}

#pragma mark - methods
- (void)loadMoreData{
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRefreshing:) userInfo:nil repeats:NO];

    if ([_searchTextField.text isEqualToString:@""]) {
        [_resultTableView.mj_footer endRefreshing];
        [SVProgressHUD showInfoWithStatus:@"请先输入查询内容或者邀请码"];
        return;
    }
    [_callCloudDic setObject:@(_listData.count) forKey:kSkip];
    
    [CommonServers callCloudWithAPIName:kCloudWork andDic:_callCloudDic success:^(id obj){
        [timer invalidate];
        if (obj) {
            [_listData addObjectsFromArray:[obj objectForKey:@"Works"]];
            [_resultTableView reloadData];
            [_resultTableView.mj_footer endRefreshingWithNoMoreData];
        }
        
    }fail:^(NSString *err){
        [_resultTableView.mj_footer endRefreshingWithNoMoreData];
    }];

}

//刷新或者上拉加载超时
- (void)stopRefreshing:(NSTimer*)timer
{
    if(timer.isValid)
    {
        [timer invalidate];
        [_resultTableView.mj_footer endRefreshing];
    }
}
/**
 *  检查是否登录
 */
- (void)checkIsLoginAndAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去登录", nil];
    alertView.tag = 3001;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3001) {
        if (buttonIndex == 1) {
            UINavigationController *nav = [[UINavigationController alloc] init];
            LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [nav pushViewController:logVC animated:NO];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    
}

//跳转至群聊界面
- (void)jumpToGroupChat:(NSString *)groupId{
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
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                NSString *updatedAtString = [dateFormatter stringFromDate:aSelfWork.updatedAt];
                NSDictionary *aSelfWorkDic = @{
                                               @"GroupId":[aSelfWork objectForKey:@"GroupId"],
                                               @"GroupOwnerId":[aSelfWork objectForKey:@"GroupOwnerId"],
                                               @"updatedAt":updatedAtString,
                                               @"Notice":[aSelfWork objectForKey:@"Notice"]
                                               };
                NSDictionary *workDic = [aSelfWork objectForKey:@"Work"];
                DirectAcceptedDetailViewController *dadvc = [[DirectAcceptedDetailViewController alloc]init];
                dadvc.workTitle         = [workDic objectForKey:@"Title"];
                dadvc.selfWorkDic       = aSelfWorkDic;
                dadvc.workObjectId      = [workDic objectForKey:@"objectId"];
                [self setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:dadvc animated:YES];
            }
        }
    }];
}



@end
