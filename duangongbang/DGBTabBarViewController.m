//
//  DGBTabBarViewController.m
//  duangongbang
//
//  Created by ljx on 15/4/23.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "DGBTabBarViewController.h"
#import "MainViewController.h"
#import "DGListViewController.h"
#import "DGBTabBar.h"
#import "MYViewController.h"
#import "MessageViewController.h"
#import "LaunchScreenViewController.h"
#import "LoginViewController.h"
#import <BmobSDK/BmobUser.h>
#import <CoreLocation/CoreLocation.h>


//#import "UINavigationController+FDFullscreenPopGesture.h"

@interface DGBTabBarViewController ()<UITabBarControllerDelegate,UITabBarDelegate,UIAlertViewDelegate>{
    BmobUser *bUser;
    
}
@property (nonatomic, assign) BOOL screensaverLaunched;
@property (strong, nonatomic) UIView *tabbarView;
@property (strong, nonatomic) UIView *popView;
@property (assign, nonatomic) NSUInteger lastSelectedItem;
@end

@implementation DGBTabBarViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addAllChildVC];
    [self addCustomTabBar];
    self.tabBar.translucent = NO;
//    self.tabBar.backgroundColor = RGB(48, 50, 63, 1.0);
    self.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.selectedViewController endAppearanceTransition];
}


-(void)viewWillDisappear:(BOOL)animated {
    [self.selectedViewController beginAppearanceTransition: NO animated: animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.selectedViewController endAppearanceTransition];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UINavigationController *nav = [[UINavigationController alloc] init];
        LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [nav pushViewController:logVC animated:NO];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - 添加子视图
- (void)addAllChildVC{
    UINavigationController *home = [[UINavigationController alloc] init];
    MainViewController *mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [home pushViewController:mainVC animated:NO];
    
    UINavigationController *home1 = [[UINavigationController alloc] init];
    DGListViewController *dgl = [[DGListViewController alloc] initWithNibName:@"DGListViewController" bundle:nil];
    
    [home1 pushViewController:dgl animated:NO];
    
    UINavigationController *home2 = [[UINavigationController alloc] init];
    MessageViewController *messageVC = [[MessageViewController alloc] init];
    [home2 pushViewController:messageVC animated:NO];
    
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"MY" bundle:nil];
    MYViewController *myVC = [myStoryboard instantiateInitialViewController];
    UINavigationController *home3 = [[UINavigationController alloc] init];
    [home3 pushViewController:myVC animated:NO];
    
    [self addChildVC:home title:nil imageName:@"首页" selectedImageName:@"首页selected"];
    [self addChildVC:home1 title:nil imageName:@"短工" selectedImageName:@"短工selected"];
    [self addChildVC:home2 title:nil imageName:@"消息" selectedImageName:@"消息selected"];
    [self addChildVC:home3 title:nil imageName:@"个人" selectedImageName:@"个人selected"];
    
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.barTintColor = [UIColor whiteColor];
    
}

- (void)addCustomTabBar
{
    DGBTabBar *customTabBar = [[DGBTabBar alloc] init];
    [self setValue:customTabBar forKey:@"tabBar"];
}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName{
    
//    childVC.tabBarItem.image = [UIImage imageNamed:imageName];
    
//    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
//    textAttrs[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
//    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:10];
//    [childVC.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
//    
//    NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
//    selectedTextAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
//    [childVC.tabBarItem setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
    
    childVC.tabBarItem.image = [[UIImage imageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //声明：这张图片按照原来的样子显示出来，不要自动渲染成其他颜色
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [self addChildViewController:childVC];
    
}


@end