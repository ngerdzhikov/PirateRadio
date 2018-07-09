//
//  AudioStreamNotificationCenter.h
//  PirateRadio
//
//  Created by A-Team User on 9.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface AudioStreamNotificationCenter : NSNotificationCenter

+ (instancetype)defaultCenter;
- (void)addAudioStreamObserver:(id<AudioStreamerDelegate>)observer;

@end
