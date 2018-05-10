//
//  VideoModel.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoModel : NSObject

@property (weak, nonatomic)  NSString *videoId;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *videoDescription;
@property (strong, nonatomic) NSDate *publishedAt;

@end
