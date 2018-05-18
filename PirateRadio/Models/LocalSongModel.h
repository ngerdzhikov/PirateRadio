//
//  LocalSongModel.h
//  PirateRadio
//
//  Created by A-Team User on 18.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalSongModel : NSObject

@property (strong, nonatomic, readonly) NSURL *localSongURL;
@property (strong, nonatomic, readonly) NSString *artistName;
@property (strong, nonatomic, readonly) NSString *songTitle;


-(instancetype) initWithLocalSongURL:(NSURL *)songURL;
-(NSURL *)localArtworkURL;
-(NSArray<NSString *> *)keywords;

@end
