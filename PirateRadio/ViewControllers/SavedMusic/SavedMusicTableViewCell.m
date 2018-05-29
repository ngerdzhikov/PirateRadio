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
    self.circleProgressBar = [self circularProgressBarWithFrame:self.progressPlaceHolderView.bounds];
    [self.progressPlaceHolderView addSubview:self.circleProgressBar];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (MBCircularProgressBarView *) circularProgressBarWithFrame:(CGRect) frame {
    MBCircularProgressBarView *circleProgressBar = [[MBCircularProgressBarView alloc] initWithFrame:frame];
    circleProgressBar.progressRotationAngle = 50;
    circleProgressBar.progressAngle = 100;
    circleProgressBar.backgroundColor = [UIColor clearColor];
    circleProgressBar.progressColor = [UIColor blueColor];
    circleProgressBar.progressStrokeColor = [UIColor blueColor];
    circleProgressBar.emptyLineColor = [UIColor clearColor];
    circleProgressBar.emptyLineStrokeColor = [UIColor clearColor];
    circleProgressBar.progressLineWidth = 3;
    circleProgressBar.showValueString = YES;
    circleProgressBar.textOffset = CGPointMake(0, -0.5);
    circleProgressBar.emptyLineColor = [UIColor grayColor];
    circleProgressBar.showUnitString = YES;
    circleProgressBar.value = 0;
    circleProgressBar.maxValue = 100;
    circleProgressBar.unitString = @"c";
    circleProgressBar.unitFontSize = 18;
    circleProgressBar.valueFontName = @"Icons South St";
    circleProgressBar.unitFontName = @"Icons South St";
    return circleProgressBar;
}


@end
