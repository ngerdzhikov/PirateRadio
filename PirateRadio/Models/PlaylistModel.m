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
        self.songs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addSong:(LocalSongModel *)song {
    [self.songs addObject:song];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.songs forKey:@"songs"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.songs = [decoder decodeObjectForKey:@"songs"];
    }
    return self;
}

@end
