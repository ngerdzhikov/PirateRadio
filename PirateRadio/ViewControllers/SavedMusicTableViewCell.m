//
//  SavedMusicTableViewCell.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicTableViewCell.h"

@implementation SavedMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.progressPlaceHolderView.center = self.contentView.center;
    [self.contentView bringSubviewToFront:self.progressPlaceHolderView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
