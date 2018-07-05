//
//  ArtworkDownload.m
//  PirateRadio
//
//  Created by A-Team User on 18.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ArtworkDownload.h"
#import "ArtworkRequest.h"
#import "LocalSongModel.h"
#import "DropBox.h"

@interface ArtworkDownload ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableDictionary<NSURLSessionDownloadTask *, LocalSongModel *> *downloadDict;

@end


@implementation ArtworkDownload

+ (instancetype)sharedInstance {
    static ArtworkDownload *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        self.downloadDict = [[NSMutableDictionary alloc] init];
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"itunesDownload"] delegate:self delegateQueue:nil];
    }
    return self;
}


- (void)downloadArtworkForLocalSongModel:(LocalSongModel *)localSong {
    [ArtworkRequest makeLastFMSearchRequestWithKeywords:localSong.keywordsFromAuthorAndTitle andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *serializationError;
        NSDictionary<NSString *, id> *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
        if (serializationError) {
            NSLog(@"serializationError = %@", serializationError);
        }
        else {
            if ([[responseDict objectForKey:@"results"] count] > 0) {
                NSArray *track = [[[responseDict objectForKey:@"results"] objectForKey:@"albummatches"] objectForKey:@"album"];
                if (track.count > 0) {
                    NSDictionary *thumbDictionary = [[track[0] objectForKey:@"image"] objectAtIndex:3];
                    
                    NSURL *artworkURL = [NSURL URLWithString:[thumbDictionary objectForKey:@"#text"]];
                    if (artworkURL != nil) {
                        if ([artworkURL.absoluteString isEqualToString:@""]) {
                            [self downloadArtworkByTitleForLocalSongModel:localSong];
                        }
                        else {
                            NSLog(@"Found artwork");
                            NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:artworkURL];
                            [self.downloadDict setObject:localSong forKey:downloadTask];
                            [downloadTask resume];
                        }
                    }
                    
                }
            }
        }
    }];
}

- (void)downloadArtworkByTitleForLocalSongModel:(LocalSongModel *)localSong {
    [ArtworkRequest makeLastFMSearchRequestWithKeywords:localSong.keywordsFromTitle andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *serializationError;
        NSDictionary<NSString *, id> *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
        if (serializationError) {
            NSLog(@"serializationError = %@", serializationError);
        }
        else {
            if ([[responseDict objectForKey:@"results"] count] > 0) {
                NSArray *track = [[[responseDict objectForKey:@"results"] objectForKey:@"albummatches"] objectForKey:@"album"];
                if (track.count > 0) {
                    NSDictionary *thumbDictionary = [[track[0] objectForKey:@"image"] objectAtIndex:3];
                    
                    NSURL *artworkURL = [NSURL URLWithString:[thumbDictionary objectForKey:@"#text"]];
                    if (artworkURL != nil && ![artworkURL.absoluteString isEqualToString:@""]) {
                            NSLog(@"Found artwork");
                            NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:artworkURL];
                            [self.downloadDict setObject:localSong forKey:downloadTask];
                            [downloadTask resume];
                    }
                    
                }
            }
        }
    }];
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSError *err;
    LocalSongModel *song = self.downloadDict[downloadTask];
    NSURL *urlToSave = song.localArtworkURL;
    [NSFileManager.defaultManager moveItemAtURL:location toURL:urlToSave error:&err];
    if (err) {
        NSLog(@"Error moving item = %@", err);
    }
    else {
        [DropBox uploadArtworkForLocalSong:self.downloadDict[downloadTask]];
    }
    
}

@end
