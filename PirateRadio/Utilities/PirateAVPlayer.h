//
//  PirateAVPlayer.h
//  PirateRadio
//
//  Created by A-Team User on 7.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@class LocalSongModel;

@interface PirateAVPlayer : AVPlayer

@property (strong, nonatomic) LocalSongModel *currentSong;

+ (instancetype)sharedPlayer;

@end
