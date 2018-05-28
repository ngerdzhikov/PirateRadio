//
//  MusicControllerView.h
//  PirateRadio
//
//  Created by A-Team User on 15.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SavedMusicTableViewController;
@class LocalSongModel;

@interface MusicControllerView : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *songTimeProgress;
@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (strong, nonatomic) LocalSongModel *song;

- (void)configureMusicControllerView;

@end
