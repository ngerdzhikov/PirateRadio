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

@interface DataBase ()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation DataBase

+ (instancetype)sharedManager {
    static DataBase *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

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

@end
