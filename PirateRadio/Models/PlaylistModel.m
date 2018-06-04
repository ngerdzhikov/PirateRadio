//
//  PlaylistModel.m
//  PirateRadio
//
//  Created by A-Team User on 4.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "PlaylistModel.h"

@implementation PlaylistModel

-initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
        self.songs = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addSong:(LocalSongModel *)song {
    [self.songs addObject:song];
}

@end
