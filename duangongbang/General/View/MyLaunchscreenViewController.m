//
//  MyLaunchscreenViewController.m
//  duangongbang
//
//  Created by ljx on 15/6/30.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "MyLaunchscreenViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MyLaunchscreenViewController (){
    MPMoviePlayerController *_player;
    UIImageView *_logoImg;
}

@end

@implementation MyLaunchscreenViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *myFilePath = [[NSBundle mainBundle] pathForResource:@"launchVideo" ofType:@"mp4"];
    
    NSURL *movieURL = [NSURL fileURLWithPath:myFilePath];
    if (_player) {
        [_player setContentURL:movieURL];
    }else{
        _player =[[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    }
    
    [self.view addSubview:_player.view];//设置写在添加之后
    
    [_player prepareToPlay];
    
    _player.shouldAutoplay=YES;
    
    [_player setControlStyle:MPMovieControlStyleNone];
    
    [_player setFullscreen:YES animated:NO];
    CGRect rect = [UIScreen mainScreen].bounds;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [_player.view setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    _player.scalingMode = MPMovieScalingModeAspectFill;
    
    [self.view addSubview:_logoImg];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_player play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreen:) name: MPMoviePlayerDidExitFullscreenNotification object:nil];
    _logoImg.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0, 150, 45, 45);
    _logoImg.image =[UIImage imageNamed:@"ICON_Launch.png"];
    [_logoImg bringSubviewToFront:self.view];
    _logoImg.alpha = 0.3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissMoviePlayerViewControllerAnimated];
        });
    });
    [UIView animateWithDuration:3.0 animations:^{
        _logoImg.alpha = 1.0;
        _logoImg.center = _player.view.center;
        
    } completion:^(BOOL finished){
        if (finished) {
            //[_player.view removeFromSuperview];
            [self dismissMoviePlayerViewControllerAnimated];
            [_player stop];
            
        }
    }];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)exitFullScreen:(NSNotification *)notification{
    
    [_player.view removeFromSuperview];
    
    LOG(@"remove player");
    
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
