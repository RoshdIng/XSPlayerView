//
//  PlayerView.m
//  player
//
//  Created by ding on 2017/6/27.
//  Copyright © 2017年 123. All rights reserved.
//

#import "XZAboutPlayerView.h"
#import "XZAboutPlayerMaskView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Direction.h"

#define WeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#define XZLogFunc XZLog(@"%s", __func__)

#ifdef DEBUG
#define XZLog(...) NSLog(__VA_ARGS__)
#else
#define XZLog(...)
#endif

@interface XZAboutPlayerView ()

@property (nonatomic, weak) XZAboutPlayerMaskView *maskView;

/**
 隐藏工具栏
 */
@property (nonatomic, assign, getter = isHideMaskTool) BOOL hideMaskTool;

/**
 提示加载中
 */
@property (nonatomic, strong) UILabel *tipLabel;

/**
 用户自己点的是否播放，用来判断当缓存到可以播放时，是否调用startPlay
 */
@property (nonatomic, assign, getter = isUserClickPlayOrPause) BOOL userClickPlayOrPause;

/**
 播放结束
 */
@property (nonatomic, assign, getter = isPlayComplete) BOOL playComplete;

/**
 是否在加载中
 */
@property (nonatomic, assign, getter = isLoading) BOOL loading;

/**
 播放总时间
 */
@property (nonatomic, assign) CGFloat totalPlayTime;

/**
 加载进度
 */
@property (nonatomic, assign) CGFloat loadProgress;

/**
 当前滑块value
 */
@property (nonatomic, assign) CGFloat sliderCurrentValue;

/**
 视频缓存路径
 */
@property (nonatomic, copy) NSString *videoSavePath;

@property (nonatomic, strong) id timeObserve;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end

@implementation XZAboutPlayerView

- (instancetype)init
{
    if (self = [super init]) {
        [self prepareForSubView];
        self.layer.masksToBounds = YES;
        
        _hideMaskTool = NO;
        _userClickPlayOrPause = YES;
        _playComplete = NO;
        _videoSavePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"xzjinrong.mp4"];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleHandle)];
        [self.maskView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleHandle)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)prepareForSubView
{
    _player = [[AVPlayer alloc] init];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer insertSublayer:_playerLayer atIndex:0];
    
    XZAboutPlayerMaskView *maskView = [[XZAboutPlayerMaskView alloc] init];
    [self addSubview:maskView];
    self.maskView = maskView;
    
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.text = @"加载中...";
    _tipLabel.font = [UIFont systemFontOfSize:14];
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.backgroundColor = [UIColor blackColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.layer.cornerRadius = 5;
    _tipLabel.layer.masksToBounds = YES;
    _tipLabel.hidden = YES;
    [self addSubview:_tipLabel];
    
    @WeakObj(maskView);
    @WeakObj(self);
    
    maskView.fullScreenBlock = ^(BOOL isFullScreen) {
        
        @StrongObj(self);
        if ([self.delegate respondsToSelector:@selector(setDeviceOrientationToPlayerView:orientation:)]) {
            [self.delegate setDeviceOrientationToPlayerView:self orientation:isFullScreen ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationPortrait];
        }
    };
    maskView.pauseOrPlayBlock = ^(BOOL isShouldPlay) {
        
        @StrongObj(self);
        
        _userClickPlayOrPause = isShouldPlay;
        
        if (isShouldPlay) {
            
            [self startPlay];
            self.tipLabel.hidden = YES;
        } else {
            [self pausePlay];
        }
    };
    maskView.sliderValueChangeBlock = ^(CGFloat value) {
        @StrongObj(self);
        
        [maskViewWeak setStartTime:value endTime:self.totalPlayTime currentProgress:value];
        [self pausePlay];
        self.sliderCurrentValue = value;
        
        [self.player seekToTime:CMTimeMake(self.sliderCurrentValue, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
            [self startPlay];
        }];
    };
    
    maskView.sliderDidTouchBlock = ^(BOOL isStillTouch) {
        @StrongObj(self);
        
        if (isStillTouch) {
            
            [self pausePlay];
        } else {
            
            if (!self.player.currentItem.duration.value || !self.player.currentItem.duration.timescale) return;
            
            [self.player seekToTime:CMTimeMake(self.sliderCurrentValue, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                
                [self startPlay];
            }];
        }
    };
    
    maskView.closePlayerViewBlock = ^{
        @StrongObj(self);
        
        if (maskViewWeak.isFullScreen) {
            
            if ([self.delegate respondsToSelector:@selector(setDeviceOrientationToPlayerView:orientation:)]) {
                [self.delegate setDeviceOrientationToPlayerView:self orientation:UIDeviceOrientationPortrait];
                maskViewWeak.fullScreen = NO;
            }
        } else {
            [self pausePlay];
            [self removeAllNotification];
            [self removeFromSuperview];
        }
    };
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.playerLayer.frame = self.frame;
    CGSize textSize = [self.tipLabel.text boundingRectWithSize:self.size
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                       context:nil].size;
    self.tipLabel.size = CGSizeMake(textSize.width + 50, textSize.height + 20);
    self.tipLabel.center = self.center;
}

- (void)setVideoPath:(NSString *)videoPath
{
    _videoPath = videoPath;
    
    if (!videoPath.length) return;
    
    AVAsset *asset = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoSavePath]) {
        asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.videoSavePath]];
    } else {
        asset = [AVAsset assetWithURL:[NSURL URLWithString:videoPath]];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10) self.player.automaticallyWaitsToMinimizeStalling = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterrupt:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [self setTheProgressOfPlayTime];
}

- (void)setTheProgressOfPlayTime
{
    if (self.isPlayComplete) return;
    
    @WeakObj(self);
    _timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        @StrongObj(self);
        CGFloat currentTime = CMTimeGetSeconds(time);
        CGFloat totalTime = 0;
        if (self.playerItem.duration.value) {
            totalTime = CMTimeGetSeconds(self.playerItem.duration);
        }
        
        self.totalPlayTime = totalTime;
        
        [self.maskView setStartTime:currentTime endTime:totalTime currentProgress:currentTime / totalTime];
        
        if (currentTime == totalTime) {
            self.playComplete = YES;
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                
                [self startPlay];
                
                XZLog(@"prepare to play");
            } else if (self.playerItem.status == AVPlayerItemStatusFailed || self.playerItem.status == AVPlayerStatusFailed) {
                
                [self pausePlay];
//                [MBProgressHUD showMessage:@"播放失败" hideByAfterDealy:1.0 inView:self.superview];
                XZLog(@"player has failed . %@", self.playerItem.error);
            }
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { // 缓存不足，需要进行暂停缓存
            
            [self pausePlay];
            self.tipLabel.hidden = NO;
            self.loading = YES;
            
            XZLog(@"play pause");
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) { // 缓存足够当前播放
            
            if (self.isPlayComplete) return;
            
            if (self.isUserClickPlayOrPause && self.playerItem.isPlaybackLikelyToKeepUp) {
                [self startPlay];
                self.tipLabel.hidden = YES;
            }
            
//            [MBProgressHUD hideForView:self];
            self.loading = NO;
            
            XZLog(@"playbackLikelyToKeepUp");
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration = self.playerItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            self.maskView.loadingProgress = timeInterval / totalDuration;
            self.loadProgress = timeInterval;
            
            // 缓存到本地
            if (timeInterval == totalDuration && ![[NSFileManager defaultManager] fileExistsAtPath:self.videoSavePath]) {
                NSLog(@"download success");
                
                AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                
                // 获取AVAsset中的音频或者视频
                // 保存视频到本地
                NSError *errorAudio = nil;
                AVAssetTrack *assetAudioTrack = [self.playerItem.asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.playerItem.asset.duration)
                                    ofTrack:assetAudioTrack
                                     atTime:kCMTimeZero
                                      error:&errorAudio];
                NSError *errorVideo = nil;
                AVAssetTrack *assetVideoTrack = [self.playerItem.asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
                [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.playerItem.asset.duration)
                                    ofTrack:assetVideoTrack
                                     atTime:kCMTimeZero
                                      error:&errorVideo];
                [videoTrack setPreferredTransform:self.playerItem.asset.preferredTransform];
                
                AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
                exporter.outputURL = [NSURL fileURLWithPath:self.videoSavePath];
                exporter.outputFileType = AVFileTypeMPEG4;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:self.videoSavePath]) {
                    NSError *error;
                    if ([[NSFileManager defaultManager] removeItemAtPath:self.videoSavePath error:&error] == NO) {
                        NSLog(@"removeitematpath %@ error :%@", self.videoSavePath, error);
                    }
                }
                
                [exporter exportAsynchronouslyWithCompletionHandler:^{
                   
                    if (exporter.status == AVAssetExportSessionStatusCompleted) {
                        XZLog(@"exporter complete");
                    } else if (exporter.status == AVAssetExportSessionStatusFailed) {
                        XZLog(@"exporter failed . %@ ", exporter.error);
                    }
                }];
            }
        }
    }
}

- (void)playDidEnd:(NSNotification *)notification
{
    @WeakObj(self);
    
    [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
        
        @StrongObj(self);
        [self.maskView setStartTime:0 endTime:self.totalPlayTime currentProgress:0];
        self.playComplete = YES;
    }];
    
    [self pausePlay];
}

- (void)playInterrupt:(NSNotification *)notification
{
    [self pausePlay];
}

- (void)startPlay
{
    [self.player play];
    self.maskView.playing = YES;
}

- (void)pausePlay
{
    [self.player pause];
    self.maskView.playing = NO;
}

- (void)singleHandle
{
    self.hideMaskTool = !self.isHideMaskTool;
    
    if (self.isHideMaskTool) { // 隐藏工具栏
        
        [self.maskView needHideTool:YES];
    } else { // 不隐藏
        [self.maskView needHideTool:NO];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            [self.maskView needHideTool:YES];
//            self.hideMaskTool = YES;
//        });
    }
}

- (void)doubleHandle
{
    if ([self.delegate respondsToSelector:@selector(setDeviceOrientationToPlayerView:orientation:)] && !self.isLoading) {
        [self.delegate setDeviceOrientationToPlayerView:self orientation:UIDeviceOrientationLandscapeLeft];
        self.maskView.fullScreen = YES;
    }
}

- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [self.player currentItem].loadedTimeRanges;
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
    CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

- (void)removeAllNotification
{
    [self.player removeTimeObserver:self.timeObserve];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
    self.tipLabel = nil;
    self.delegate = nil;
    [self.playerLayer removeFromSuperlayer];
    [self.tipLabel removeFromSuperview];
    [self.maskView removeFromSuperview];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
