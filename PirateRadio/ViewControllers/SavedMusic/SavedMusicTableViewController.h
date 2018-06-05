//
//  SavedMusicTableViewController.h
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Protocols.h"

@class MusicPlayerViewController;
@class PlaylistModel;

@interface SavedMusicTableViewController : UITableViewController<SongListDelegate>

@property (weak, nonatomic) id<MusicPlayerDelegate> musicPlayerDelegate;
@property (strong, nonatomic) PlaylistModel *playlist;

@end
