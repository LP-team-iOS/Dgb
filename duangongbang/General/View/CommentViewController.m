//
//  CommentViewController.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/12.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "CommentViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ComentTableViewCell.h"
#import "WorkCommentTableViewCell.h"
#import "CommonServers.h"
#import <BmobSDK/BmobUser.h>
#import "SVProgressHUD.h"
#import "LoginViewController.h"

@interface CommentViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    BmobUser *bUser;
    UIAlertView *_alertInput;
    NSString *_adviseObjectId;
    __weak IBOutlet UIButton *_btnClose;
    __weak IBOutlet UITableView *_tableView;

}

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bUser = [ShareDataSource sharedDataSource].myData;
    
    _alertInput = [[UIAlertView alloc] initWithTitle:@"回复评论" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ComentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"WorkCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"WorkComment"];
    _btnClose.layer.cornerRadius = 20.0;
    [_btnClose addTarget:self action:@selector(closeTheViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCommentWhenCommentSuccess:) name:@"commentSuccess" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"commentSuccess" object:nil];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    bUser = [BmobUser getCurrentUser];
    if (!bUser) {
        [self chackIsLoginAndAlert];
        return;
    }
    
    NSString *strReply;
    if ([[_commentList objectAtIndex:indexPath.row] objectForKey:@"ReComment"]) {
        _adviseObjectId = [[[_commentList objectAtIndex:indexPath.row] objectForKey:@"ReComment"] objectForKey:@"objectId"];
        strReply = [[[_commentList objectAtIndex:indexPath.row] objectForKey:@"ReComment"] objectForKey:@"NickName"];
    }else {
        _adviseObjectId = [[_commentList objectAtIndex:indexPath.row] objectForKey:@"objectId"];
        strReply = [[_commentList objectAtIndex:indexPath.row] objectForKey:@"NickName"];
    }
    
    [_alertInput setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    _alertInput.tag = 10000;
    
    [_alertInput textFieldAtIndex:0].placeholder = [NSString stringWithFormat:@"回复 %@ :",strReply];
    [_alertInput show];
    
}

#pragma mark - UITableViewDatasources
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_commentList objectAtIndex:indexPath.row] objectForKey:@"ReComment"]) {
        return [tableView fd_heightForCellWithIdentifier:@"CommentCell" cacheByIndexPath:indexPath configuration:^(id cell) {
            [cell showDataToViewWithDic:[_commentList objectAtIndex:indexPath.row]];
        }];
    }else {
        return [tableView fd_heightForCellWithIdentifier:@"WorkComment" cacheByIndexPath:indexPath configuration:^(id cell) {
            [cell showDataToViewWithDic:[_commentList objectAtIndex:indexPath.row]];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_commentList objectAtIndex:indexPath.row] objectForKey:@"ReComment"]) {
        static NSString *simpleIdentify = @"CommentCell";
        ComentTableViewCell *cell = (ComentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify forIndexPath:indexPath];
        [cell showDataToViewWithDic:[_commentList objectAtIndex:indexPath.row]];
        return cell;
    }else {
        static NSString *simpleIdentify = @"WorkComment";
        ComentTableViewCell *cell = (ComentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleIdentify forIndexPath:indexPath];
        [cell showDataToViewWithDic:[_commentList objectAtIndex:indexPath.row]];
        return cell;
    }
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            UITextField *text = [alertView textFieldAtIndex:0];
            
            if ([text.text isEqualToString:@""]) {
                return;
            }
            
            /**
             *  {"Type":"ReComment","Version":"3","UserObjectId":"73eea9a3d5","WorkObjectId":"7013a59e55","Content":"感觉还行，继续加油","AdviseObjectId":"f5ea273017"}
             */
            bUser = [BmobUser getCurrentUser];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_adviseObjectId, @"AdviseObjectId", bUser.objectId, @"UserObjectId", @"ReComment", @"Type", kCloudVersion, @"Version", _workObjectId, @"WorkObjectId", text.text, @"Content", nil];
            [SVProgressHUD show];
            [CommonServers callCloudWithAPIName:kCloudInteractive andDic:dict success:^(id object) {
                if (object) {
                    if ([[object objectForKey:@"Static"] isEqualToString:@"success"]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_GET_WORK_DETAIL object:nil];
                        [SVProgressHUD showSuccessWithStatus:@"评论成功"];
                    }else {
                        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[object objectForKey:@"Value"]]];
                    }
                }
            } fail:^(NSString *reason) {
                [SVProgressHUD showErrorWithStatus:reason];
            }];
        }
    }else if (alertView.tag == 10001) {
        if (buttonIndex == 1) {
            UINavigationController *nav = [[UINavigationController alloc] init];
            LoginViewController *logVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            [nav pushViewController:logVC animated:NO];
            [self presentViewController:nav animated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_HIDE_COMMENTVC object:nil];
            }];
        }
    }

    
}

#pragma mark - methods
- (void)chackIsLoginAndAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"先登录一下呗~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去登录", nil];
    alertView.tag = 10001;
    [alertView show];
}

- (void)closeTheViewController {
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_KVO_HIDE_COMMENTVC object:nil];
}

- (void)refreshCommentWhenCommentSuccess:(NSNotification *)notification {
    _commentList = notification.object;
    [_tableView reloadData];
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
