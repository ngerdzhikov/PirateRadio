//
//  ArtworkDownload.h
//  PirateRadio
//
//  Created by A-Team User on 18.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalSongModel;

@interface ArtworkDownload : NSObject<NSURLSessionDownloadDelegate>

+ (instancetype)sharedInstance;
- (void)downloadArtworkForLocalSongModel:(LocalSongModel *)localSong;

@end
