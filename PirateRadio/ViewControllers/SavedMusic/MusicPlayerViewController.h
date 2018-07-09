//
//  MusicControllerView.h
//  PirateRadio
//
//  Created by A-Team User on 15.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class SavedMusicTableViewController;
@class LocalSongModel;
@class CBAutoScrollLabel;

@interface MusicPlayerViewController : UIViewController<MusicPlayerDelegate, AudioStreamerDelegate>

@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *songName;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *songTimeProgress;
@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) id<SongListDelegate> songListDelegate;

- (void)configureMusicControllerView;

@end
