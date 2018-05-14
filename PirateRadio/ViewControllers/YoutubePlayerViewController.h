//
//  YoutubePlayerViewController.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"
#import "YTPlayerView.h"
#import "DownloadButtonWebView.h"

@interface YoutubePlayerViewController : UIViewController <YTPlayerViewDelegate>

@property (strong, nonatomic) VideoModel *videoModel;
@property (weak, nonatomic) IBOutlet YTPlayerView *youtubePlayer;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet DownloadButtonWebView *downloadButtonWebView;
@property (weak, nonatomic) IBOutlet UITextView *videoDescription;



@end
