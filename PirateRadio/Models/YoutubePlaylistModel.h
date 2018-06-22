//
//  YoutubePlaylistModel.h
//  PirateRadio
//
//  Created by A-Team User on 18.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoutubeEntityModel.h"

@class ThumbnailModel;
@class VideoModel;

@interface YoutubePlaylistModel : YoutubeEntityModel

@property (strong, nonatomic, readonly) NSMutableArray<VideoModel *> *playlistItems;
@property NSInteger itemsCount;

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet andPlaylistId:(NSString *)playlistId;
- (void)addPlaylistItem:(YoutubeEntityModel *)entity;
- (instancetype)initWithVideoModel:(VideoModel *)videoModel;

@end
