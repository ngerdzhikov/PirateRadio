//
//  YoutubeEntityModel.h
//  PirateRadio
//
//  Created by A-Team User on 18.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"

@class ThumbnailModel;

RLM_ARRAY_TYPE(ThumbnailModel)

@interface YoutubeEntityModel : RLMObject

@property (strong, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) NSString *entityId;
@property (strong, nonatomic, readonly) ThumbnailModel *thumbnail;
@property (strong, nonatomic, readonly) NSString *kind;
@property (strong, nonatomic, readonly) NSString *channelTitle;
@property (strong, nonatomic, readonly) NSString *publishedAt;
@property (strong, nonatomic, readonly) NSString *entityDescription;

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet entityId:(NSString *)entityId andKind:(NSString *)kind;
- (instancetype)initWithVideoId:(NSString *)videoId title:(NSString *)title channel:(NSString *)channel publishedAt:(NSString *)publishedAt thumbnail:(ThumbnailModel *)thumbnailModel;
- (NSDictionary<NSString *, ThumbnailModel *> *)thumbnails;

@end
