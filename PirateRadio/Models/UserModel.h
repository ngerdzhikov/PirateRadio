//
//  UserModel.h
//  PirateRadio
//
//  Created by A-Team User on 13.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserModel : NSObject

@property (strong, nonatomic, readonly) NSString *username;
@property (strong, nonatomic, readonly) NSString *password;
@property (strong, nonatomic, readonly) NSURL *profileImageURL;
@property (strong, nonatomic, readonly) NSURL *objectID;

- (instancetype)initWithObjectID:(NSURL *)objectID username:(NSString *)username password:(NSString *)password andProfileImageURL:(NSURL *)url;
- (UIImage *)profileImage;

@end
