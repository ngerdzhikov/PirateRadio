//
//  DropBox.m
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "DropBox.h"
#import "LocalSongModel.h"
#import "Toast.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@implementation DropBox

+ (void)uploadLocalSong:(LocalSongModel *)song {
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    NSString *fileName = [[[song.artistName stringByAppendingString:@" - "] stringByAppendingString:song.songTitle] stringByAppendingString:@".mp3"];
    
    NSString *uploadPath = [@"/PirateRadio/songs/" stringByAppendingString:fileName];
    
    NSData *fileData = [NSData dataWithContentsOfURL:song.localSongURL];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    if (!client) {
        [Toast displayStandardToastWithMessage:@"Login in dropbox to upload song."];
    }
    else {
        [[[client.filesRoutes uploadData:uploadPath
                                    mode:mode
                              autorename:@(YES)
                          clientModified:nil
                                    mute:@(NO)
                          propertyGroups:nil
                               inputData:fileData]
          setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
              if (result) {
                  [Toast displayStandardToastWithMessage:@"Song uploaded successfully"];
              } else {
              }
          }]
         setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
             NSLog(@"\n%lld\n%lld\n%lld\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
         }];
    }
    
}

+ (void)uploadArtworkForLocalSong:(LocalSongModel *)song {
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    NSString *fileName = [[[song.artistName stringByAppendingString:@" - "] stringByAppendingString:song.songTitle] stringByAppendingString:@".jpg"];
    
    NSString *uploadPath = [@"/PirateRadio/artworks/" stringByAppendingString:fileName];
    
    NSData *fileData = [NSData dataWithContentsOfURL:song.localArtworkURL];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[[client.filesRoutes uploadData:uploadPath
                                mode:mode
                          autorename:@(YES)
                      clientModified:nil
                                mute:@(NO)
                      propertyGroups:nil
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
          if (result) {
              NSLog(@"%@\n", result);
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }]
     setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
         NSLog(@"\n%lld\n%lld\n%lld\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
     }];
}

@end
