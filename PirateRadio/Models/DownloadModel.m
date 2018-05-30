//
//  DownloadModel.m
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "DownloadModel.h"
#import "VideoModel.h"

@interface DownloadModel ()

@property (strong, nonatomic) VideoModel *video;
@property (strong, nonatomic) NSURL *URL;

@end

@implementation DownloadModel

- (NSURL *)localURLWithTimeStamp {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *fileName = [[self.video.videoTitle stringByAppendingString:[formatter stringFromDate:[NSDate date]]] stringByReplacingOccurrencesOfString:@"/" withString:@" "];
    fileName = [fileName stringByAppendingPathExtension:@"mp3"];

    
    NSURL *fileURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    fileURL = [[fileURL URLByAppendingPathComponent:@"songs"] URLByAppendingPathComponent:fileName];
    
    return fileURL;
}


- (instancetype)initWithVideoModel:(VideoModel *)videoModel andURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.video = videoModel;
        self.URL = url;
    }
    return self;
}

@end
