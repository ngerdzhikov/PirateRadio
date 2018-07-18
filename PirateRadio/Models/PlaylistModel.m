//
//  PlaylistModel.m
//  PirateRadio
//
//  Created by A-Team User on 4.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "PlaylistModel.h"

@implementation PlaylistModel

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

- (void)addSong:(LocalSongModel *)song {
    [self.realmSongs addObject:song];
}

- (NSMutableArray<LocalSongModel *> *)songs {
    NSMutableArray<LocalSongModel *> *songs = [[NSMutableArray alloc] init];
    for (LocalSongModel *song in self.realmSongs) {
        [songs addObject:song];
    }
    return songs;
}

@end
