//
//  DataBase.h
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoModel;
@class LocalSongModel;
@class PlaylistModel;

@interface DataBase : NSObject

/* users */
- (NSArray *)users;
- (void)addUser:(NSString *)username forPassword:(NSString *)password;
- (BOOL)doesUserExists:(NSString *)username;
/* videos */
- (void)addFavouriteVideo:(VideoModel *)video ForUsername:(NSString *)username;
- (void)deleteFavouriteVideo:(VideoModel *)video ForUsername:(NSString *)username;
- (NSArray *)favouriteVideosForUsername:(NSString *)username;
/* songs */
- (void)addNewSong:(LocalSongModel *)song withURL:(NSURL *)url;
- (NSArray *)allSongs;
- (NSURL *)videoURLForLocalSongModel:(LocalSongModel *)localSong;
- (void)deleteDBSongforLocalSong:(LocalSongModel *)localSong;
/* playlists */
- (void)updateArrayOfSongsForPlaylist:(PlaylistModel *)playlist;
- (BOOL)addNewPlaylist:(PlaylistModel *)playlist;
- (BOOL)deletePlaylist:(PlaylistModel *)playlist;
- (void)renamePlaylistWithNewName:(NSString *)newName forOldPlaylistName:(NSString *)oldName;
- (NSArray *)allPlaylists;

@end
