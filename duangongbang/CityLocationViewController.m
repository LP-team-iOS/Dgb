//
//  CityLocationViewController.m
//  duangongbangUser
//
//  Created by ljx on 15/3/27.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "CityLocationViewController.h"
#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <BmobSDK/Bmob.h>
#import "SVProgressHUD.h"
#import "VisitorChooseViewController.h"
#import "SchoolViewController.h"
#import "RegistViewController.h"

@interface CityLocationViewController ()<CLLocationManagerDelegate>{
    
    CLLocationManager *locMgr;
    
    CLLocationCoordinate2D coordinate;
    
    CLGeocoder *geocoder;
    
    NSArray *hotCity;

    BOOL isLoadCity;
    
    BOOL includedThisCity;
    
    NSString *myCity;
    
    NSMutableArray *cityArray;
}

- (IBAction)btnLocation:(id)sender;

- (IBAction)btnChooseCity:(id)sender;

@property (weak, nonatomic) IBOutlet __block UIButton *btnChooseCityPro;

@property (weak, nonatomic) IBOutlet UITableView *cityTableView;

@end

@implementation CityLocationViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlackColor);
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [locMgr stopUpdatingLocation];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.title = @"城市选择";

    self.btnChooseCityPro.userInteractionEnabled = NO;
    
    if (![CLLocationManager locationServicesEnabled]) {
        [SVProgressHUD showErrorWithStatus:@"请打开定位功能"];
        return;
    }else {
        locMgr = [[CLLocationManager alloc] init];
        locMgr.delegate = self;
//        kCLLocationAccuracyNearestTenMeters，10米
//        
//        kCLLocationAccuracyHundredMeters ，100米
//        
//        kCLLocationAccuracyKilometer ，1000米
//        
//        kCLLocationAccuracyThreeKilometers，3000米
//        
//        kCLLocationAccuracyBest ，最好的精度
        
        locMgr.desiredAccuracy = kCLLocationAccuracyBest;
        locMgr.distanceFilter = 10;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [locMgr requestWhenInUseAuthorization];
//            [locMgr requestAlwaysAuthorization];
        }
        [locMgr startUpdatingLocation];
    }
    
    [self getHotCity:^(NSArray *arr){
        hotCity = arr;
        [self.cityTableView reloadData];
    }fail:^(NSString *str){
        
    }];
}

#pragma mark - 检测应用是否开启定位服务
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            [self openGPSTips];
            break;
        case kCLErrorLocationUnknown:
            break;
        default:
            break;
    }
}

-(void)openGPSTips{
    UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"当前定位服务不可用" message:@"请到“设置->隐私->定位服务”中开启定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alet show];
}

#pragma mark - coreLocation delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
//    CLLocation *location = [locations lastObject];
    CLLocation *location = [locations objectAtIndex:0];
    coordinate = location.coordinate;

    //获取当前城市名
    geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error)
     
    {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"定位失败，请重试"];
        }
        
        if (array.count > 0)
        {
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            //获取城市
            NSString *city = placemark.locality;
            myCity = city;

            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
                
            }
            cityArray = [[NSMutableArray alloc]init];
            
            for (NSDictionary *dic in hotCity) {
                [cityArray addObject:[dic objectForKey:@"CityName"]];
            }
            
            if ([cityArray containsObject:myCity]) {
                includedThisCity = YES;
                [self.btnChooseCityPro setTitle:city forState:UIControlStateNormal];
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"当前城市：%@",city]];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"该城市暂未开放"];
            }

            
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    
    [locMgr stopUpdatingLocation];
    
    NSDictionary *cordinateDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:coordinate.latitude], KEY_COORDINATE_LATITUDE, [NSNumber numberWithDouble:coordinate.longitude], KEY_COORDINATE_LONGITUDE, nil];
    
    [USER_DEFAULT setObject:cordinateDic forKey:KEY_COORDINATE];
    [USER_DEFAULT synchronize];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return hotCity.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
    
    cell.textLabel.text = [[hotCity objectAtIndex:indexPath.row] objectForKey:@"CityName"];
    
    return cell;
}

#pragma mark - tableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BmobObject *obj = [hotCity objectAtIndex:indexPath.row];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         obj.objectId,@"objectId",
                         [obj objectForKey:@"CityName"],@"CityName",nil];
    
    [USER_DEFAULT setObject:dic forKey:MY_CITY_KEY];
    
    [USER_DEFAULT synchronize];
    
    [self selectedCity];
}

- (void)getHotCity:(void(^)(NSArray *city))allCity fail:(void(^)(NSString *reason))fail{
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"City"];
    
    if (!isLoadCity) {
        [bquery setCachePolicy:kBmobCachePolicyCacheThenNetwork];
        isLoadCity = YES;
    }else{
        [bquery setCachePolicy:kBmobCachePolicyNetworkOnly];
    }
    
    [bquery orderByAscending:@"createdAt"];
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *arr, NSError *err){
        
        if (arr) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            for (BmobObject *bmobObject in arr) {
                [array addObject:bmobObject];
            }
            allCity(array);
        }
        
    }];
    
}

- (IBAction)btnLocation:(id)sender{
    [SVProgressHUD showWithStatus:@"定位中"];
    
    [locMgr startUpdatingLocation];
}

- (IBAction)btnChooseCity:(id)sender{
    BmobQuery *getquery = [BmobQuery queryWithClassName:@"City"];
    [getquery whereKey:@"CityName" equalTo:myCity];
    [getquery findObjectsInBackgroundWithBlock:^(NSArray *arr, NSError *err){
        
        if (arr) {
            
            BmobObject *obj = [arr firstObject];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 obj.objectId,@"objectId",
                                 myCity,@"CityName",nil];
            
            [USER_DEFAULT setObject:dic forKey:@"MyCity"];
            
            [self selectedCity];
            
            includedThisCity = YES;
        }else{
            [SVProgressHUD showErrorWithStatus:@"当前城市未开通"];
            includedThisCity = NO;
        }
        
    }];
    
}
#pragma mark - methods
- (void)selectedCity{
    if (_chooseCityAndChangeSchool) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_LOAD_SCHOOL_WHEN_CHANGE_CITY object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (_beforeRigistView) {
        RegistViewController *registVC = [[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil];
        [self.navigationController pushViewController:registVC animated:YES];
        return;
    }
    if (_justChooseCity) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GETMAINDATA object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GET_WORK_LIST object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        VisitorChooseViewController *visitorVC = [[VisitorChooseViewController alloc] init];
        visitorVC.thisViewIsPush = YES;
        [self.navigationController pushViewController:visitorVC animated:YES];
    }
}

- (void)backPop{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
