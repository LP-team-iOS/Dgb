//
//  GuideViewController.m
//  duangongbang
//
//  Created by ljx on 15/7/6.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "GuideViewController.h"
#import "DGBTabBarViewController.h"
#import "UIView+Position.h"
#import <CoreLocation/CoreLocation.h>

@interface GuideViewController ()<CLLocationManagerDelegate>{
    
    CLLocationManager *locMgr;
    __weak IBOutlet UIScrollView *_scrollView;
}

@end

@implementation GuideViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    locMgr = [[CLLocationManager alloc] init];
    
    //  如果没有定位授权则请求授权
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [locMgr requestWhenInUseAuthorization];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _scrollView.contentSize = CGSizeMake(mainScreenWidth * 3, mainScreenHeight);
    UIImageView *img1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"引导页1.jpg"]];
    img1.frame = CGRectMake(0, 0, mainScreenWidth, mainScreenHeight + 20);
    UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"引导页2.jpg"]];
    img2.frame = CGRectMake(mainScreenWidth, 0, mainScreenWidth, mainScreenHeight+20);
    UIImageView *img3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"引导页3.jpg"]];
    img3.frame = CGRectMake(mainScreenWidth * 2, 0, mainScreenWidth, mainScreenHeight+20);
    img1.contentMode = UIViewContentModeScaleAspectFill;
    img2.contentMode = UIViewContentModeScaleAspectFill;
    img3.contentMode = UIViewContentModeScaleAspectFill;
    
    UIButton *inputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inputButton.frame = CGRectMake(Width*2, 0, Width, Height);
//    inputButton.center = CGPointMake(mainScreenWidth * 2.5, mainScreenHeight - 30);
    [inputButton addTarget:self action:@selector(changeWindowView) forControlEvents:UIControlEventTouchUpInside];
    
    [inputButton setBackgroundColor:[UIColor clearColor]];
    
    [_scrollView addSubview:img1];
    [_scrollView addSubview:img2];
    [_scrollView addSubview:img3];
    [_scrollView addSubview:inputButton];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeWindowView{
    UINavigationController *nvc = [[UINavigationController alloc] init];
    DGBTabBarViewController *dgbTBVC = [[DGBTabBarViewController alloc] init];
    [nvc pushViewController:dgbTBVC animated:NO];
    [[UIApplication sharedApplication].delegate window].rootViewController = nvc;
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
