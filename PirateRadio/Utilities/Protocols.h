//
//  Protocols.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h


typedef enum {
    EnumCellMediaPlaybackStatePlaying,
    EnumCellMediaPlaybackStatePaused
} EnumCellMediaPlaybackState;


@class UserModel;
@class LocalSongModel;

@protocol SearchTableViewDelegate

- (void)makeSearchWithString:(NSString *)string;

@end

@protocol SearchSuggestionsDelegate

- (void)didChangeText:(NSString *)searchText;
- (void)didMakeSearchWithText:(NSString *)searchText;

@end

@protocol SongListDelegate

- (void)didPauseSong:(LocalSongModel *)song;
- (void)didStartPlayingSong:(LocalSongModel *)song;
- (void)didRequestNextForSong:(LocalSongModel *)song;
- (void)didRequestPreviousForSong:(LocalSongModel *)song;
- (BOOL)isFiltering;

@end

@protocol MusicPlayerDelegate

- (void)prepareSong:(LocalSongModel *)song;
- (void)playLoadedSong;
- (void)pauseLoadedSong;
- (BOOL)isPlaying;
- (void)setPlayerPlayPauseButtonState:(BOOL)play;
- (LocalSongModel *)nowPlaying;

@end

@protocol AudioStreamerDelegate

- (void)playPauseStream;

@end

@protocol ProfileUserPreferencesDelegate

- (void)changeProfilePicture;
- (void)ecoMode:(BOOL)eco;
- (void)changeName;
- (void)changePassword;

@end

@protocol ProfileLoginPresenterDelegate

- (void)loggedSuccessfulyWithUserModel:(UserModel *)userModel;

@end



#endif /* Protocols_h */
