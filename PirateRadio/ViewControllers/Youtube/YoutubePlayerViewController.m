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
#import "SearchResultTableViewCell.h"
#import "ImageCacher.h"
#import "ThumbnailModel.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>

#define DOWNLOAD_BUTTON_URL_PREFIX @"https://youtube7.download/mini.php"

@interface YoutubePlayerViewController ()

@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) NSMutableArray<VideoModel *> *suggestedVideos;
@property (weak, nonatomic) IBOutlet UITableView *suggestedVideosTableView;
@property (weak, nonatomic) IBOutlet UISwitch *autoPlaySwitch;
@property (nonatomic) double timer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation YoutubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self startAnimation];
    
    [self setContentDetailsForVideoModel:self.videoModel];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.suggestedVideosTableView.delegate = self;
    self.suggestedVideosTableView.dataSource = self;
    
    [self makeSearchForSuggestedVideosForVideoId:self.videoModel.videoId];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didStartDownloading:) name:@"downloadingStarted" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stopAnimation:) name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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

- (void)setContentDetailsForVideoModel:(VideoModel *)videoModel {
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"origin" : @"https://www.example.com"
                                 };
    [self.youtubePlayer loadWithVideoId:videoModel.videoId playerVars:playerVars];
    self.youtubePlayer.delegate = self;
    self.videoTitle.text = videoModel.videoTitle;
    self.videoTitle.scrollSpeed = 15;
    self.videoDescription.text = videoModel.videoDescription;
    if ([self.videoDescription.text isEqualToString:@""]) {
        self.videoDescription.text = @"No description.";
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    numberFormatter.groupingSeparator = groupingSeparator;
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    self.videoViews.text = [[numberFormatter stringFromNumber:[numberFormatter numberFromString:videoModel.videoViews]] stringByAppendingString:@" views"];
    
    NSURLQueryItem *idItem = [NSURLQueryItem queryItemWithName:@"id" value:videoModel.videoId];
    NSURL *buttonURL = [[NSURL URLWithString:DOWNLOAD_BUTTON_URL_PREFIX] URLByAppendingQueryItems:@[idItem]];
    [self.downloadButtonWebView loadRequest:[NSURLRequest requestWithURL:buttonURL]];
    self.downloadButtonWebView.videoModel = videoModel;
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

- (void)stopAnimation:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        UILabel *downloadFinishedLabel = [[UILabel alloc] initWithFrame:self.downloadButtonWebView.frame];
        downloadFinishedLabel.text = @"Download finished.";
        downloadFinishedLabel.textAlignment = NSTextAlignmentCenter;
        downloadFinishedLabel.font = [UIFont boldSystemFontOfSize:20];
        [self.scrollView addSubview:downloadFinishedLabel];
    });
}

- (void)stopAnimation {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    [self.blurEffectView removeFromSuperview];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    
    if (state == kYTPlayerStatePlaying) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_YOUTUBE_VIDEO_STARTED_PLAYING object:nil];
    }
    if (state == kYTPlayerStatePaused) {
        
    }
    if (state == kYTPlayerStateEnded && self.autoPlaySwitch.isOn && (self.suggestedVideos.count > 0)) {
        [self startAutoPlayAnimation];
    }
}

- (void)didEnterBackground:(NSNotification *)notification {

    if (self.youtubePlayer.playerState == kYTPlayerStatePlaying) {

        [self.youtubePlayer playVideo];
    }
}

- (IBAction)autoPlaySwitchTap:(id)sender {
    if (self.autoPlaySwitch.isOn && self.youtubePlayer.playerState == kYTPlayerStateEnded && (self.suggestedVideos.count > 0)) {
        [self startAutoPlayAnimation];
    }
}

- (void)makeSearchForSuggestedVideosForVideoId:(NSString *)videoId {
    [YoutubeConnectionManager makeYoutubeRequestForSuggestedVideosForVideoId:videoId andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error = %@", error);
        }
        else {
            NSError *serializationError;
            NSDictionary<NSString *, id> *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                NSLog(@"Error = %@", serializationError.localizedDescription);
            }
            else {
                NSArray *items = [responseDict objectForKey:@"items"];
                for (NSDictionary *item in items) {
                    NSString *videoId = [[item objectForKey:@"id"] objectForKey:@"videoId"];
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    VideoModel *videoModel = [[VideoModel alloc] initWithSnippet:snippet andVideoId:videoId];
                    if (!self.suggestedVideos)
                        self.suggestedVideos = [[NSMutableArray alloc] initWithCapacity:items.count];
                    [self.suggestedVideos addObject:videoModel];
                    
                }
                [self makeSearchForVideoDurationsWithVideoModels:self.suggestedVideos];
            }
        }
    }];
}

- (void)makeSearchForVideoDurationsWithVideoModels:(NSMutableArray<VideoModel *> *)videoModels {
    NSArray<NSString *> *videoIds = [[NSArray alloc] initWithArray:[videoModels valueForKey:@"videoId"]];
    [YoutubeConnectionManager makeYoutubeRequestForVideoDurationsWithVideoIds:videoIds andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error searching for video durations = %@", error);
            [self stopAnimation];
        }
        else {
            
            NSError *serializationError;
            NSDictionary<NSString *, id> *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                NSLog(@"Error = %@", serializationError.localizedDescription);
            }
            
            else {
                NSUInteger index = 0;
                NSArray *items = [responseDict objectForKey:@"items"];
                for (NSDictionary *item in items) {
                    NSString *duration = [[item objectForKey:@"contentDetails"] objectForKey:@"duration"];
                    NSString *views = [[item objectForKey:@"statistics"] objectForKey:@"viewCount"];
                    self.suggestedVideos[index].videoDuration = duration;
                    self.suggestedVideos[index].videoViews = views;
                    index++;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self stopAnimation];
                [self.suggestedVideosTableView reloadData];
            });
        }
    }];
}

#pragma mark tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggestedVideos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 255.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    VideoModel *videoModel = self.suggestedVideos[indexPath.row];
    UIImage *thumbnail = [ImageCacher.sharedInstance imageForVideoId:videoModel.videoId];
    if (!thumbnail) {
        thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[videoModel.thumbnails objectForKey:@"high"].url]];
    }
    cell.videoImage.image = thumbnail;
    cell.videoTitle.text = videoModel.videoTitle;
    cell.channelTitle.text = videoModel.channelTitle;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    numberFormatter.groupingSeparator = groupingSeparator;
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    cell.views.text = [numberFormatter stringFromNumber:[numberFormatter numberFromString:videoModel.videoViews]];
    
    cell.duration.text = videoModel.formattedDuration;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormatter dateFromString:videoModel.publishedAt];
    cell.dateUploaded.text = [[dateFormatter stringFromDate:date] componentsSeparatedByString:@"T"][0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self pushYoutubePlayerWithVideoModel:self.suggestedVideos[indexPath.row]];
}

- (void)pushYoutubePlayerWithVideoModel:(VideoModel *)videoModel {
    YoutubePlayerViewController *viewControllerForSelectedVideo = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YoutubePlayerViewController"];
    viewControllerForSelectedVideo.videoModel = videoModel;
    
    [self.navigationController pushViewController:viewControllerForSelectedVideo animated:YES];
    [self removeFromParentViewController];
    
}

- (void)playNextButtonTap {
    [self pushYoutubePlayerWithVideoModel:self.suggestedVideos[0]];
}

- (void)startAutoPlayAnimation {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = self.youtubePlayer.bounds;
    [self.youtubePlayer addSubview:self.blurEffectView];
    

    
    MBCircularProgressBarView *circularProgressBar = [[MBCircularProgressBarView alloc] initWithFrame:
                                                      CGRectMake(self.youtubePlayer.frame.size.width/2 - 50, self.youtubePlayer.frame.size.height/2 - 50, 100, 100)];
    circularProgressBar.maxValue = 5;
    circularProgressBar.value = 0;
    circularProgressBar.showUnitString = NO;
    circularProgressBar.showValueString = NO;
    circularProgressBar.backgroundColor = [UIColor clearColor];
    [self.youtubePlayer addSubview:circularProgressBar];
    
    self.timer = 0;
    UILabel *nextVideoLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(self.youtubePlayer.frame.origin.x, circularProgressBar.frame.origin.y - 30, self.youtubePlayer.frame.size.width, 20)];
    nextVideoLabel.font = [UIFont systemFontOfSize:17];
    nextVideoLabel.textAlignment = NSTextAlignmentCenter;
    nextVideoLabel.text = [NSString stringWithFormat:@"Next: %@", self.suggestedVideos[0].videoTitle];
    [self.youtubePlayer addSubview:nextVideoLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(circularProgressBar.frame.origin.x, circularProgressBar.frame.origin.y + 100, 100, 30)];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.youtubePlayer addSubview:cancelButton];
    
    UIButton *playNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playNextButton setImage:[UIImage imageNamed:@"next_button_icon"] forState:UIControlStateNormal];
    [playNextButton setFrame:CGRectMake(circularProgressBar.frame.origin.x + circularProgressBar.frame.size.width / 2 - 15,
                                        circularProgressBar.frame.origin.y + circularProgressBar.frame.size.height / 2  - 15,
                                        30,
                                        30)];
    [playNextButton addTarget:self action:@selector(playNextButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.youtubePlayer addSubview:playNextButton];
    
    [[NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!self.autoPlaySwitch.isOn) {
            [timer invalidate];
            [circularProgressBar removeFromSuperview];
            [self.blurEffectView removeFromSuperview];
            [cancelButton removeFromSuperview];
            
        }
        self.timer += timer.timeInterval;
        circularProgressBar.value = self.timer;
        if (self.timer >= 5) {
            [timer invalidate];
            [self pushYoutubePlayerWithVideoModel:self.suggestedVideos[0]];
        }
    }] fire];

    
}

- (void)cancelButtonClicked {
    [self.autoPlaySwitch setOn:NO animated:YES];
}

- (void)didStartDownloading:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScalePulseOutRapid];
        self.activityIndicatorView.tintColor = [UIColor blackColor];
        self.activityIndicatorView.frame = self.downloadButtonWebView.frame;
        [self.scrollView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    });
    self.downloadButtonWebView.hidden = YES;
}

@end
