//
//  YoutubeDownloadManager.h
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubeDownloadManager : NSObject<NSURLSessionDownloadDelegate>

- (void) downloadDataFromURL:(NSURL *)url;
+ (instancetype)sharedInstance;

@end
