//
//  SongListFromPlaylistTableViewController.h
//  PirateRadio
//
//  Created by A-Team User on 6.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicTableViewController.h"

@class PlaylistModel;

@interface SongListFromPlaylistTableViewController : SavedMusicTableViewController

@property (strong, nonatomic) PlaylistModel *playlist;

- (void)addSongInPlaylist;
- (void)editSongs:(id)sender;

@end
