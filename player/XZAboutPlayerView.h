//
//  PlayerView.h
//  player
//
//  Created by ding on 2017/6/27.
//  Copyright © 2017年 123. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XZAboutPlayerView;

@protocol XZAboutPlayerViewDelegate <NSObject>

- (void)setDeviceOrientationToPlayerView:(XZAboutPlayerView *)playerView orientation:(UIDeviceOrientation)orientation;

@end

@interface XZAboutPlayerView : UIView

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, weak) id<XZAboutPlayerViewDelegate> delegate;

- (void)startPlay;
- (void)pausePlay;

@end
