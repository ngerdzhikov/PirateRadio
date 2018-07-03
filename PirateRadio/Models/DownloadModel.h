//
//  DownloadModel.h
//  PirateRadio
//
//  Created by A-Team User on 11.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoModel;

@interface DownloadModel : NSObject

@property (strong, nonatomic, readonly) NSURL *URL;

- (instancetype)initWithVideoModel:(VideoModel *)videoModel andURL:(NSURL *)url;
- (NSURL *)localURLWithTimeStamp;
- (NSURL *)videoURL;

@end
