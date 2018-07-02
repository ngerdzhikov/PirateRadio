//
//  YoutubeEntityModel.m
//  PirateRadio
//
//  Created by A-Team User on 18.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "YoutubeEntityModel.h"
#import "ThumbnailModel.h"
#import "ImageCacher.h"

@interface YoutubeEntityModel ()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *entityId;
@property (strong, nonatomic) NSDictionary<NSString *,ThumbnailModel *> *thumbnails;
@property (strong, nonatomic) NSString *entityDescription;
@property (strong, nonatomic) NSString *kind;
@property (strong, nonatomic) NSString *channelTitle;
@property (strong, nonatomic) NSString *publishedAt;

@end


@implementation YoutubeEntityModel

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet entityId:(NSString *)entityId andKind:(NSString *)kind {
    self = [super init];
    if (self)
    {
        self.entityId = entityId;
        self.title = [snippet objectForKey:@"title"];
        self.kind = kind;
        self.entityDescription = [snippet objectForKey:@"description"];
        self.publishedAt = [snippet objectForKey:@"publishedAt"];
        NSDictionary<NSString *, id> *thumbnailsDict = [snippet objectForKey:@"thumbnails"];
        NSMutableDictionary<NSString *,ThumbnailModel *> *temp = [[NSMutableDictionary alloc] init];
        for (NSString *quality in thumbnailsDict.allKeys) {
            NSDictionary *thumbDict = [thumbnailsDict objectForKey:quality];
            ThumbnailModel *thumbnail = [[ThumbnailModel alloc] initWithJSONDictionary:thumbDict];
            [temp setObject:thumbnail forKey:quality];
        }
        self.thumbnails = temp.copy;
        UIImage *thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.thumbnails objectForKey:@"high"].url]];
        [ImageCacher.sharedInstance cacheImage:thumb forSearchResultId:entityId];
        self.channelTitle = [snippet objectForKey:@"channelTitle"];
    }
    
    return self;
}

- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title channel:(NSString *)channel publishedAt:(NSString *)publishedAt thumbnail:(ThumbnailModel *)thumbnailModel {
    self = [super init];
    if (self) {
        self.entityId = videoId;
        self.title = title;
        self.channelTitle = channel;
        self.publishedAt = publishedAt;
        self.thumbnails = @{@"high" : thumbnailModel ?: nil};
    }
    return self;
}

@end
