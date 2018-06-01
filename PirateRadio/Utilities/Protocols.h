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
    EnumCellMediaPlaybackStatePlay,
    EnumCellMediaPlaybackStatePause
} EnumCellMediaPlaybackState;

@protocol SearchSuggestionsDelegate

@property (strong, nonatomic) NSMutableArray<NSString *> *searchSuggestions;
@property (strong, nonatomic) NSMutableArray<NSString *> *searchHistory;

- (void)makeSearchWithString:(NSString *)string;

@end



@class LocalSongModel;

@protocol SongListDelegate

- (void)updateProgress:(double)progress forSong:(LocalSongModel *)song;
- (void)didPauseSong:(LocalSongModel *)song;
- (void)didStartPlayingSong:(LocalSongModel *)song;
- (void)didRequestNextForSong:(LocalSongModel *)song;
- (void)didRequestPreviousForSong:(LocalSongModel *)song;

@end

@protocol MusicPlayerDelegate

- (void)prepareSong:(LocalSongModel *)song;
- (void)playLoadedSong;
- (void)pauseLoadedSong;
- (BOOL)isPlaying;
- (void)setPlayerPlayPauseButtonState:(EnumCellMediaPlaybackState)state;
- (LocalSongModel *)nowPlaying;

@end



#endif /* Protocols_h */
