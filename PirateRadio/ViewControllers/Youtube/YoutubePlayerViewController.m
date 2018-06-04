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
#import "DownloadButtonWebView.h"
#import "VideoModel.h"
#import "NSURL+URLWithQueryItems.h"
#import "DGActivityIndicatorView.h"
#import "Constants.h"
#import "CBAutoScrollLabel.h"

#define DOWNLOAD_BUTTON_URL_PREFIX @"https://youtube7.download/mini.php"

@interface YoutubePlayerViewController ()

@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

@end

@implementation YoutubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startAnimation];
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"origin" : @"https://www.example.com"
                                 };
    [self.youtubePlayer loadWithVideoId:self.videoModel.videoId playerVars:playerVars];
    self.youtubePlayer.delegate = self;
    self.videoTitle.text = self.videoModel.videoTitle;
    self.videoTitle.scrollSpeed = 15;
    self.videoDescription.text = self.videoModel.videoDescription;
    if ([self.videoDescription.text isEqualToString:@""]) {
        self.videoDescription.text = @"No description.";
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    numberFormatter.groupingSeparator = groupingSeparator;
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    self.videoViews.text = [[numberFormatter stringFromNumber:[numberFormatter numberFromString:self.videoModel.videoViews]] stringByAppendingString:@" views"];
    
    NSURLQueryItem *idItem = [NSURLQueryItem queryItemWithName:@"id" value:self.videoModel.videoId];
    NSURL *buttonURL = [[NSURL URLWithString:DOWNLOAD_BUTTON_URL_PREFIX] URLByAppendingQueryItems:@[idItem]];
    [self.downloadButtonWebView loadRequest:[NSURLRequest requestWithURL:buttonURL]];
    self.downloadButtonWebView.videoModel = self.videoModel;
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self.youtubePlayer playVideo];
    [self stopAnimation];
}

- (void)startAnimation {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView.frame = self.view.bounds;
        self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:self.blurEffectView];
    }
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeCookieTerminator];
    self.activityIndicatorView.tintColor = [UIColor blackColor];
    self.activityIndicatorView.frame = CGRectMake(self.navigationController.view.frame.origin.x/2-10, self.navigationController.view.frame.origin.y/2, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.navigationController.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}


- (void)stopAnimation {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    [self.blurEffectView removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAnimation];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    

}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    
    if (state == kYTPlayerStatePlaying) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_YOUTUBE_VIDEO_STARTED_PLAYING object:nil];
    }
    if (state == kYTPlayerStatePaused) {
        
    }
}

- (void)didEnterBackground:(NSNotification *)notification {

    if (self.youtubePlayer.playerState == kYTPlayerStatePlaying) {

        [self.youtubePlayer playVideo];
    }
    

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
