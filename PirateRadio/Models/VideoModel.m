//
//  VideoModel.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "VideoModel.h"
#import "ThumbnailModel.h"

@interface VideoModel ()

@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSDictionary<NSString *,ThumbnailModel *> *thumbnails;
@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *videoDescription;
@property (strong, nonatomic) NSDate *publishedAt;
@property (strong, nonatomic) NSString *channelTitle;

@end

@implementation VideoModel

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet andVideoId:(NSString *)videoId {
    self = [super init];
    if (self)
    {
        self.videoId = videoId;
        self.videoTitle = [snippet objectForKey:@"title"];
        self.videoDescription = [snippet objectForKey:@"description"];
        self.publishedAt = (NSDate *)[snippet objectForKey:@"publishedAt"];
        
        NSDictionary<NSString *, id> *thumbnailsDict = [snippet objectForKey:@"thumbnails"];
        NSMutableDictionary<NSString *,ThumbnailModel *> *temp = [[NSMutableDictionary alloc] init];
        for (NSString *key in thumbnailsDict.allKeys) {
            
            ThumbnailModel *thumbnail = [[ThumbnailModel alloc] initWithJSONDictionary:[thumbnailsDict objectForKey:key]];
            [temp setObject:thumbnail forKey:key];
        }
        
        self.thumbnails = temp.copy;
        self.channelTitle = [snippet objectForKey:@"channelTitle"];
    }
    
    return self;
}

@end
