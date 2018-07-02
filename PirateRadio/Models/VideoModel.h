//
//  VideoModel.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoutubeEntityModel.h"

@class ThumbnailModel;

@interface VideoModel : YoutubeEntityModel

@property (strong, nonatomic) NSString *videoDuration;
@property (strong, nonatomic) NSString *videoViews;

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet andVideoId:(NSString *)videoId;
- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title channel:(NSString *)channel publishedAt:(NSString *)publishedAt thumbnail:(ThumbnailModel *)thumbnailModel views:(NSString *)views duration:(NSString *)duration;
- (NSString *)formattedDuration;

@end
