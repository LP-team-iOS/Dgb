//
//  SchoolViewController.m
//  duangongbang
//
//  Created by ljx on 15/7/15.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "SchoolViewController.h"
#import <BmobSDK/BmobQuery.h>
#import "SVProgressHUD.h"
#import "CityLocationViewController.h"

@interface SchoolViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    BOOL isLoadCity;
    
    NSString *cityObjectId;
    
    NSArray *schoolArray;
    
    __weak IBOutlet UITableView *_schoolTableView;
    __weak IBOutlet UIButton *_btnOtherCity;
    __weak IBOutlet UILabel *_lbLocationCity;
    __weak IBOutlet UIButton *_btnLocation;
    
}

@end

@implementation SchoolViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlueColor);
    _lbLocationCity.text = [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"CityName"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [_btnOtherCity addTarget:self action:@selector(chooseOtherCity:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSchoolWithCity:) name:KEY_KVO_LOAD_SCHOOL_WHEN_CHANGE_CITY object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOAD_SCHOOL_WHEN_CHANGE_CITY object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KEY_KVO_LOAD_SCHOOL_WHEN_CHANGE_CITY object:nil];
}

#pragma mark - UITableViewDataSources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return schoolArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:kFontName size:15.0]];
    [cell.textLabel setTextColor:UIColorFromRGB(xBaseBlack)];
    cell.textLabel.text = [[schoolArray objectAtIndex:indexPath.row] objectForKey:@"SchoolName"];
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_CHANGE_THE_CHOOSEN_SCHOOL object:[NSDictionary dictionaryWithObjectsAndKeys:[[schoolArray objectAtIndex:indexPath.row] objectForKey:@"SchoolName"],@"SchoolName",[(BmobObject *)[schoolArray objectAtIndex:indexPath.row] objectId],@"SchoolObjectId", nil]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - button
- (void)chooseOtherCity:(id)sender{
    CityLocationViewController *cityVC = [[CityLocationViewController alloc] initWithNibName:@"CityLocationViewController" bundle:nil];
    cityVC.chooseCityAndChangeSchool = YES;
    [self.navigationController pushViewController:cityVC animated:YES];
}

#pragma mark - methods
- (void)backPop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadSchoolWithCity:(NSNotification *)nitification{
    
    cityObjectId = [[USER_DEFAULT objectForKey:MY_CITY_KEY] objectForKey:@"objectId"];
    
    [self querySchoolWithCtiyId:cityObjectId success:^(NSArray *schools){
        if (schools) {
            schoolArray = [NSArray arrayWithArray:schools];
            [_schoolTableView reloadData];
        }
    }fail:^(NSString *err){
        [SVProgressHUD showErrorWithStatus:err];
    }];
}

#pragma mark - Servers
- (void)querySchoolWithCtiyId:(NSString *)cityId success:(void(^)(NSArray *city))success fail:(void(^)(NSString *reason))fail{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"School"];
    
    if (!isLoadCity) {
        [bquery setCachePolicy:kBmobCachePolicyCacheThenNetwork];
        isLoadCity = YES;
    }else{
        [bquery setCachePolicy:kBmobCachePolicyNetworkOnly];
    }
    
    [bquery whereKey:@"City" equalTo:cityId];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *arr, NSError *err){
        
        if (arr) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            for (BmobObject *bmobObject in arr) {
                [array addObject:bmobObject];
            }
            success(array);
        }
        if (err) {
            fail(kNetworkWarning); 
        }
    }];
    
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
