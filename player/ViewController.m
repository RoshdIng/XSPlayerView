//
//  ViewController.m
//  player
//
//  Created by ding on 2017/6/27.
//  Copyright © 2017年 123. All rights reserved.
//

#import "ViewController.h"
#import "XZAboutPlayerView.h"
#import "Masonry.h"

@interface ViewController () <XZAboutPlayerViewDelegate>

@property (nonatomic, weak) XZAboutPlayerView *playView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    XZAboutPlayerView *playView = [[XZAboutPlayerView alloc] init];
    playView.videoPath = @"https://www.xzjinrong.com/static/xzjinrong5s.mp4";
    playView.delegate = self;
    [self.view addSubview:playView];
    self.playView = playView;
    
    [playView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.and.left.and.right.equalTo(self.view);
        make.height.equalTo(@200);
    }];
}

- (void)setDeviceOrientationToPlayerView:(XZAboutPlayerView *)playerView orientation:(UIDeviceOrientation)orientation
{
    @try {
        //[NOTE]: 先设成upsidedown，再设到目的方向，才能保证最后一次生效，否则有时候设置方向不起作用
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortraitUpsideDown]
                                    forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation]
                                    forKey:@"orientation"];
        
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            
            [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.height.equalTo(@(self.view.bounds.size.height));
            }];
        } else if (orientation == UIDeviceOrientationPortrait) {
            
            [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
                
                make.height.equalTo(@200);
            }];
        }
        
        [self.view layoutIfNeeded];
    }
    @catch (NSException *exception) {
        NSLog(@"setDeviceOrientationTo exception %@", exception);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"%s", __func__);
}


@end
