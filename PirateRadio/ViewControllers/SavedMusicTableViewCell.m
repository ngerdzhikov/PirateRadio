//
//  SavedMusicTableViewCell.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicTableViewCell.h"
#import "Constants.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>

typedef enum {
    EnumCellMediaPlaybackStatePlay,
    EnumCellMediaPlaybackStatePause
} EnumCellMediaPlaybackState;

@interface SavedMusicTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *progressPlaceHolderView;

@end

@implementation SavedMusicTableViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    self.progressPlaceHolderView.center = self.contentView.center;
    [self.contentView bringSubviewToFront:self.progressPlaceHolderView];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onPlayButtonTap:) name:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onPauseButtonTap:) name:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil];
    self.circleProgressBar = [self circularProgressBarWithFrame:self.progressPlaceHolderView.bounds];
    [self.progressPlaceHolderView addSubview:self.circleProgressBar];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)onPlayButtonTap:(NSNotification *)notification {
    NSDictionary<NSString *, id> *userInfo = notification.userInfo;
    if ([self isEqual:userInfo[@"cell"]])
    {
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause];
    }
    else {
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay];
        self.circleProgressBar.value = 0;
    }
}

-(void)onPauseButtonTap:(NSNotification *)notification {
    NSDictionary<NSString *, id> *userInfo = notification.userInfo;
    if ([self isEqual:userInfo[@"cell"]])
    {
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay];
    }
}

- (void)setMediaPlayBackState:(EnumCellMediaPlaybackState) playbackState {
    if (playbackState == EnumCellMediaPlaybackStatePlay) {
        self.circleProgressBar.unitString = BUTTON_TITLE_PLAY_STRING;
    }
    else {
        self.circleProgressBar.unitString = BUTTON_TITLE_PAUSE_STRING;
    }
}

- (MBCircularProgressBarView *) circularProgressBarWithFrame:(CGRect) frame {
    MBCircularProgressBarView *circleProgressBar = [[MBCircularProgressBarView alloc] initWithFrame:frame];
    circleProgressBar.progressRotationAngle = 90;
    circleProgressBar.progressAngle = 180;
    circleProgressBar.backgroundColor = [UIColor clearColor];
    circleProgressBar.progressColor = [UIColor blueColor];
    circleProgressBar.progressStrokeColor = [UIColor blueColor];
    circleProgressBar.emptyLineColor = [UIColor clearColor];
    circleProgressBar.emptyLineStrokeColor = [UIColor clearColor];
    circleProgressBar.progressLineWidth = 3;
    circleProgressBar.showValueString = YES;
    circleProgressBar.showUnitString = YES;
    circleProgressBar.value = 0;
    circleProgressBar.unitString = @"c";
    circleProgressBar.unitFontSize = 15;
    circleProgressBar.valueFontName = @"Icons South St";
    circleProgressBar.unitFontName = @"Icons South St";
    return circleProgressBar;
}

@end
