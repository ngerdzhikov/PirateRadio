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
    
    NSRegularExpression *regexForOfficial = [NSRegularExpression regularExpressionWithPattern:@"(\\[|\\().*Official.*(\\]|\\))|((\\[|\\().*Audio.*(\\]|\\)))|((\\[|\\().*Music.*(\\]|\\)))|((\\[|\\().*Video.*(\\]|\\)))" options:NSRegularExpressionCaseInsensitive error:&err];
    if (err) {
        NSLog(@"Error = %@", err);
    }
    else {
        modifiedTitle = [regexForOfficial stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, title.length) withTemplate:@""];
    }
    return [modifiedTitle substringToIndex:modifiedTitle.length - 8];
}

-(void)extractArtistNameAndSongTitleFromSongURL:(NSURL *)songURL {
    NSString *song = [[[songURL lastPathComponent] stringByDeletingPathExtension] stringByRemovingPercentEncoding];
    NSString *artistNamePlusSongName = [self extractedSongTitleFromString:song];
    NSArray<NSString *> *components = [artistNamePlusSongName componentsSeparatedByString:@" - "];
    if (components.count == 2) {
        self.artistName = components[0];
        self.songTitle = components[1];
    }
    else if (components.count > 2) {
        self.artistName = components[0];
        NSArray<NSString *> *newComponents = [components[1] componentsSeparatedByString:@"  "];
        self.songTitle = newComponents[0];
    }
    else {
        self.artistName = @"Unknown artist";
        self.songTitle = artistNamePlusSongName;
    }
}

-(NSURL *)localArtworkURL {
    
    NSString *urlString = self.localSongURL.absoluteString;
    NSString *artworkURLString = [[urlString stringByReplacingOccurrencesOfString:@"/songs/" withString:@"/artwork/"] stringByReplacingOccurrencesOfString:@".mp3" withString:@".jpg"];
    NSURL *artworkURL = [NSURL URLWithString:artworkURLString];
    
    return artworkURL;
}

-(NSArray<NSString *> *)keywordsFromTitle {
    return [self.songTitle componentsSeparatedByString:@" "];
}

-(NSArray<NSString *> *)keywordsFromAuthorAndTitle {
    if ([self.artistName isEqualToString:@"Unknown artist"]) {
        return [self keywordsFromTitle];
    }
    NSMutableArray<NSString *> *keywords = [[NSMutableArray alloc] init];
    [keywords addObjectsFromArray:[self.artistName componentsSeparatedByString:@" "]];
    NSArray *titleWithoutFt = [self.songTitle componentsSeparatedByString:@" ft"];
    NSArray *titleWithoutFeat = [titleWithoutFt[0] componentsSeparatedByString:@" feat"];
    [keywords addObjectsFromArray:[titleWithoutFeat[0] componentsSeparatedByString:@" "]];
    return keywords;
}

- (NSString *)properMusicTitle {
    NSString *songTitle = [[self.artistName stringByAppendingString:@" - "] stringByAppendingString:self.songTitle];
    if ([self.artistName isEqualToString:@"Unknown artist"]) {
        songTitle = self.songTitle;
    }
    
    return songTitle;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[LocalSongModel class]]) {
        LocalSongModel *songToCompare = (LocalSongModel *)object;
        if ([songToCompare.localSongURL.lastPathComponent isEqual:self.localSongURL.lastPathComponent]) {
            return YES;
        }
    }
    return NO;
    
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSString *fileName = self.localSongURL.lastPathComponent;
    [encoder encodeObject:fileName forKey:@"localSongURL"];
    [encoder encodeObject:self.artistName forKey:@"artistName"];
    [encoder encodeObject:self.songTitle forKey:@"songTitle"];
    [encoder encodeObject:self.videoURL forKey:@"videoURL"];
    [encoder encodeObject:self.duration forKey:@"duration"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if((self = [super init])) {
        NSString *fileName = [decoder decodeObjectForKey:@"localSongURL"];
        NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        sourcePath = [sourcePath URLByAppendingPathComponent:@"songs"];
        self.localSongURL = [sourcePath URLByAppendingPathComponent:fileName isDirectory:NO];
        self.artistName = [decoder decodeObjectForKey:@"artistName"];
        self.songTitle = [decoder decodeObjectForKey:@"songTitle"];
        self.videoURL = [decoder decodeObjectForKey:@"videoURL"];
        self.duration = [decoder decodeObjectForKey:@"duration"];
    }
    return self;
}

@end
