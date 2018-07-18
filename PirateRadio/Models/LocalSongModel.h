//
//  LocalSongModel.h
//  PirateRadio
//
//  Created by A-Team User on 18.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"

@interface LocalSongModel : RLMObject

@property (strong, nonatomic, readonly) NSString *songUniqueName;
@property (strong, nonatomic, readonly) NSString *artistName;
@property (strong, nonatomic, readonly) NSString *songTitle;
@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSNumber<RLMDouble> *duration;
@property (strong, nonatomic) NSURL *localSongURL;

- (instancetype)initWithLocalSongURL:(NSURL *)songURL;
- (NSURL *)videoURL;
- (NSURL *)localArtworkURL;
- (NSString *)properMusicTitle;
- (NSArray<NSString *> *)keywordsFromTitle;
- (NSArray<NSString *> *)keywordsFromAuthorAndTitle;

@end
