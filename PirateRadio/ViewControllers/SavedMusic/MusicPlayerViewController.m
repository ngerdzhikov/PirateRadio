//
//  MusicControllerView.m
//  PirateRadio
//
//  Created by A-Team User on 15.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import <AVKit/AVKit.h>
#import "LocalSongModel.h"
#import "Constants.h"
#import "CBAutoScrollLabel.h"

@interface MusicPlayerViewController ()

@property (strong, nonatomic) AVPlayer *player;
@property BOOL isSeekInProgress;
@property BOOL isSliding;
@property CMTime chaseTime;
@property AVPlayerStatus playerCurrentItemStatus;

@end

@implementation MusicPlayerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.player = [[AVPlayer alloc] init];
    [self configureMusicControllerView];
    self.songTimeProgress.value = 0.0f;
    
    self.songName.textAlignment = NSTextAlignmentCenter;
    
    __weak MusicPlayerViewController *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateProgressBar];
    }];
    
    
}

}

- (void)updateProgressBar {
    
    if (!self.isSliding) {
        double time = CMTimeGetSeconds(self.player.currentTime);
        double duration = CMTimeGetSeconds(self.player.currentItem.duration);
        self.songTimeProgress.value = time;
        [self.songListDelegate updateProgress:(time / duration) * 100 forSong:self.song];
    }
}


- (void)configureMusicControllerView {
    [self.songTimeProgress addTarget:self action:@selector(sliderIsSliding) forControlEvents:UIControlEventValueChanged];
    [self.songTimeProgress addTarget:self action:@selector(sliderEndedSliding) forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareSong:(LocalSongModel *)song {
    
    if (![self.song.localSongURL isEqual:song.localSongURL]) {
        self.song = song;
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.song.localSongURL options:nil];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(itemDidEndPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        [self.player replaceCurrentItemWithPlayerItem:item];
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
        
        // Register as an observer of the player item's status property
        [item addObserver:self forKeyPath:@"status" options:options context:nil];
        [self setMusicPlayerSongNameAndImage];
    }
}


- (IBAction)musicControllerPlayBtnTap:(id)sender {
    if (self.isPlaying) {
        
        [self pauseLoadedSong];
        [self.playButton setImage:[UIImage imageNamed:@"play_button_icon"] forState:UIControlStateNormal];
        
        [self.songListDelegate didPauseSong:self.song];
    }
    else {
        
        [self playLoadedSong];
        [self.playButton setImage:[UIImage imageNamed:@"pause_button_icon"] forState:UIControlStateNormal];
        
        [self.songListDelegate didStartPlayingSong:self.song];
    }
}

- (IBAction)previousBtnTap:(id)sender {
    
    [self.songListDelegate didRequestPreviousForSong:self.song];
}

- (IBAction)nextBtnTap:(id)sender {
    
    [self.songListDelegate didRequestNextForSong:self.song];
}

- (void)itemDidEndPlaying:(NSNotification *)notification {
    
    [self.songListDelegate didRequestNextForSong:self.song];
}

- (void)setMusicPlayerSongNameAndImage {
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.song.localArtworkURL]];
    if (image) {
        
        self.songImage.image = image;
    }
    else {
        
        self.songImage.image = [UIImage imageNamed:@"unknown_artist_transperent"];
    }
    self.songName.text = self.song.songTitle;
}


- (void)sliderIsSliding {
    
    self.isSliding = YES;
}

-(void) sliderEndedSliding {
    
    [self stopPlayingAndSeekSmoothlyToTime:CMTimeMake(self.songTimeProgress.value * 600, 600)];
    self.isSliding = NO;
}


- (void)stopPlayingAndSeekSmoothlyToTime:(CMTime)newChaseTime {
    
    [self pauseLoadedSong];
    NSLog(@"time = %lf", CMTimeGetSeconds(newChaseTime));
    if (CMTIME_COMPARE_INLINE(newChaseTime, !=, self.chaseTime)) {
        
        self.chaseTime = newChaseTime;
        if (!self.isSeekInProgress) {
            
            [self trySeekToChaseTime];
        }
    }
}

- (void)trySeekToChaseTime {
    
    if (self.playerCurrentItemStatus == AVPlayerItemStatusUnknown) {
        // wait until item becomes ready (KVO player.currentItem.status)
    }
    else if (self.playerCurrentItemStatus == AVPlayerItemStatusReadyToPlay) {
        [self actuallySeekToTime];
    }
}

- (void)actuallySeekToTime {
    
    self.isSeekInProgress = YES;
    CMTime seekTimeInProgress = self.chaseTime;
    [self.player seekToTime:seekTimeInProgress toleranceBefore:kCMTimeZero
             toleranceAfter:kCMTimeZero completionHandler:
     ^(BOOL isFinished) {
         if (CMTIME_COMPARE_INLINE(seekTimeInProgress, ==, self.chaseTime)) {
             self.isSeekInProgress = NO;
             [self.player play];
         }
         else{
             [self trySeekToChaseTime];
         }
     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                self.playerCurrentItemStatus = AVPlayerStatusReadyToPlay;
                self.songTimeProgress.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                break;
            case AVPlayerItemStatusFailed:
                // Failed. Examine AVPlayerItem.error
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

    }
    
    [MPNowPlayingInfoCenter.defaultCenter setPlaybackState:MPNowPlayingPlaybackStatePlaying];
    [self.player play];
}

- (void)pauseLoadedSong {
    [AVAudioSession.sharedInstance setActive:NO error:nil];
    [MPNowPlayingInfoCenter.defaultCenter setPlaybackState:MPNowPlayingPlaybackStatePaused];
    [self.player pause];
}

- (BOOL)isPlaying {
    
    return self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
}

- (LocalSongModel *)nowPlaying {
    return self.song;
}

- (void)setPlayerPlayPauseButtonState:(EnumCellMediaPlaybackState)state {
    [self.playButton setImage:[UIImage imageNamed:@"play_button_icon"] forState:UIControlStateNormal];
    if (state == EnumCellMediaPlaybackStatePause) {
        [self.playButton setImage:[UIImage imageNamed:@"pause_button_icon"] forState:UIControlStateNormal];
    }
}

@end
