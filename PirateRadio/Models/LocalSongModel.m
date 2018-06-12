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
    //@"(\\[|\\()Official(\\s*\\w*)*(\\]|\\))
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\[|\\()(\\s*)Official(\\s*\\w*)*(\\]|\\))" options:NSRegularExpressionCaseInsensitive error:&err];
    if (err) {
        NSLog(@"Error = %@", err);
    }
    else {
        modifiedTitle = [regex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, [title length]) withTemplate:@""];
    }
    return [modifiedTitle substringToIndex:modifiedTitle.length - 8];
}

-(void)extractArtistNameAndSongTitleFromSongURL:(NSURL *)songURL {
    NSString *song = [[[songURL lastPathComponent] stringByDeletingPathExtension] stringByRemovingPercentEncoding];
    NSArray<NSString *> *components = [song componentsSeparatedByString:@" - "];
    if (components.count == 2) {
        self.artistName = components[0];
        self.songTitle = [self extractedSongTitleFromString:components[1]];
    }
    else if (components.count > 2) {
        self.artistName = components[0];
        NSArray<NSString *> *newComponents = [components[1] componentsSeparatedByString:@"  "];
        self.songTitle = newComponents[0];
    }
    else {
        self.artistName = @"Unknown artist";
        self.songTitle = [self extractedSongTitleFromString:song];
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
    NSMutableArray<NSString *> *keywords = [[NSMutableArray alloc] init];
    [keywords addObjectsFromArray:[self.artistName componentsSeparatedByString:@" "]];
    [keywords addObjectsFromArray:[self.songTitle componentsSeparatedByString:@" "]];
    return keywords;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[LocalSongModel class]]) {
        LocalSongModel *songToCompare = (LocalSongModel *)object;
        if ([songToCompare.songTitle isEqual:self.songTitle
             ]) {
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
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if((self = [super init])) {
        NSString *fileName = [decoder decodeObjectForKey:@"localSongURL"];
        NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        sourcePath = [sourcePath URLByAppendingPathComponent:@"songs"];
        self.localSongURL = [sourcePath URLByAppendingPathComponent:fileName isDirectory:NO];
        self.artistName = [decoder decodeObjectForKey:@"artistName"];
        self.songTitle = [decoder decodeObjectForKey:@"songTitle"];
    }
    return self;
}

@end
