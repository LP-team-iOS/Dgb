 //
//  ForgotPSAndResetViewController.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/17.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "ForgotPSAndResetViewController.h"
#import "UIView+Border.h"
#import "UITextField+HeaderView.h"
#import "SVProgressHUD.h"
#import "CommonServers.h"

@interface ForgotPSAndResetViewController () {
    
    __weak IBOutlet UITextField *_txfPassword;
    
}

@end

@implementation ForgotPSAndResetViewController

@synthesize phone;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(xMainBlueColor);
    
    //设置返回按钮
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detailBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backPop)];
    backItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *enter = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(resetEnter)];
    enter.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:enter];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_txfPassword addHeaderViewWithSpacing:24.0];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - methods
- (void)backPop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetEnter {
    /**
     *  {"Type":"ForgetPassword","phone":"18824865098","password":"888888"}
     */
    if (_txfPassword.text.length < 6) {
        [SVProgressHUD showErrorWithStatus:@"密码过短"];
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"ForgetPassword",@"Type", [USER_DEFAULT objectForKey:USER_PHONE],@"phone",_txfPassword.text,@"password",nil];
//    
//    [CommonServers callAccountWithDict:dic success:^(NSDictionary *object) {
//        
//    } fail:^(NSString *reason) {
//
//    }];
    
    [CommonServers callCloudWithAPIName:@"Account" andDic:dic success:^(id object) {
        if (object) {
            [SVProgressHUD showSuccessWithStatus:[object objectForKey:@"Value"]];
            if ([[object objectForKey:@"Static"] isEqualToString:@"success"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } fail:^(NSString *reason) {
        [SVProgressHUD showErrorWithStatus:reason];
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
