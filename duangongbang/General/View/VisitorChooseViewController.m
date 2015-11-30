//
//  VisitorChooseViewController.m
//  duangongbang
//
//  Created by ljx on 15/6/19.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "VisitorChooseViewController.h"
#import <BmobSDK/BmobCloud.h>
#import "CommonServers.h"
#import "UIView+Border.h"
#import "GetFilters.h"
#import "SVProgressHUD.h"

#define CHOOSELABEL_ARRAY_KVO_KEY @"CHOOSELABEL_ARRAY"

@interface VisitorChooseViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *chooseLabelArray;
    NSMutableArray *chooseLabelObjectIdArray;//存放选中标签objectId
    NSArray *rightArray;
    NSArray *rightArrayId;
    NSArray *leftArray;
    NSDictionary *dicClassify;
    __weak IBOutlet UIButton *btnFinished;
    __weak IBOutlet UITableView *_leftTableView;
    __weak IBOutlet UITableView *_rightTableView;
    __weak IBOutlet UIView *_headView;
    __weak IBOutlet UIView *_bottomView;
    __weak IBOutlet UIButton *_btnFirstChoose;
    __weak IBOutlet UIButton *_btnSecondChoose;
    __weak IBOutlet UIButton *_btnThirdChoose;
}
typedef NS_ENUM(NSInteger, UITableViewTag){
    LeftJobTableViewTag = 0,
    RightJobTableViewTag,
};
@end

@implementation VisitorChooseViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlueColor);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_thisViewIsPush) {
        //设置返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
        backItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = backItem;
    }else{
        UIBarButtonItem *returnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_close"] style:UIBarButtonItemStylePlain target:self action:@selector(returnDismiss)];
        returnItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = returnItem;
    }
    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 34)];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.font = [UIFont fontWithName:kFontName size:17.0];
//    titleLabel.text = @"请选择你喜欢的兼职类型";
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    
//    [self.navigationController.navigationBar addSubview:titleLabel];
//    titleLabel.center = CGPointMake(mainScreenWidth / 2, 22);
    self.title = @"请选择你喜欢的兼职类型";
    [self.navigationController.navigationBar setTitleTextAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    LOG(@"%@",[USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY]);
    
    chooseLabelArray = [[NSMutableArray alloc] init];
    chooseLabelObjectIdArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooicesChange:) name:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
    
    //[chooseLabelArray addObserver:self forKeyPath:CHOOSELABEL_ARRAY_KVO_KEY options:NSKeyValueObservingOptionNew context:NULL];
    
    [self setShadowWithView:_headView];
    [self setShadowWithView:_bottomView];
    
    [_rightTableView addLeftBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    
    _leftTableView.backgroundColor = UIColorFromRGB(xTableViewGrayColor);
    
    [btnFinished addTarget:self action:@selector(finishedChoose:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnFirstChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSecondChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_btnThirdChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    
    _leftTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _rightTableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *categoryDic;
    @try {
        if ([[USER_DEFAULT objectForKey:kCategoriesAndArea] isKindOfClass:[NSDictionary class]]) {
            categoryDic = [USER_DEFAULT objectForKey:kCategoriesAndArea];
        }else {
            NSString *strPath = [[NSBundle mainBundle] pathForResource:kCategoryJsonFileName ofType:@"json"];
            NSString *parseJson = [[NSString alloc] initWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
            categoryDic = [NSJSONSerialization JSONObjectWithData:[parseJson dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            
            [USER_DEFAULT setObject:categoryDic forKey:kCategoriesAndArea];
            [USER_DEFAULT synchronize];
        }
    }
    @catch (NSException *exception) {
        NSString *strPath = [[NSBundle mainBundle] pathForResource:kCategoryJsonFileName ofType:@"json"];
        NSString *parseJson = [[NSString alloc] initWithContentsOfFile:strPath encoding:NSUTF8StringEncoding error:nil];
        categoryDic = [NSJSONSerialization JSONObjectWithData:[parseJson dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        [USER_DEFAULT setObject:categoryDic forKey:kCategoriesAndArea];
        [USER_DEFAULT synchronize];
    }
    @finally {
        
    }
    
    dicClassify = [GetFilters getAllClassisfyWithArray:[categoryDic objectForKey:@"Classify"]];
    leftArray = [dicClassify objectForKey:kClassifyName];
    rightArray = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:0];
    rightArrayId = [[dicClassify objectForKey:kClassifyObjectIdArray] objectAtIndex:0];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
}

#pragma mark - UITableviewDelegete
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (tableView.tag) {
        case LeftJobTableViewTag:
            rightArray = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:indexPath.row];
            rightArrayId = [[dicClassify objectForKey:kClassifyObjectIdArray] objectAtIndex:indexPath.row];
            [_rightTableView reloadData];
            break;
        case RightJobTableViewTag:
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
    if (tableView.tag == LeftJobTableViewTag) {
        
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
        case LeftJobTableViewTag:
            cell.backgroundColor = UIColorFromRGB(xTableViewGrayColor);
            back.backgroundColor = UIColorFromRGB(0xFFFFFF);
            cell.selectedBackgroundView = back;
            cell.textLabel.text = [leftArray objectAtIndex:indexPath.row];
            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addRightBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            break;
        case RightJobTableViewTag:
            cell.textLabel.text = [rightArray objectAtIndex:indexPath.row];
            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addRightBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addLeftBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            break;
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - methods
- (void)backPop{
    NSLog(@"返回");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)returnDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)finishedChooseLabel{
    /**
     *  {"Type":"VisitorCustom",
     *  "Version":"3",
     *  "DeviceId":"xFF991F22CF183A9A2DC9AE43D6EC571",
     *  "DeviceType":"ios",
     *  "Classifies":["xcxcxc"]}
     */
    [SVProgressHUD showWithStatus:REFRESHING_DATA_KEY];
    NSString *deviceId = [[USER_DEFAULT objectForKey:DEVICE_TOKEN_KEY] copy];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"VisitorCustom",@"Type",
                         kCloudVersion,@"Version",
                         deviceId,@"DeviceId",
                         @"ios",@"DeviceType",
                         chooseLabelObjectIdArray,@"Classifies",
                         nil];
    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
    [CommonServers callAccountWithDict:dic
                               success:^(NSDictionary *obj){
                                   if (obj) {
                                       [timer invalidate];
                                       [SVProgressHUD showSuccessWithStatus:@"定制成功"];
                                       [USER_DEFAULT setBool:YES forKey:kIsCustom];
                                       [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }
                                   
    }
                                  fail:^(NSString *errorString){
                                      [timer invalidate];
                                      [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
    }];
}
- (void)stopRequest {
    [SVProgressHUD showErrorWithStatus:kNetworkWarning];
}

- (void)setShadowWithView:(UIView *)view{
    view.layer.masksToBounds = NO;
    
    //view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    view.layer.shadowRadius = 3.0;
    
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    view.layer.shadowOpacity = 0.1f;
}

- (void)chooicesChange:(id)sender{
    if (chooseLabelArray.count == 0) {
        _btnFirstChoose.enabled = NO;
        _btnSecondChoose.enabled = NO;
        _btnThirdChoose.enabled = NO;
        [_btnFirstChoose setTitle:@"" forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:@"" forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:@"" forState:UIControlStateNormal];
    }else if (chooseLabelArray.count == 1){
        _btnFirstChoose.enabled = YES;
        _btnSecondChoose.enabled = NO;
        _btnThirdChoose.enabled = NO;
        [_btnFirstChoose setTitle:[chooseLabelArray objectAtIndex:0] forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:@"" forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:@"" forState:UIControlStateNormal];
    }else if (chooseLabelArray.count == 2){
        _btnFirstChoose.enabled = YES;
        _btnSecondChoose.enabled = YES;
        _btnThirdChoose.enabled = NO;
        [_btnFirstChoose setTitle:[chooseLabelArray objectAtIndex:0] forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:[chooseLabelArray objectAtIndex:1] forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:@"" forState:UIControlStateNormal];
    }else if (chooseLabelArray.count == 3){
        _btnFirstChoose.enabled = YES;
        _btnSecondChoose.enabled = YES;
        _btnThirdChoose.enabled = YES;
        [_btnFirstChoose setTitle:[chooseLabelArray objectAtIndex:0] forState:UIControlStateNormal];
        [_btnSecondChoose setTitle:[chooseLabelArray objectAtIndex:1] forState:UIControlStateNormal];
        [_btnThirdChoose setTitle:[chooseLabelArray objectAtIndex:2] forState:UIControlStateNormal];
    }
}

#pragma mark - Button
- (void)deleteChooseLabel:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    if (![btn.titleLabel.text isEqualToString:@""]) {
        NSArray *temp = [[NSArray arrayWithArray:chooseLabelArray] copy];
        [chooseLabelArray removeObjectAtIndex:[temp indexOfObject:btn.titleLabel.text]];
        [chooseLabelObjectIdArray removeObjectAtIndex:[temp indexOfObject:btn.titleLabel.text]];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
    }
}

- (void)finishedChoose:(id)sender{
    if (chooseLabelArray.count > 0) {
        [self finishedChooseLabel];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请至少选择一个"];
    }
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:CHOOSELABEL_ARRAY_KVO_KEY]) {
        LOG(@"arraychange!");
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}
#pragma mark - servers

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
