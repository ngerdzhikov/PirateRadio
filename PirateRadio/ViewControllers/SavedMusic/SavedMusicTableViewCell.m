//
//  SavedMusicTableViewCell.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicTableViewCell.h"
#import "Constants.h"
#import "DGActivityIndicatorView.h"

typedef enum {
    EnumCellMediaPlaybackStatePlay,
    EnumCellMediaPlaybackStatePause
} EnumCellMediaPlaybackState;

@interface SavedMusicTableViewCell ()

@end

@implementation SavedMusicTableViewCell



- (void)awakeFromNib {
    [super awakeFromNib];
    self.progressPlaceHolderView.center = self.contentView.center;
    [self.contentView bringSubviewToFront:self.progressPlaceHolderView];
    self.playIndicator = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScalePulseOutRapid tintColor:[UIColor colorWithRed:0.14 green:0.38 blue:0.56 alpha:1.0] size:17];
    [self.progressPlaceHolderView addSubview:self.playIndicator];
    self.playIndicator.frame = self.progressPlaceHolderView.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
