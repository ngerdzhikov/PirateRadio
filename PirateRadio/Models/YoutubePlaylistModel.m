//
//  YoutubePlaylistModel.m
//  PirateRadio
//
//  Created by A-Team User on 18.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "YoutubePlaylistModel.h"
#import "ThumbnailModel.h"
#import "ImageCacher.h"
#import <UIKit/UIKit.h>

@interface YoutubePlaylistModel ()

@property (strong, nonatomic) NSMutableArray<VideoModel *> *playlistItems;

@end


@implementation YoutubePlaylistModel


- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet andPlaylistId:(NSString *)playlistId {
    self = [super initWithSnippet:snippet entityId:playlistId andKind:@"youtube#playlist"];
    if (self) {
        self.playlistItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPlaylistItem:(VideoModel *)entity {
    [self.playlistItems addObject:entity];
}

- (instancetype)initWithVideoModel:(VideoModel *)videoModel {
    self = [super init];
    if (self) {
        self.playlistItems = [[NSMutableArray alloc] init];
        [self.playlistItems addObject:videoModel];
    }
    return self;
}

+ (NSArray<NSString *> *)ignoredProperties {
    return @[@"playlistItems"];
}

@end
