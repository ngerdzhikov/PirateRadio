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
@import AVFoundation;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DBClientsManager setupWithAppKey:@"rp9dtda9u6je0kv"];
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
    
    NSError *setCategoryError = nil;
    [AVAudioSession.sharedInstance setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
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
                NSLog(@"UIEventSubtypeRemoteControlTogglePlayPause");
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
    }
    return NO;
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Model"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    return self.persistentContainer.viewContext;
}


@end
