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

@end


@implementation UserModel

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password andProfileImageURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.username = username;
        self.password = password;
        if (url)
            self.profileImageURL = url;
    }
    return self;
}

-(UIImage *)profileImage {
    if (self.profileImageURL) {
        NSURL *fileURL = [NSFileManager.defaultManager.temporaryDirectory URLByAppendingPathComponent:self.profileImageURL.lastPathComponent];
        NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
        return [UIImage imageWithData:imageData];
    }
    else {
        return [UIImage imageNamed:@"default_user_icon"];
    }

}

@end
