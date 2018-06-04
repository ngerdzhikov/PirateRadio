//
//  PlaylistModel.h
//  PirateRadio
//
//  Created by A-Team User on 4.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalSongModel;

@interface PlaylistModel : NSObject

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *songs;
@property (strong, nonatomic) NSString *name;


-(instancetype)initWithName:(NSString *)name;
-(void)addSong:(LocalSongModel *)song;

@end
