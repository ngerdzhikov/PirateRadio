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
#import "Constants.h"
#import "DataBase.h"
#import "AVKit/AVKit.h"
#import "UIView+Toast.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@implementation DropBox

+ (void)uploadLocalSong:(LocalSongModel *)song {
    // For overriding on upload
    DBFILESWriteMode *mode = [[DBFILESWriteMode alloc] initWithOverwrite];
    
    NSString *uploadPath = [self.class dropboxPathForSongNameWithMp3Extension:song.properMusicTitle];
    
    NSData *fileData = [NSData dataWithContentsOfURL:song.localSongURL];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    if (!client) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            [window.rootViewController.view makeToast:@"Login in dropbox to upload song"];
        });
    }
    else {
        [[client.filesRoutes uploadData:uploadPath
                                    mode:mode
                              autorename:@(YES)
                          clientModified:nil
                                    mute:@(NO)
                          propertyGroups:nil
                               inputData:fileData]
          setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
              if (result) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      UIWindow *window=[UIApplication sharedApplication].keyWindow;
                      [window.rootViewController.view makeToast:@"Song uploaded successfully"];
                  });
              } else {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      UIWindow *window=[UIApplication sharedApplication].keyWindow;
                      [window.rootViewController.view makeToast:@"Error uploading song"];
                  });
              }
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
    
    [[client.filesRoutes uploadData:uploadPath
                                mode:mode
                          autorename:@(YES)
                      clientModified:nil
                                mute:@(NO)
                      propertyGroups:nil
                           inputData:fileData]
      setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESUploadError * _Nullable routeError, DBRequestError * _Nullable networkError) {
          if (result) {
              NSLog(@"%@\n", result);
          }
      }];
}

+ (void)downloadSongWithName:(NSString *)songName {
    NSURL *outputUrl = [[self class] localURLWithTimeStampForSongName:songName];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSString *downloadPath = [self.class dropboxPathForSongName:songName];
    
    [[client.filesRoutes downloadUrl:downloadPath overwrite:YES destination:outputUrl]
      setResponseBlock:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *networkError,
                         NSURL *destination) {
          
          
          
          
          if (result) {
              LocalSongModel *song = [[LocalSongModel alloc] initWithLocalSongURL:outputUrl];
              AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:song.localSongURL options:nil];
              NSNumber *duration = [NSNumber numberWithDouble:CMTimeGetSeconds(audioAsset.duration)];
              song.duration = duration;
              
              [RLMRealm.defaultRealm beginWriteTransaction];
              [RLMRealm.defaultRealm addObject:song];
              [RLMRealm.defaultRealm commitWriteTransaction];
              
              [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_DOWNLOAD_FINISHED object:nil userInfo:[NSDictionary dictionaryWithObject:song.songUniqueName forKey:@"song"]];

              dispatch_async(dispatch_get_main_queue(), ^{
                  UIWindow *window=[UIApplication sharedApplication].keyWindow;
                  [window.rootViewController.view makeToast:@"Download successful"]; 
              });
              
              [[self class] downloadArtworkForSongName:songName andLocalSongModel:song];
          } else {
              NSLog(@"%@\n%@\n", routeError, networkError);
          }
      }];
}

+ (void)downloadArtworkForSongName:(NSString *)songName andLocalSongModel:(LocalSongModel *)localSong {
    NSURL *outputUrl = localSong.localArtworkURL;
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    NSString *downloadPath = [[[@"/PirateRadio/artworks/" stringByAppendingString:songName] substringToIndex:songName.length + 18] stringByAppendingString:@".jpg"];
    
    [[client.filesRoutes downloadUrl:downloadPath overwrite:YES destination:outputUrl] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSURL * _Nonnull destination) {
    }];
}

+ (NSURL *)localURLWithTimeStampForSongName:(NSString *)songName {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *fileName = [[[[songName substringToIndex:songName.length - 4] stringByAppendingString:[formatter stringFromDate:[NSDate date]]] stringByReplacingOccurrencesOfString:@"/" withString:@" "] stringByReplacingOccurrencesOfString:@"%" withString:@" "];
    fileName = [fileName stringByAppendingPathExtension:@"mp3"];
    
    
    NSURL *fileURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    fileURL = [[fileURL URLByAppendingPathComponent:@"songs"] URLByAppendingPathComponent:fileName];
    
    return fileURL;
}

+ (BOOL)doesSongExists:(LocalSongModel *)song {
    __block BOOL exists = NO;
    
    NSString *filePath = [self.class dropboxPathForSongNameWithMp3Extension:song.properMusicTitle];
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[[client filesRoutes] getMetadata:filePath] setResponseBlock:^(DBFILESMetadata * _Nullable result, DBFILESGetMetadataError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            exists = YES;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) { [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]; }
    return exists;
}

+ (void)shareableLinkForSongName:(NSString *)songName {
    __block NSURL *shareableLink;
    
    DBUserClient *client = [DBClientsManager authorizedClient];
    __block NSArray *url;
    [[client.sharingRoutes createSharedLinkWithSettings:[self.class dropboxPathForSongName:songName]] setResponseBlock:^(DBSHARINGSharedLinkMetadata * _Nullable result, DBSHARINGCreateSharedLinkWithSettingsError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        url = [result valueForKey:@"url"];
        if (!url) {
            [[client.sharingRoutes listSharedLinks:[self.class dropboxPathForSongName:songName] cursor:nil directOnly:nil] setResponseBlock:^(DBSHARINGSharedLinkMetadata * _Nullable result, DBSHARINGSharedLinkError * _Nullable routeError, DBRequestError * _Nullable networkError) {
                url = [[result valueForKey:@"links"] valueForKey:@"url"];
                UIPasteboard.generalPasteboard.string = url.firstObject;
                shareableLink = [NSURL URLWithString:url.firstObject];
                [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_COPY_DROPBOX_LINK_FINISHED object:nil userInfo:@{@"songName" : songName, @"url" : shareableLink}];
            }];
        }
        else {
            NSString *firstResultURL = (NSString *)url;
            UIPasteboard.generalPasteboard.string = firstResultURL;
            shareableLink = [NSURL URLWithString:firstResultURL];
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_COPY_DROPBOX_LINK_FINISHED object:nil userInfo:@{@"songName" : songName, @"url" : shareableLink}];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            [window.rootViewController.view makeToast:@"Link copied"];
        });
        
    }];
}

+ (NSString *)dropboxPathForSongNameWithMp3Extension:(NSString *)songName {
    return [[@"/PirateRadio/songs/" stringByAppendingString:songName] stringByAppendingString:@".mp3"];
}

+ (NSString *)dropboxPathForSongName:(NSString *)songName {
    return [@"/PirateRadio/songs/" stringByAppendingString:songName];
}

@end
