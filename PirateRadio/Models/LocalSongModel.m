//
//  LocalSongModel.m
//  PirateRadio
//
//  Created by A-Team User on 18.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "LocalSongModel.h"

@interface LocalSongModel ()

@property (strong, nonatomic) NSURL *localSongURL;
@property (strong, nonatomic) NSString *artistName;
@property (strong, nonatomic) NSString *songTitle;

@end


@implementation LocalSongModel

-(instancetype) initWithLocalSongURL:(NSURL *)songURL {
    self = [super init];
    if (self) {
        self.localSongURL = songURL;
        [self extractArtistNameAndSongTitleFromSongURL:songURL];
    }
    return self;
}


-(NSString *)extractedSongTitleFromString:(NSString *)title {
    NSString *modifiedTitle = title;
    modifiedTitle = [title stringByTrimmingCharactersInSet:NSCharacterSet.symbolCharacterSet];
    NSError *err;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\[|\\()Official(\\s*\\w*)*(\\]|\\))" options:NSRegularExpressionCaseInsensitive error:&err];
    if (err) {
        NSLog(@"Error = %@", err);
    }
    else {
        modifiedTitle = [regex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, [title length]) withTemplate:@""];
    }
    return modifiedTitle;
}

-(void)extractArtistNameAndSongTitleFromSongURL:(NSURL *)songURL {
    NSString *song = [[songURL lastPathComponent] stringByDeletingPathExtension];
    NSArray<NSString *> *components = [song componentsSeparatedByString:@" - "];
    if (components.count > 1) {
        self.artistName = components[0];
        self.songTitle = [self extractedSongTitleFromString:[components[1] substringToIndex:components[1].length - 8]];
    }
}

-(NSURL *)localArtworkURL {
    
    NSString *urlString = self.localSongURL.absoluteString;
    NSString *artworkURLString = [[urlString stringByReplacingOccurrencesOfString:@"/songs/" withString:@"/artwork/"] stringByReplacingOccurrencesOfString:@".mp3" withString:@".jpg"];
    NSURL *artworkURL = [NSURL URLWithString:artworkURLString];
    
    return artworkURL;
}

-(NSArray<NSString *> *)keywords {
    return [self.songTitle componentsSeparatedByString:@" "];
}

@end
