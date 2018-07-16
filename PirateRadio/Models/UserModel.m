//
//  UserModel.m
//  PirateRadio
//
//  Created by A-Team User on 13.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "UserModel.h"
#import "Constants.h"

@interface UserModel ()

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSURL *profileImageURL;
@property (strong, nonatomic) NSURL *objectID;

@end


@implementation UserModel

- (instancetype)initWithObjectID:(NSURL *)objectID username:(NSString *)username password:(NSString *)password andProfileImageURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.objectID = objectID;
        self.username = username;
        self.password = password;
        if (url)
            self.profileImageURL = url;
    }
    return self;
}

- (UIImage *)profileImage {
    if (self.profileImageURL) {
        NSURL *fileURL = [NSFileManager.defaultManager.temporaryDirectory URLByAppendingPathComponent:self.profileImageURL.lastPathComponent];
        if (!fileURL) {
            fileURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
            fileURL = [[[fileURL URLByAppendingPathComponent:@"profile images"] URLByAppendingPathComponent:self.objectID.lastPathComponent] URLByAppendingPathExtension:@"jpeg"];
        }
        NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
        return [UIImage imageWithData:imageData];
    }
    else {
        return [UIImage imageNamed:@"default_user_icon"];
    }
}

@end
