//
//  YoutubeDownloadManager.m
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "YoutubeDownloadManager.h"
#import "VideoModel.h"
#import "DownloadModel.h"

@interface YoutubeDownloadManager ()

@property (strong, nonatomic) NSMutableDictionary<NSURLSessionDownloadTask *, DownloadModel *> *downloads;
@property (strong, nonatomic) NSURLSession *session;

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloads = [[NSMutableDictionary alloc] init];
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"youtubeDownload"] delegate:self delegateQueue:nil];
    }
    return self;
}

- (void) downloadVideoWithDownloadModel:(DownloadModel *)download {
    
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:download.URL];
    [self.downloads setObject:download forKey:downloadTask];
    
    [downloadTask resume];
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    DownloadModel *download = self.downloads[downloadTask];
    
    NSError *error;
    [fileManager moveItemAtURL:location toURL:download.localURLWithTimeStamp error:&error];
    
    if (error) {
        NSLog(@"error = %@", error.localizedDescription);
    }
    else {
        [self.downloads removeObjectForKey:downloadTask];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"Total Bytes Written = %lld", totalBytesWritten);
}


@end
