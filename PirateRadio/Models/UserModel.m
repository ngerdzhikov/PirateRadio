//
//  UserModel.m
//  PirateRadio
//
//  Created by A-Team User on 17.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password andUserID:(NSNumber *)userID {
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
        self.userID = userID;
    }
    return self;
}

- (UIImage *)profileImage {
    NSURL *fileURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    fileURL = [[[fileURL URLByAppendingPathComponent:@"profile images"] URLByAppendingPathComponent:self.userID.stringValue] URLByAppendingPathExtension:@"jpeg"];
    NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
    if (imageData) {
        return [UIImage imageWithData:imageData];
    }
    else {
        return [UIImage imageNamed:@"default_user_icon"];
    }
}

- (NSArray<VideoModel *> *)favouriteVideos {
    NSMutableArray<VideoModel *> *favVideos = [[NSMutableArray alloc] init];
    for (VideoModel *entity in self.favouriteYoutubeEntities) {
        [favVideos addObject:entity];
    }
    return favVideos;
}


@end
