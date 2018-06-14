//
//  SavedMusicTableViewCell.h
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBCircularProgressBarView;

@interface SavedMusicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *musicTitle;
@property (strong, nonatomic) MBCircularProgressBarView *circleProgressBar;
@property (weak, nonatomic) IBOutlet UILabel *songDurationLabel;

@end
