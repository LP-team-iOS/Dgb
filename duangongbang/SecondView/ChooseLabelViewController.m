//
//  ChooseLabelViewController.m
//  duangongbang
//
//  Created by ljx on 15/5/15.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "ChooseLabelViewController.h"
#import "UIView+Border.h"
#import "GetFilters.h"
#import "UINavigationController+MoveBottomBlackLine.h"
//#import "UINavigationController+FDFullscreenPopGesture.h"
#import "CommonServers.h"
#import <BmobSDK/BmobUser.h>
#import "SVProgressHUD.h"

#define kTypeTitle @"请选择你喜欢的兼职类型";
#define kTimeTitle @"请选择空闲表";
#define kPayTitle @"请选择结算周期";

//#define PAY_WAYARRAY @["日结","周结","月结","面议"];

#define CHOOSELABEL_ARRAY_KVO_KEY @"CHOOSELABEL_ARRAY"

@interface ChooseLabelViewController ()<UIScrollViewDelegate>{
    BmobUser *bUser;
    NSArray *PAY_WAYARRAY;
    UILabel *titleLabel;
    NSDictionary *localClassifyDic;
    NSArray *leftArray;
    NSArray *rightArray;
    NSArray *rightArrayId;
    NSMutableArray *chooseLabelArray;
    NSMutableArray *chooseLabelObjectIdArray;//存放选中标签objectId
    
    NSMutableArray *weekDates;
    NSMutableArray *payMethods;
    
    NSDictionary *dicClassify;
    __weak IBOutlet UIButton *_btnAddNewPage;
    __weak IBOutlet UIButton *_btnFirstChoose;
    __weak IBOutlet UIButton *_btnSecondChoose;
    __weak IBOutlet UIButton *_btnThirdChoose;
    
    __weak IBOutlet UIButton *_btnFinishChooseWeekDates;
    __weak IBOutlet UIButton *_btnFinishChooseLabel;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentLineCenter;//is 86/320
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tuesCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wedCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *satCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sunCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markLineCenter;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *timeTopView;


@property (weak, nonatomic) IBOutlet UITableView *rightTableView;
@property (weak, nonatomic) IBOutlet UITableView *payWayTableView;

@property (weak, nonatomic) IBOutlet UIButton *btnFirst;
@property (weak, nonatomic) IBOutlet UIButton *btnSecond;
@property (weak, nonatomic) IBOutlet UIButton *btnThrid;

@property (weak, nonatomic) IBOutlet UIButton *monButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesButton;
@property (weak, nonatomic) IBOutlet UIButton *webButton;
@property (weak, nonatomic) IBOutlet UIButton *thurButton;
@property (weak, nonatomic) IBOutlet UIButton *friButton;
@property (weak, nonatomic) IBOutlet UIButton *satButton;
@property (weak, nonatomic) IBOutlet UIButton *sunButton;

@property (strong, nonatomic) IBOutlet UIView *typeView;

@property (strong, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) IBOutlet UIView *payView;

@property (weak, nonatomic) IBOutlet UIView *typeBottomView;

@property (weak, nonatomic) IBOutlet UIView *payBottomView;

@property (weak, nonatomic) IBOutlet UIView *timeBottomView;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

typedef NS_ENUM(NSInteger, UITableViewTag){
    LeftJobTableViewTag = 0,
    RightJobTableViewTag,
    PayWayTableViewTag,
};

@implementation ChooseLabelViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlueColor);
    bUser = [ShareDataSource sharedDataSource].myData;
    PAY_WAYARRAY = @[@"不限",@"日结",@"周结",@"月结",@"面议"];
    [_mainScrollView addSubview:_typeView];
    [_mainScrollView addSubview:_timeView];
    [_mainScrollView addSubview:_payView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAllFrame];
    
//    self.fd_interactivePopDisabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (tableView.tag) {
        case LeftJobTableViewTag:
//            rightArray = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:indexPath.row];
//            [_rightTableView reloadData];
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
        case PayWayTableViewTag:
            payMethods = [NSMutableArray arrayWithObject:[PAY_WAYARRAY objectAtIndex:indexPath.row]];

//            LOG(@"SelectPayMethods:%@",payMethods);
            break;
    }
    
}

#pragma mark - UITableViewDataSources
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //设置选中
    if (tableView.tag == LeftJobTableViewTag) {
        return leftArray.count;
    }else if(tableView.tag == RightJobTableViewTag){
        return rightArray.count;
    }else{
        return PAY_WAYARRAY.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
//            cell.backgroundColor = UIColorFromRGB(xTableViewGrayColor);
//            back.backgroundColor = UIColorFromRGB(0xFFFFFF);
//            cell.selectedBackgroundView = back;
//            cell.textLabel.text = [leftArray objectAtIndex:indexPath.row];
//            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
//            [cell addRightBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            break;
        case RightJobTableViewTag:
            cell.textLabel.text = [rightArray objectAtIndex:indexPath.row];
            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
//            [cell addRightBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            [cell addLeftBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
            break;
        case PayWayTableViewTag:
            cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x + 20, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
            cell.textLabel.text = [PAY_WAYARRAY objectAtIndex:indexPath.row];
            [cell addBottomBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5 andHeight:mainScreenWidth - 32.0];
            cell.textLabel.font = [UIFont fontWithName:kFontName size:14.0];
            break;
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //_markLineCenter.constant = scrollView.contentOffset.x * mainScreenWidth  * 86 / 320 / 3 / mainScreenWidth;
//    if(scrollView.contentOffset.x <= 0 && scrollView.contentOffset.x > -mainScreenWidth) {
//        _markLineCenter.constant = - ((mainScreenWidth * 86 / 320) * (mainScreenWidth - scrollView.contentOffset.x) / mainScreenWidth);
//    }else if (scrollView.contentOffset.x > 0){
//        _markLineCenter.constant = ((mainScreenWidth * 86 / 320) * scrollView.contentOffset.x / mainScreenWidth);
//    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (_mainScrollView.contentOffset.x == 0.0) {
        _markLineCenter.constant = mainScreenWidth * 86 / 320;
        titleLabel.text = kTypeTitle;
    }else if (_mainScrollView.contentOffset.x == mainScreenWidth){
        _markLineCenter.constant = 0.0;
        titleLabel.text = kTimeTitle;
    }else if (_mainScrollView.contentOffset.x == mainScreenWidth * 2){
        _markLineCenter.constant = - mainScreenWidth * 86 / 320;
        titleLabel.text = kPayTitle;
    }
}

#pragma mark - Button
- (void)touchButton:(id)sender{
    
}

- (void)finishedChooseAndOpenMainView:(id)sender{
    if (chooseLabelObjectIdArray.count > 0 && weekDates.count > 0 && payMethods.count > 0) {
        [self callAccountCloud];
    }else{
        [SVProgressHUD showErrorWithStatus:@"每个定制选项至少选择1个"];
    }
}

- (void)selectAndChangeStates:(UIButton *)sender{
//    UIButton *btn = (UIButton *)sender;
    
    NSString *dates =  [NSString stringWithFormat:@"%d",sender.tag];
    
    if (sender.isSelected) {
        sender.selected = NO;
        [sender setBackgroundColor:[UIColor clearColor]];
        [sender setTitleColor:UIColorFromRGB(xBaseBlack) forState:UIControlStateNormal];
//        NSString *dates = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:sender.tag]];
//        [weekDates removeObject:[NSNumber numberWithInteger:sender.tag]];
        
        [weekDates removeObject:dates];
    }else{
        sender.selected = YES;
        [sender setBackgroundColor:UIColorFromRGB(xMainBlueColor)];
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [weekDates addObject:dates];
        
//        [weekDates addObject:[NSNumber numberWithInteger:sender.tag]];
    }
}

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
        _mainScrollView.contentSize = CGSizeMake(mainScreenWidth * 2, mainScreenHeight - 88.0);
        [_mainScrollView setContentOffset:CGPointMake(mainScreenWidth, 0) animated:YES];
        _markLineCenter.constant = 0.0;
        titleLabel.text = kTimeTitle;
    }else{
        _mainScrollView.contentSize = CGSizeMake(mainScreenWidth, mainScreenHeight - 88.0);
        [SVProgressHUD showErrorWithStatus:@"请至少选择一个"];
    }
    
}

- (void)finishedChooseWeekDates:(id)sender{
    if (weekDates.count > 0) {
        _mainScrollView.contentSize = CGSizeMake(mainScreenWidth * 3, mainScreenHeight - 88.0);
        [_mainScrollView setContentOffset:CGPointMake(mainScreenWidth * 2, 0) animated:YES];
        _markLineCenter.constant = - mainScreenWidth * 86 / 320;
        titleLabel.text = kPayTitle;
    }else{
        _mainScrollView.contentSize = CGSizeMake(mainScreenWidth * 2, mainScreenHeight - 88.0);
        [SVProgressHUD showErrorWithStatus:@"请至少选择一个"];
    }
}
#pragma mark - methods
- (void)backPop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)returnDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setShadowWithView:(UIView *)view{
    view.layer.masksToBounds = NO;
    
    //view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    view.layer.shadowRadius = 3.0;
    
    view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    
    view.layer.shadowOpacity = 0.1f;
}

- (void)setAllFrame{

//    _leftTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _rightTableView.translatesAutoresizingMaskIntoConstraints = NO;

    if (_thisViewIsPush) {
        //设置返回按钮
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
        backItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = backItem;
    }else{
        UIBarButtonItem *returnItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(returnDismiss)];
        returnItem.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = returnItem;
    }
    
    [self.navigationController moveBottomBlackLine];
    _markLineCenter.constant = mainScreenWidth * 86 / 320;
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
    
    weekDates = [[NSMutableArray alloc] init];

    payMethods = [[NSMutableArray alloc] init];
    
    chooseLabelArray = [[NSMutableArray alloc] init];
    chooseLabelObjectIdArray = [[NSMutableArray alloc] init];
    
    dicClassify = [GetFilters getAllClassisfyWithArray:[categoryDic objectForKey:@"Classify"]];
    
    leftArray = [dicClassify objectForKey:kClassifyName];
    rightArray = [[dicClassify objectForKey:kClassifyNameArray] objectAtIndex:0];
    rightArrayId = [[dicClassify objectForKey:kClassifyObjectIdArray] objectAtIndex:0];
    
    CGFloat widthCenter = ((mainScreenWidth - 64.0) / 7);
    _lineHeight.constant = mainScreenWidth == 414 ? 0.3333 : 0.5;
    //利用constant设置星期的位置
    _monCenter.constant = widthCenter*3;
    _tuesCenter.constant = widthCenter*2;
    _wedCenter.constant = widthCenter*1;
    _friCenter.constant = -widthCenter*1;
    _satCenter.constant = -widthCenter*2;
    _sunCenter.constant = -widthCenter*3;
    
    [_monButton setViewCornerWithRadius:12.0];
    [_tuesButton setViewCornerWithRadius:12.0];
    [_webButton setViewCornerWithRadius:12.0];
    [_thurButton setViewCornerWithRadius:12.0];
    [_friButton setViewCornerWithRadius:12.0];
    [_satButton setViewCornerWithRadius:12.0];
    [_sunButton setViewCornerWithRadius:12.0];
    
    
    [_btnFirstChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_btnSecondChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    [_btnThirdChoose addTarget:self action:@selector(deleteChooseLabel:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooicesChange:) name:CHOOSELABEL_ARRAY_KVO_KEY object:nil];
    
    [_monButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_tuesButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_webButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_thurButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_friButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_satButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    [_sunButton addTarget:self action:@selector(selectAndChangeStates:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnFinishChooseLabel addTarget:self action:@selector(finishedChoose:) forControlEvents:UIControlEventTouchUpInside];
    [_btnFinishChooseWeekDates addTarget:self action:@selector(finishedChooseWeekDates:) forControlEvents:UIControlEventTouchUpInside];
    [_btnAddNewPage addTarget:self action:@selector(finishedChooseAndOpenMainView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_rightTableView addLeftBorderWithColor:UIColorFromRGB(xBoderColor1) andWidth:0.5];
    

    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 34)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:kFontName size:17.0];
    titleLabel.text = kTypeTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationController.navigationBar addSubview:titleLabel];
    titleLabel.center = CGPointMake(mainScreenWidth / 2, 22);
    // Do any additional setup after loading the view from its nib.
    
    [self setShadowWithView:_topView];
    [self setShadowWithView:_timeTopView];
    [self setShadowWithView:_timeBottomView];
    [self setShadowWithView:_typeBottomView];
    [self setShadowWithView:_payBottomView];
    
    _mainScrollView.contentSize = CGSizeMake(Width, mainScreenHeight - 88.0);
    _typeView.frame = CGRectMake(0.0, 0.0, mainScreenWidth, mainScreenHeight-88.0);
    //_typeView.translatesAutoresizingMaskIntoConstraints = NO;
    _timeView.frame = CGRectMake(mainScreenWidth, 0.0, mainScreenWidth, mainScreenHeight-88.0);
    _payView.frame = CGRectMake(mainScreenWidth*2.0, 0.0, mainScreenWidth, mainScreenHeight-88.0);
    
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


#pragma mark - servers 
- (void)callAccountCloud{
    /**
     * {"Type":"UserCustom",
     *  "PayMethods":["日结","周结","月结","面议"],
     *  "Classifies":["FfCC9445","c1fki55Y"],
     *  "Version":kCloudVersion,
     *  "UserObjectId":"61acc57699",
     *  "FreeDays":["1","2","3","4","5","6"]
     * }
     */
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"UserCustom",@"Type",
                         payMethods,@"PayMethods",
                         chooseLabelObjectIdArray,@"Classifies",
                         kCloudVersion,@"Version",
                         bUser.objectId,@"UserObjectId",
                         weekDates,@"FreeDays",
                          @"ios",@"DeviceType",
                          nil];

    NSTimer *timer =[NSTimer scheduledTimerWithTimeInterval:refreshMaxTime target:self selector:@selector(stopRequest) userInfo:nil repeats:NO];
    [CommonServers callAccountWithDict:dict success:^(NSDictionary *dic){
        NSLog(@"上传数据-----%@",dict);
        NSLog(@"定制成功----%@",dic);
        [timer invalidate];
        [SVProgressHUD showSuccessWithStatus:@"定制成功"];
        [USER_DEFAULT setBool:YES forKey:kIsCustom];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOGIN_LOAD_USER_INFO object:nil];
        }];
    }fail:^(NSString *err){
        [timer invalidate];
        [SVProgressHUD showErrorWithStatus:REFRESHED_ERRER_KEY];
    }];
    
}

- (void)stopRequest {
    [SVProgressHUD showErrorWithStatus:kNetworkWarning];
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
