//
//  YoutubeDownloadManager.m
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "YoutubeDownloadManager.h"

@implementation YoutubeDownloadManager

- (void) downloadDataFromURL:(NSURL *)url {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"youtubeDownload"] delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

+ (instancetype)sharedInstance {
    static YoutubeDownloadManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    NSLog(@"Finished Downloading at %@",[location description]);
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSURL *saveTo = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    saveTo = [saveTo URLByAppendingPathComponent:@"test.mp3"];
    NSError *error;
    [fileManager moveItemAtURL:location toURL:saveTo error:&error];
    
    if (error) {
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"Total Bytes Written = %lld", totalBytesWritten);
}


@end
