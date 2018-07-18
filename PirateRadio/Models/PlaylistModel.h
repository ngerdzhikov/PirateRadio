//
//  PlaylistModel.h
//  PirateRadio
//
//  Created by A-Team User on 4.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"

@class LocalSongModel;

RLM_ARRAY_TYPE(LocalSongModel)

@interface PlaylistModel : RLMObject

@property (strong, nonatomic) RLMArray<LocalSongModel *><LocalSongModel> *realmSongs;
@property (strong, nonatomic) NSString *name;


- (instancetype)initWithName:(NSString *)name;
- (void)addSong:(LocalSongModel *)song;
- (NSMutableArray<LocalSongModel *> *)songs;

@end
