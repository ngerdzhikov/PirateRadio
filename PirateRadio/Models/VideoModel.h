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
- (NSString *)formattedDuration;

@end
