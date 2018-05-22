//
//  YoutubePlayerViewController.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "YoutubePlayerViewController.h"
#import "YoutubeConnectionManager.h"
#import "YoutubeDownloadManager.h"
#import "NSURL+URLWithQueryItems.h"

#define DOWNLOAD_BUTTON_URL_PREFIX @"https://youtube7.download/mini.php"

@interface YoutubePlayerViewController ()

@end

@implementation YoutubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 };
    [self.youtubePlayer loadWithVideoId:self.videoModel.videoId playerVars:playerVars];
    self.youtubePlayer.delegate = self;
    self.videoTitle.text = self.videoModel.videoTitle;
    self.videoDescription.text = self.videoModel.videoDescription;
    self.videoViews.text = [self.videoModel.videoViews stringByAppendingString:@" views"];
    
    NSURLQueryItem *idItem = [NSURLQueryItem queryItemWithName:@"id" value:self.videoModel.videoId];
    NSURL *buttonURL = [[NSURL URLWithString:DOWNLOAD_BUTTON_URL_PREFIX] URLByAppendingQueryItems:@[idItem]];
    [self.downloadButtonWebView loadRequest:[NSURLRequest requestWithURL:buttonURL]];
    self.downloadButtonWebView.videoModel = self.videoModel;
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self.youtubePlayer playVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
