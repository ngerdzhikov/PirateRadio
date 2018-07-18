//
//  UserModel.h
//  PirateRadio
//
//  Created by A-Team User on 17.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"
#import "VideoModel.h"
#import "UIKit/UIKit.h"

RLM_ARRAY_TYPE(VideoModel)

@interface UserModel : RLMObject

@property (strong, nonatomic) NSNumber<RLMInt> *userID;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) RLMArray<VideoModel *><VideoModel> *favouriteYoutubeEntities;

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password andUserID:(NSNumber *)userID;
- (NSArray<VideoModel *> *)favouriteVideos;
- (UIImage *)profileImage;

@end
