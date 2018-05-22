//
//  VideoModel.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ThumbnailModel;

@interface VideoModel : NSObject

@property (strong, nonatomic, readonly) NSString *videoId;
@property (strong, nonatomic, readonly) NSDictionary<NSString *,ThumbnailModel *> *thumbnails;
@property (strong, nonatomic, readonly) NSString *videoTitle;
@property (strong, nonatomic, readonly) NSString *videoDescription;
@property (strong, nonatomic, readonly) NSString *publishedAt;
@property (strong, nonatomic, readonly) NSString *channelTitle;
@property (strong, nonatomic) NSString *videoDuration;
@property (strong, nonatomic) NSString *videoViews;

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet andVideoId:(NSString *)videoId;


@end
