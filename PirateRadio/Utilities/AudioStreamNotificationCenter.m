//
//  AudioStreamNotificationCenter.m
//  PirateRadio
//
//  Created by A-Team User on 9.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "AudioStreamNotificationCenter.h"
#import "MusicPlayerViewController.h"
#import "Protocols.h"
#import "Constants.h"

@interface AudioStreamNotificationCenter ()

@property (strong, nonatomic) id<AudioStreamerDelegate> audioStream;

@end

@implementation AudioStreamNotificationCenter

+ (instancetype)defaultCenter {
    static AudioStreamNotificationCenter *defaultCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[self alloc] init];
    });
    return defaultCenter;
}

- (void)addAudioStreamObserver:(id<AudioStreamerDelegate>)observer {
    if (self.audioStream != observer) {
        [NSNotificationCenter.defaultCenter removeObserver:self.audioStream name:NOTIFICATION_REMOTE_EVENT_PLAY_PAUSE_TOGGLE object:nil];
        self.audioStream = observer;
        [NSNotificationCenter.defaultCenter addObserver:observer selector:@selector(playPauseStream) name:NOTIFICATION_REMOTE_EVENT_PLAY_PAUSE_TOGGLE object:nil];
    }
}

@end
