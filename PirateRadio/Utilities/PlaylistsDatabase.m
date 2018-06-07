//
//  PlaylistsDatabase.m
//  PirateRadio
//
//  Created by A-Team User on 7.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "PlaylistsDatabase.h"
#import "Constants.h"
#import "PlaylistModel.h"

@implementation PlaylistsDatabase

+ (void)savePlaylistArray:(NSArray<PlaylistModel *> *)playlists {
    NSData *encodedPlaylists = [NSKeyedArchiver archivedDataWithRootObject:playlists];
    [NSUserDefaults.standardUserDefaults setObject:encodedPlaylists forKey:USER_DEFAULTS_KEY_PLAYLISTS];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (NSArray<PlaylistModel *> *)loadPlaylistsFromUserDefaults {
    NSData *encodedPlaylists = [NSUserDefaults.standardUserDefaults objectForKey:USER_DEFAULTS_KEY_PLAYLISTS];
    NSArray<PlaylistModel *> *playlists = [NSKeyedUnarchiver unarchiveObjectWithData:encodedPlaylists];
    return playlists;
}

+ (void)updateDatabaseForChangedPlaylist:(PlaylistModel *)playlist {
    NSMutableArray<PlaylistModel *> *playlists = [[PlaylistsDatabase loadPlaylistsFromUserDefaults] mutableCopy];
    NSUInteger index = NSIntegerMax;
    for (PlaylistModel *iteratingPlaylist in playlists) {
        if ([iteratingPlaylist.name isEqualToString:playlist.name]) {
            index = [playlists indexOfObject:iteratingPlaylist];
            break;
        }
    }
    [playlists replaceObjectAtIndex:index withObject:playlist];
    [PlaylistsDatabase savePlaylistArray:playlists];
}

@end
