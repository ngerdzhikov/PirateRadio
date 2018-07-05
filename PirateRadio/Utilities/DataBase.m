//
//  DataBase.m
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "DataBase.h"
#import "CoreData/CoreData.h"
#import "UIKit/UIKit.h"
#import "VideoModel.h"
#import "ThumbnailModel.h"
#import "LocalSongModel.h"
#import "AVKit/AVKit.h"
#import "AppDelegate.h"
#import "PlaylistModel.h"

@interface DataBase ()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation DataBase

- (instancetype)init {
    self = [super init];
    if (self) {
        id delegate = [[UIApplication sharedApplication] delegate];
        self.context = [delegate managedObjectContext];
    }
    return self;
}

- (NSArray *)users {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    return results;
}

- (void)addUser:(NSString *)username forPassword:(NSString *)password {
    NSManagedObject *transaction = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
    [transaction setValue:username forKey:@"username"];
    [transaction setValue:password forKey:@"password"];
    
    NSError *err;
    [self.context save:&err];
    
}

- (NSManagedObject *)userObjectForUsername:(NSString *)username {
    NSArray *results = self.users;
    for (NSManagedObject *obj in results) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        if ([[dictionary valueForKey:@"username"] isEqualToString:username]) {
            return obj;
        }
    }
    return nil;
}

- (void)addFavouriteVideo:(VideoModel *)video ForUsername:(NSString *)username {
    NSError *err;
    
    NSManagedObject *user = [self userObjectForUsername:username];
    NSMutableOrderedSet *favVideos = [user mutableOrderedSetValueForKey:@"favouriteVideos"];
    
    NSFetchRequest *checkIfVideoExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"YoutubeVideoModel"];
    [checkIfVideoExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"videoId = %@", video.entityId]];
    NSArray *resultFromCheck = [self.context executeFetchRequest:checkIfVideoExistsRequest error:&err];
    NSManagedObject *favVideo;
    if (resultFromCheck.count > 0) {
        favVideo = resultFromCheck.firstObject;
        
    }
    else {
        favVideo = [NSEntityDescription insertNewObjectForEntityForName:@"YoutubeVideoModel" inManagedObjectContext:self.context];
        
        [favVideo setValue:video.entityId forKey:@"videoId"];
        [favVideo setValue:video.title forKey:@"title"];
        [favVideo setValue:video.channelTitle forKey:@"channel"];
        [favVideo setValue:video.videoDuration forKey:@"duration"];
        [favVideo setValue:video.publishedAt forKey:@"publishedAt"];
        [favVideo setValue:video.videoViews forKey:@"views"];
        ThumbnailModel *thumbnail = [video.thumbnails objectForKey:@"high"];
        [favVideo setValue:thumbnail.url forKey:@"thumbnail"];
        
        
    }
    if (![favVideos containsObject:favVideo]) {
        [favVideos addObject:favVideo];
    }
    
    [self.context save:&err];
}

- (void)deleteFavouriteVideo:(VideoModel *)video ForUsername:(NSString *)username {
    NSError *err;
    NSManagedObject *user = [self userObjectForUsername:username];
    NSMutableOrderedSet *favVideos = [user mutableOrderedSetValueForKey:@"favouriteVideos"];
    NSFetchRequest *checkIfExistsRequest = [[NSFetchRequest alloc] initWithEntityName:@"YoutubeVideoModel"];
    [checkIfExistsRequest setPredicate:[NSPredicate predicateWithFormat:@"videoId = %@", video.entityId]];
    NSArray *resultFromCheck = [self.context executeFetchRequest:checkIfExistsRequest error:&err];
    NSManagedObject *favVideo = resultFromCheck.firstObject;
    [favVideos removeObject:favVideo];
    NSSet *usersForThisVideo = [favVideo valueForKey:@"users"];
    if (usersForThisVideo.allObjects.count < 1) {
        [self.context deleteObject:favVideo];
    }
    
    [self.context save:&err];
    
}

- (NSArray *)favouriteVideosForUsername:(NSString *)username {
    NSManagedObject *user = [self userObjectForUsername:username];
    NSOrderedSet *videosSet = [user valueForKey:@"favouriteVideos"];
    NSArray *allVideos = videosSet.array;
    NSMutableArray<VideoModel *> *videos = [[NSMutableArray alloc] init];
    for (NSManagedObject *entity in allVideos) {
        NSString *videoId = [entity valueForKey:@"videoId"];
        NSString *title = [entity valueForKey:@"title"];
        NSString *channel = [entity valueForKey:@"channel"];
        NSString *views = [entity valueForKey:@"views"];
        NSString *publishedAt = [entity valueForKey:@"publishedAt"];
        NSURL *thumbnailURL = [entity valueForKey:@"thumbnail"];
        ThumbnailModel *thumbnail = [[ThumbnailModel alloc] initWithURL:thumbnailURL width:@50 height:@50];
        NSString *duration = [entity valueForKey:@"duration"];
        VideoModel *videoModel = [[VideoModel alloc] initWithVideoId:videoId title:title channel:channel publishedAt:publishedAt thumbnail:thumbnail views:views duration:duration];
        [videos addObject:videoModel];
    }

    return videos;
}

- (NSArray *)allSongs {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalSong"];
    NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSSortDescriptor *artistSort = [NSSortDescriptor sortDescriptorWithKey:@"artist" ascending:YES];
    [request setSortDescriptors:@[artistSort, titleSort]];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    return results;
}

- (void)addNewSong:(LocalSongModel *)song withURL:(NSURL *)url {
    NSManagedObject *dbSong = [NSEntityDescription insertNewObjectForEntityForName:@"LocalSong" inManagedObjectContext:self.context];
    [dbSong setValue:song.artistName forKey:@"artist"];
    [dbSong setValue:song.songTitle forKey:@"title"];
    [dbSong setValue:url forKey:@"videoURL"];
    [dbSong setValue:song.localSongURL.lastPathComponent forKey:@"identityName"];
    
    [dbSong setValue:[NSString stringWithFormat:@"%@", song.duration] forKey:@"duration"];
    
    NSError *err;
    [self.context save:&err];
    
}

- (NSURL *)videoURLForLocalSongModel:(LocalSongModel *)localSong {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"LocalSong"];
    NSError *error = nil;
    [request setPredicate:[NSPredicate predicateWithFormat:@"identityName = %@", localSong.localSongURL.lastPathComponent]];
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in results) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        if ([[dictionary objectForKey:@"identityName"] isEqualToString:localSong.localSongURL.lastPathComponent]) {
            if ([[dictionary valueForKey:@"videoURL"] isKindOfClass:NSNull.class]) {
                return [NSURL URLWithString:@""];
            }
            return [dictionary valueForKey:@"videoURL"];
        }
    }
    return [NSURL URLWithString:@""];
}

- (NSManagedObject *)dbSongForLocalSongModel:(LocalSongModel *)localSong {
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"LocalSong"];
    NSError *error = nil;
    [request setPredicate:[NSPredicate predicateWithFormat:@"identityName = %@", localSong.localSongURL.lastPathComponent]];
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    return results.firstObject;
}

- (void)deleteDBSongforLocalSong:(LocalSongModel *)localSong {
    
    NSManagedObject *dbSong = [self dbSongForLocalSongModel:localSong];
    [self.context deleteObject:dbSong];
    
    [self.context save:nil];
}

- (BOOL)addNewPlaylist:(PlaylistModel *)playlist {
    NSError *err;
    
    NSManagedObject *dbPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:self.context];
    
    [dbPlaylist setValue:playlist.name forKey:@"name"];
    
    [self.context save:&err];
    
    return err == nil;
}

- (BOOL)deletePlaylist:(PlaylistModel *)playlist {
    NSError *err;
    
    NSFetchRequest *playlistRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    [playlistRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@", playlist.name]];
    NSArray *dbPlaylist = [self.context executeFetchRequest:playlistRequest error:&err];
    [self.context deleteObject:dbPlaylist.firstObject];
    [self.context save:&err];
    
    return err == nil;
}


- (void)updateArrayOfSongsForPlaylist:(PlaylistModel *)playlist {
    NSError *error;
    
    NSFetchRequest *playlistRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    [playlistRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@", playlist.name]];
    NSArray *dbPlaylist = [self.context executeFetchRequest:playlistRequest error:&error];
    
    NSMutableOrderedSet *mutableOrderedSetOfDBSongs = [dbPlaylist.firstObject mutableOrderedSetValueForKey:@"songs"];
    [mutableOrderedSetOfDBSongs removeAllObjects];
    for (LocalSongModel *stackSong in playlist.songs) {
        NSManagedObject *dbSong = [self dbSongForLocalSongModel:stackSong];
        [mutableOrderedSetOfDBSongs addObject:dbSong];
    }
    
    [self.context save:&error];
    
}

- (void)renamePlaylistWithNewName:(NSString *)newName forOldPlaylistName:(NSString *)oldName {
    NSError *error;
    
    NSFetchRequest *playlistRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    [playlistRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@", oldName]];
    NSArray *dbPlaylist = [self.context executeFetchRequest:playlistRequest error:&error];
    
    [dbPlaylist.firstObject setValue:newName forKey:@"name"];
    
    [self.context save:&error];
}

- (NSArray *)allPlaylists {
    
    NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    sourcePath = [sourcePath URLByAppendingPathComponent:@"songs"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    NSMutableArray<PlaylistModel *> *playlists = [[NSMutableArray alloc] init];
    for (NSManagedObject *obj in results) {
        PlaylistModel *playlist = [[PlaylistModel alloc] initWithName:[obj valueForKey:@"name"]];
        NSOrderedSet *dbSongsSet = [obj valueForKey:@"songs"];
        for (NSManagedObject *dbSong in dbSongsSet.array) {
            NSURL *localSongURL = [sourcePath URLByAppendingPathComponent:[dbSong valueForKey:@"identityName"]];
            LocalSongModel *song = [[LocalSongModel alloc] initWithLocalSongURL:localSongURL];
            song.videoURL = [dbSong valueForKey:@"videoURL"];
            song.duration = [dbSong valueForKey:@"duration"];
            [playlist.songs addObject:song];
        }
        [playlists addObject:playlist];
    }
    return playlists;
}



@end
