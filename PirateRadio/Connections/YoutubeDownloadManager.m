//
//  YoutubeDownloadManager.m
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "YoutubeDownloadManager.h"
#import "DownloadModel.h"
#import "ArtworkDownload.h"
#import "LocalSongModel.h"
#import "Constants.h"
#import "DataBase.h"
#import "AVKit/AVKit.h"
#import "DropBox.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface YoutubeDownloadManager ()

@property (strong, nonatomic) NSMutableDictionary<NSNumber *, DownloadModel *> *downloads;
@property (strong, nonatomic) NSURLSession *youtubeSession;

@end

@implementation YoutubeDownloadManager

+ (instancetype)sharedInstance {
    static YoutubeDownloadManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.downloads = [[NSMutableDictionary alloc] init];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"youtubeDownload"];
        configuration.waitsForConnectivity = YES;
        configuration.shouldUseExtendedBackgroundIdleMode = YES;
        self.youtubeSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)downloadVideoWithDownloadModel:(DownloadModel *)download {
    
    NSURLSessionDownloadTask *downloadTask = [self.youtubeSession downloadTaskWithURL:download.URL];
    [self.downloads setObject:download forKey:[NSNumber numberWithUnsignedInteger:downloadTask.taskIdentifier]];
    [downloadTask resume];
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    DownloadModel *download = [self.downloads objectForKey:[NSNumber numberWithUnsignedInteger:downloadTask.taskIdentifier]];
    
    NSURL *localURL = download.localURLWithTimeStamp;
    
    NSError *error;
    [fileManager moveItemAtURL:location toURL:localURL.absoluteURL error:&error];
    
    if (error) {
        NSLog(@"error = %@", error.localizedDescription);
    }
    else {
        LocalSongModel *song = [[LocalSongModel alloc] initWithLocalSongURL:localURL];
        song.videoURL = download.videoURL;
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:song.localSongURL options:nil];
        NSNumber *duration = [NSNumber numberWithDouble:CMTimeGetSeconds(audioAsset.duration)];
        song.duration = duration;
        [ArtworkDownload.sharedInstance downloadArtworkForLocalSongModel:song];
        [self.downloads removeObjectForKey:[NSNumber numberWithUnsignedInteger:downloadTask.taskIdentifier]];
        
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[song, download] forKeys:@[@"song", @"download"]];
        
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_DOWNLOAD_FINISHED object:nil userInfo:userInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            DataBase *db = [[DataBase alloc] init];
            [db addNewSong:song withURL:download.videoURL];
        });
        
        [DropBox uploadLocalSong:song];
    }
    [self.youtubeSession resetWithCompletionHandler:^{
        
    }];
}


@end
