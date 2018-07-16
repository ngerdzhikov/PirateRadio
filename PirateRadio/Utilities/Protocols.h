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

@protocol SearchSuggestionsDelegate

@property (strong, nonatomic) NSMutableArray<NSString *> *searchSuggestions;
@property (strong, nonatomic) NSMutableArray<NSString *> *searchHistory;

- (void)makeSearchWithString:(NSString *)string;

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

- (void)changeName;
- (void)imageGalleryPicker;

@end

@protocol ProfileLoginPresenterDelegate

- (void)loggedSuccessfulyWithUserModel:(UserModel *)userModel;

@end



#endif /* Protocols_h */
