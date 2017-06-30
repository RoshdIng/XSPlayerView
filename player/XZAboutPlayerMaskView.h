//
//  PlayerMaskView.h
//  player
//
//  Created by ding on 2017/6/27.
//  Copyright © 2017年 123. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZAboutPlayerMaskView : UIView

/**
 是否正在播放
 */
@property (nonatomic, assign, getter = isPlaying) BOOL playing;

/**
 是否全屏
 */
@property (nonatomic, assign, getter = isFullScreen) BOOL fullScreen;

/**
 用户自己点的是否全屏
 */
@property (nonatomic, copy) void(^fullScreenBlock)(BOOL isFullScreen);

/**
 用户自己点的是否播放
 */
@property (nonatomic, copy) void(^pauseOrPlayBlock)(BOOL isShouldPlay);

/**
 滑块偏移
 */
@property (nonatomic, copy) void(^sliderValueChangeBlock)(CGFloat value);

/**
 用户是否已经不再触摸滑块
 */
@property (nonatomic, copy) void(^sliderDidTouchBlock)(BOOL isStillTouch);

/**
 关闭播放器
 */
@property (nonatomic, copy) void(^closePlayerViewBlock)();

/**
 加载进度
 */
@property (nonatomic, assign) CGFloat loadingProgress;

- (void)needHideTool:(BOOL)hidden;
- (void)setStartTime:(CGFloat)startTime endTime:(CGFloat)endTime currentProgress:(CGFloat)currentProgress;

@end
