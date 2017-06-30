//
//  PlayerMaskView.m
//  player
//
//  Created by ding on 2017/6/27.
//  Copyright © 2017年 123. All rights reserved.
//

#import "XZAboutPlayerMaskView.h"
#import "Masonry.h"

@interface XZAboutPlayerMaskView ()

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIButton *pauseButton;
@property (nonatomic, weak) UIButton *fullScreenButton;
@property (nonatomic, weak) UISlider *sliderView;
@property (nonatomic, weak) UILabel *startLabel;
@property (nonatomic, weak) UILabel *endLabel;
@property (nonatomic, weak) UIProgressView *playProgressView;

@end

@implementation XZAboutPlayerMaskView

- (instancetype)init
{
    if (self = [super init]) {
        [self prepareForSubView];
    }
    return self;
}

- (void)prepareForSubView
{
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:topView];
    self.topView = topView;
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:bottomView];
    self.bottomView = bottomView;
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.and.left.and.right.equalTo(self);
        make.height.equalTo(@44);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.and.left.and.right.equalTo(self);
        make.height.equalTo(@50);
    }];
    
    [self prepareForTopView];
    [self prepareForBottomView];
}

- (void)prepareForTopView
{
    UILabel *titleView = [[UILabel alloc] init];
    titleView.text = @"协众金融";
    titleView.font = [UIFont systemFontOfSize:14];
    titleView.textColor = [UIColor whiteColor];
    [self.topView addSubview:titleView];
    
    UIButton *closePlayButton = [[UIButton alloc] init];
    closePlayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [closePlayButton setImage:[UIImage imageNamed:@"Register_back.png"] forState:UIControlStateNormal];
    [closePlayButton addTarget:self action:@selector(closePlayerView) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:closePlayButton];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.topView);
    }];
    
    [closePlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.topView);
        make.leading.offset(15);
        make.size.mas_equalTo(CGSizeMake(32, 15));
    }];
    
    closePlayButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 23);
}

- (void)prepareForBottomView
{
    UIButton *pause = [[UIButton alloc] init];
    [pause setBackgroundImage:[UIImage imageNamed:@"videoPlayBtn"] forState:UIControlStateNormal];
    [pause setBackgroundImage:[UIImage imageNamed:@"videoPauseBtn"] forState:UIControlStateSelected];
    [pause addTarget:self action:@selector(pauseOrPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:pause];
    self.pauseButton = pause;
    
    UISlider *sliderView = [[UISlider alloc] init];
    [sliderView setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    sliderView.minimumTrackTintColor = [UIColor whiteColor];
    sliderView.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [sliderView addTarget:self action:@selector(sliderViewDidValueChange) forControlEvents:UIControlEventValueChanged];
    [sliderView addTarget:self action:@selector(sliderViewDidTouchDown) forControlEvents:UIControlEventTouchDown];
    [sliderView addTarget:self action:@selector(sliderViewDidTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside | UIControlEventTouchDragExit];
    [self.bottomView addSubview:sliderView];
    self.sliderView = sliderView;
    
    UIProgressView *playProgressView = [[UIProgressView alloc] init];
    playProgressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    playProgressView.trackTintColor = [UIColor clearColor];
    [self.bottomView addSubview:playProgressView];
    self.playProgressView = playProgressView;
    
    UILabel *startLabel = [[UILabel alloc] init];
    startLabel.font = [UIFont systemFontOfSize:12];
    startLabel.textColor = [UIColor whiteColor];
    startLabel.text = @"00:00";
    [self.bottomView addSubview:startLabel];
    self.startLabel = startLabel;
    
    UILabel *endLabel = [[UILabel alloc] init];
    endLabel.font = [UIFont systemFontOfSize:12];
    endLabel.textColor = [UIColor whiteColor];
    endLabel.text = @"00:00";
    [self.bottomView addSubview:endLabel];
    self.endLabel = endLabel;
    
    UIButton *fullScreen = [[UIButton alloc] init];
    [fullScreen setBackgroundImage:[UIImage imageNamed:@"kr-video-player-fullscreen"] forState:UIControlStateNormal];
    [fullScreen setBackgroundImage:[UIImage imageNamed:@"exitFullScreen"] forState:UIControlStateSelected];
    [fullScreen addTarget:self action:@selector(fullScreenOrClose) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:fullScreen];
    self.fullScreenButton = fullScreen;
    
    [pause mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.offset(15);
        make.centerY.equalTo(self.bottomView);
    }];
    
    [playProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.bottomView);
        make.width.equalTo(@([UIScreen mainScreen].bounds.size.width / 2.5));
    }];
    
    [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bottomView);
        make.height.equalTo(@15);
        make.leading.and.width.equalTo(playProgressView);
    }];
    
    [fullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bottomView);
        make.right.offset(-15);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bottomView);
        make.right.equalTo(playProgressView.mas_left).offset(-10);
    }];
    
    [endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.bottomView);
        make.left.equalTo(playProgressView.mas_right).offset(10);
    }];
}

- (void)setStartTime:(CGFloat)startTime endTime:(CGFloat)endTime currentProgress:(CGFloat)currentProgress
{
    NSInteger proSecond = (NSInteger)startTime % 60;
    NSInteger proMin = (NSInteger)startTime / 60;
    NSInteger durationSecond = (NSInteger)endTime % 60;
    NSInteger durationMin = (NSInteger)endTime / 60;
    
    self.startLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSecond];
    self.endLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durationMin, durationSecond];
    [self.sliderView setValue:startTime animated:YES];
    self.sliderView.maximumValue = endTime;
}

- (void)pauseOrPlay
{
    self.pauseButton.selected = !self.pauseButton.isSelected;
    self.playing = self.pauseButton.isSelected;
    self.pauseOrPlayBlock(self.pauseButton.isSelected);
}

- (void)sliderViewDidValueChange
{
    self.sliderView.selected = YES;
    self.sliderValueChangeBlock(self.sliderView.value);
}

- (void)sliderViewDidTouchDown
{
    self.sliderView.selected = YES;
    self.sliderDidTouchBlock(self.sliderView.isSelected);
}

- (void)sliderViewDidTouchUp
{
    self.sliderView.selected = NO;
    self.sliderDidTouchBlock(self.sliderView.isSelected);
}

- (void)fullScreenOrClose
{
    self.fullScreenButton.selected = !self.fullScreenButton.isSelected;
    self.fullScreen = self.fullScreenButton.isSelected;
    self.fullScreenBlock(self.isFullScreen);
}

- (void)closePlayerView
{
    self.closePlayerViewBlock();
}

- (void)setPlaying:(BOOL)playing
{
    _playing = playing;
    
    self.pauseButton.selected = playing;
}

- (void)setFullScreen:(BOOL)fullScreen
{
    _fullScreen = fullScreen;
    
    self.fullScreenButton.selected = fullScreen;
}

- (void)setLoadingProgress:(CGFloat)loadingProgress
{
    _loadingProgress = loadingProgress;
    
    self.playProgressView.progress = loadingProgress;
}

- (void)needHideTool:(BOOL)hidden
{
    if (hidden) {
        
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.offset(-34);
        }];
        
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.offset(34);
        }];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            self.topView.hidden = hidden;
            self.bottomView.hidden = hidden;
        }];
    } else {
        
        [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self);
        }];
        
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(self);
        }];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            [self layoutIfNeeded];
            self.topView.hidden = hidden;
            self.bottomView.hidden = hidden;
        }];
    }
}

@end
