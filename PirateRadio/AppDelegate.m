//
//  AppDelegate.m
//  PirateRadio
//
//  Created by A-Team User on 9.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "AppDelegate.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "Constants.h"
#import "LocalSongModel.h"
#import "Reachability.h"
#import "AVKit/AVKit.h"
#import "DropBox.h"
#import "Realm.h"
#import "ArtworkDownload.h"
@import AVFoundation;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DBClientsManager setupWithAppKey:DROPBOX_KEY];
    NSError *error;
    NSURL *artworkDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    artworkDirectory = [artworkDirectory URLByAppendingPathComponent:@"artwork/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:artworkDirectory.relativePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    NSURL *songsDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    songsDirectory = [songsDirectory URLByAppendingPathComponent:@"songs/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:songsDirectory.relativePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    NSURL *profileImagesDirectory = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    profileImagesDirectory = [profileImagesDirectory URLByAppendingPathComponent:@"profile images"];
    [[NSFileManager defaultManager] createDirectoryAtPath:profileImagesDirectory.relativePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    NSError *setCategoryError = nil;
    [AVAudioSession.sharedInstance setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_APP_ENTERED_BACKGROUND object:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    if (theEvent.type == UIEventTypeRemoteControl)
    {
        switch(theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_REMOTE_EVENT_PLAY_PAUSE_TOGGLE object:nil];
                break;
            default:
                return;
        }
    }
}

#pragma mark - Dropbox integration

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if ([url.pathExtension isEqualToString:@"mp3"]) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        NSString *fileName = [url.lastPathComponent.stringByDeletingPathExtension stringByAppendingString:[formatter stringFromDate:[NSDate date]]];
        fileName = [fileName stringByAppendingPathExtension:@"mp3"];
        NSURL *fileURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        fileURL = [[fileURL URLByAppendingPathComponent:@"songs"] URLByAppendingPathComponent:fileName];
        NSError *error;
        
        [NSFileManager.defaultManager moveItemAtURL:url toURL:fileURL error:&error];
        if (error) {
            NSLog(@"error = %@", error);
        }
        else {
            LocalSongModel *song = [[LocalSongModel alloc] initWithLocalSongURL:fileURL];
            AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:song.localSongURL options:nil];
            NSNumber *duration = [NSNumber numberWithDouble:CMTimeGetSeconds(audioAsset.duration)];
            song.duration = duration;
            
            
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[song] forKeys:@[@"song"]];
            
            [RLMRealm.defaultRealm beginWriteTransaction];
            [RLMRealm.defaultRealm addObject:song];
            [RLMRealm.defaultRealm commitWriteTransaction];
            
            [ArtworkDownload.sharedInstance downloadArtworkForLocalSongModelWithUniqueName:song.songUniqueName];
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_DOWNLOAD_FINISHED object:nil userInfo:userInfo];
            Reachability *reachability = [Reachability reachabilityForInternetConnection];
            if (reachability.isReachable && [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX]) {
                if (![DropBox doesSongExists:song]) {
                    Reachability *reachability = [Reachability reachabilityForInternetConnection];
                    if (reachability.isReachableViaWiFi) {
                        [DropBox uploadLocalSong:song];
                    }
                    else if (reachability.isReachableViaWWAN && [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX_VIA_CELLULAR]) {
                        [DropBox uploadLocalSong:song];
                    }
                }
            }
        }
    }
    else {
        DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
        if (authResult != nil) {
            if ([authResult isSuccess]) {
                NSLog(@"Success! User is logged into Dropbox.");
                DBUserClient *client = [DBClientsManager authorizedClient];
                [[client.filesRoutes createFolderV2:@"/PirateRadio/songs"]
                 setResponseBlock:^(DBFILESFolderMetadata *result, DBFILESCreateFolderError *routeError, DBRequestError *networkError) {
                     if (result) {
                         NSLog(@"%@\n", result);
                     } else {
                         NSLog(@"Directory already exists or there is an error.\n");
                     }
                 }];
                [[client.filesRoutes createFolderV2:@"/PirateRadio/artworks"]
                 setResponseBlock:^(DBFILESFolderMetadata *result, DBFILESCreateFolderError *routeError, DBRequestError *networkError) {
                     if (result) {
                         NSLog(@"%@\n", result);
                     } else {
                         NSLog(@"Directory already exists or there is an error\n");
                     }
                 }];
            } else if ([authResult isCancel]) {
                NSLog(@"Authorization flow was manually canceled by user!");
            } else if ([authResult isError]) {
                NSLog(@"Error: %@", authResult);
            }
            [NSNotificationCenter.defaultCenter postNotificationName:@"dropboxAuthorization" object:nil];
        }
    }
    return NO;
}



@end
