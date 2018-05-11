//
//  YoutubeDownloadManager.h
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadModel;

@interface YoutubeDownloadManager : NSObject<NSURLSessionDownloadDelegate>

+ (instancetype)sharedInstance;
- (void) downloadVideoWithDownloadModel:(DownloadModel *)download;

@end
