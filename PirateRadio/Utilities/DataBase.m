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
    NSManagedObject *user = [self userObjectForUsername:username];
    NSMutableSet *favVideos = [user mutableSetValueForKey:@"favouriteVideos"];
    NSManagedObject *favVideo = [NSEntityDescription insertNewObjectForEntityForName:@"YoutubeVideoModel" inManagedObjectContext:self.context];
    
    [favVideo setValue:video.entityId forKey:@"videoId"];
    [favVideo setValue:video.title forKey:@"title"];
    [favVideo setValue:video.channelTitle forKey:@"channel"];
    [favVideo setValue:video.videoDuration forKey:@"duration"];
    [favVideo setValue:video.publishedAt forKey:@"publishedAt"];
    [favVideo setValue:video.videoViews forKey:@"views"];
    ThumbnailModel *thumbnail = [video.thumbnails objectForKey:@"high"];
    [favVideo setValue:thumbnail.url forKey:@"thumbnail"];
    
    NSMutableSet *usersForCurrentFavVideo = [favVideo mutableSetValueForKey:@"users"];
    [usersForCurrentFavVideo addObject:user];
    
    [favVideos addObject:favVideo];
    
    NSError *err;
    [self.context save:&err];
}

- (NSArray *)favouriteVideosForUsername:(NSString *)username {
    NSManagedObject *user = [self userObjectForUsername:username];
    NSSet *videosSet = [user valueForKey:@"favouriteVideos"];
    NSArray *allVideos = videosSet.allObjects;
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
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:song.localSongURL options:nil];
    NSNumber *duration = [NSNumber numberWithDouble:CMTimeGetSeconds(audioAsset.duration)];
    [dbSong setValue:[NSString stringWithFormat:@"%@", duration] forKey:@"duration"];
    
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
            return [dictionary valueForKey:@"videoURL"];
        }
    }
    return nil;
}

- (void)deleteDBSongforLocalSong:(LocalSongModel *)localSong {
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"LocalSong"];
    NSError *error = nil;
    [request setPredicate:[NSPredicate predicateWithFormat:@"identityName = %@", localSong.localSongURL.lastPathComponent]];
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in results) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        if ([[dictionary objectForKey:@"identityName"] isEqualToString:localSong.localSongURL.lastPathComponent]) {
            [self.context deleteObject:obj];
        }
    }
}

- (void)addNewPlaylist:(PlaylistModel *)playlist {
    NSManagedObject *dbPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:self.context];
    
    [dbPlaylist setValue:playlist.name forKey:@"name"];
    
    [self.context save:nil];
}

- (void)addArrayOfSongs:(NSArray<LocalSongModel *> *)songs forPlaylist:(PlaylistModel *)playlist {
    NSError *error;
    
    NSFetchRequest *songRequest = [[NSFetchRequest alloc]initWithEntityName:@"LocalSong"];
    NSArray *songURLs = [songs valueForKey:@"localSongURL"];
    NSMutableArray<NSString *> *identityNames = [[NSMutableArray alloc] init];
    for (NSURL *songURL in songURLs) {
        [identityNames addObject:songURL.lastPathComponent];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identityName IN %@", identityNames];
    [songRequest setPredicate:predicate];
    NSArray *dbSongs = [self.context executeFetchRequest:songRequest error:&error];
    
    if (!error) {
        
        NSFetchRequest *playlistRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
        [playlistRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@", playlist.name]];
        NSArray *dbPlaylist = [self.context executeFetchRequest:playlistRequest error:&error];
        
        if (!error && dbPlaylist.firstObject != nil) {
            NSMutableSet *dbPlaylistSongs = [dbPlaylist.firstObject mutableSetValueForKey:@"songs"];
            for (NSManagedObject *obj in dbSongs) {
                [dbPlaylistSongs addObject:obj];
            }
            [self.context save:&error];
        }

    }
    
}

- (void)removeArrayOfSongs:(NSArray<LocalSongModel *> *)songs fromPlaylist:(PlaylistModel *)playlist {
    NSError *error;
    
    NSFetchRequest *songRequest = [[NSFetchRequest alloc]initWithEntityName:@"LocalSong"];
    NSArray *songURLs = [songs valueForKey:@"localSongURL"];
    NSMutableArray<NSString *> *identityNames = [[NSMutableArray alloc] init];
    for (NSURL *songURL in songURLs) {
        [identityNames addObject:songURL.lastPathComponent];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identityName IN %@", identityNames];
    [songRequest setPredicate:predicate];
    NSArray *dbSongs = [self.context executeFetchRequest:songRequest error:&error];
    
    if (!error) {
        
        NSFetchRequest *playlistRequest = [[NSFetchRequest alloc]initWithEntityName:@"Playlist"];
        [playlistRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@", playlist.name]];
        NSArray *dbPlaylist = [self.context executeFetchRequest:playlistRequest error:&error];
        
        if (!error && dbPlaylist.firstObject != nil) {
            NSMutableSet *dbPlaylistSongs = [dbPlaylist.firstObject mutableSetValueForKey:@"songs"];
            for (NSManagedObject *obj in dbSongs) {
                [dbPlaylistSongs removeObject:obj];
            }
            [self.context save:&error];
        }
    }
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
        NSSet *dbSongsSet = [obj valueForKey:@"songs"];
        NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        NSSortDescriptor *artistSort = [NSSortDescriptor sortDescriptorWithKey:@"artist" ascending:YES];
        
        NSMutableArray *dbSongs = dbSongsSet.allObjects.mutableCopy;
        [dbSongs sortUsingDescriptors:@[artistSort, titleSort]];
        
        for (NSManagedObject *dbSong in dbSongs) {
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
