//
//  DataBase.h
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoModel;

@interface DataBase : NSObject

+ (instancetype)sharedManager;
- (NSArray *)users;
- (void)addFavouriteVideo:(VideoModel *)video ForUsername:(NSString *)username;
- (NSArray *)favouriteVideosForUsername:(NSString *)username;

@end
