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
@class UserModel;

@interface DataBase : NSObject

/* users */
- (UserModel *)newUserWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)changeUsername:(NSString *)newUsername forUserModel:(UserModel *)userModel;
- (BOOL)doesUserWithUsernameExists:(NSString *)username;
- (UserModel *)userModelForUsername:(NSString *)username;
- (UserModel *)userModelForUserID:(NSURL *)userID;
- (void)updateUserProfileImageURL:(NSURL *)newURL forUserModel:(UserModel *)user;
/* videos */
- (void)addFavouriteVideo:(VideoModel *)video forUserID:(NSURL *)userID;
- (void)deleteFavouriteVideo:(VideoModel *)video ForUserModel:(UserModel *)userModel;
- (NSArray *)favouriteVideosForUserModel:(UserModel *)userModel;
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
