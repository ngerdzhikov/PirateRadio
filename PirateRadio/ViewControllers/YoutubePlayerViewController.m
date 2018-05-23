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
#import "DGActivityIndicatorView.h"

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
