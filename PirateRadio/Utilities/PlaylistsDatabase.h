//
//  PlaylistsDatabase.h
//  PirateRadio
//
//  Created by A-Team User on 7.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlaylistModel;
@class LocalSongModel;

@interface PlaylistsDatabase : NSObject

+ (void)savePlaylistArray:(NSArray<PlaylistModel *> *)playlists;
+ (NSArray<PlaylistModel *> *)loadPlaylistsFromUserDefaults;
+ (void)updateDatabaseForChangedPlaylist:(PlaylistModel *)playlist;
+ (void)removeSong:(LocalSongModel *)song;

@end
