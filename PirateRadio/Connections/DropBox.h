//
//  DropBox.h
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalSongModel;

@interface DropBox : NSObject

+ (void)uploadLocalSong:(LocalSongModel *)song;
+ (void)downloadSongWithName:(NSString *)songName;
+ (BOOL)doesSongExists:(LocalSongModel *)song;

@end
