//
//  SavedMusicViewController.h
//  PirateRadio
//
//  Created by A-Team User on 28.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SavedMusicTableViewController;
@class MusicPlayerViewController;

@class PlaylistModel;

@interface SongListPlusPlayerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UIView *musicPlayerContainer;

+(instancetype)songListPlusPlayerViewControllerWithPlaylist:(PlaylistModel *)playlist;

@end
