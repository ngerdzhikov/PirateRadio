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

- (NSArray *)users;
- (void)addFavouriteVideo:(VideoModel *)video ForUsername:(NSString *)username;
- (NSArray *)favouriteVideosForUsername:(NSString *)username;
- (void)addUser:(NSString *)username forPassword:(NSString *)password;
- (void)addNewSong:(LocalSongModel *)song withURL:(NSURL *)url;
- (NSArray *)allSongs;
- (NSURL *)videoURLForLocalSongModel:(LocalSongModel *)localSong;
- (void)deleteDBSongforLocalSong:(LocalSongModel *)localSong;
- (void)addArrayOfSongs:(NSArray<LocalSongModel *> *)songs forPlaylist:(PlaylistModel *)playlist;
- (void)removeArrayOfSongs:(NSArray<LocalSongModel *> *)songs fromPlaylist:(PlaylistModel *)playlist;
- (void)addNewPlaylist:(PlaylistModel *)playlist;
- (void)renamePlaylistWithNewName:(NSString *)newName forOldPlaylistName:(NSString *)oldName;
- (NSArray *)allPlaylists;

@end
