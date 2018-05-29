//
//  Protocols.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

@protocol SearchSuggestionsDelegate

@property (strong, nonatomic) NSMutableArray<NSString *> *searchSuggestions;
@property (strong, nonatomic) NSMutableArray<NSString *> *searchHistory;

- (void)makeSearchWithString:(NSString *)string;

@end



@class LocalSongModel;

@protocol SavedMusicTableDelegate

- (LocalSongModel *)previousSong;
- (LocalSongModel *)nextSong;
- (LocalSongModel *)firstSong;
- (void)updateProgressBar:(NSNumber *)value;
- (void)onPlayButtonTap;
- (void)onPauseButtonTap;

@end

@protocol MusicPlayerDelegate

- (void)replaceCurrentSongWithSong:(LocalSongModel *)song;
- (BOOL)avPlayerStatusIsPlaying;

@end



#endif /* Protocols_h */
