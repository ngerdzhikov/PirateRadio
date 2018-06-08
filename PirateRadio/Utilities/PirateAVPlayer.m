//
//  PirateAVPlayer.m
//  PirateRadio
//
//  Created by A-Team User on 7.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "PirateAVPlayer.h"

@implementation PirateAVPlayer

+ (instancetype)sharedPlayer {
    static PirateAVPlayer *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[self alloc] init];
    });
    return sharedPlayer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
