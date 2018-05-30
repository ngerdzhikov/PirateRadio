//
//  YoutubePlayerViewController.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@class VideoModel;
@class DownloadButtonWebView;
@class CBAutoScrollLabel;

@interface YoutubePlayerViewController : UIViewController <YTPlayerViewDelegate>

@property (strong, nonatomic) VideoModel *videoModel;
@property (weak, nonatomic) IBOutlet YTPlayerView *youtubePlayer;
@property (weak, nonatomic) IBOutlet DownloadButtonWebView *downloadButtonWebView;
@property (weak, nonatomic) IBOutlet UITextView *videoDescription;
@property (weak, nonatomic) IBOutlet UILabel *videoViews;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *videoTitle;



@end
