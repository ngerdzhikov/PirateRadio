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
#import "YoutubePlaylistModel.h"
#import "SearchResultTableViewCell.h"
#import "MainTabBarController.h"
#import "ImageCacher.h"
#import "ThumbnailModel.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>
#import "DataBase.h"
#import "Toast.h"

@import MediaPlayer;

#define DOWNLOAD_BUTTON_URL_PREFIX @"https://youtube7.download/mini.php"

@interface YoutubePlayerViewController ()

@property (weak, nonatomic) IBOutlet UITableView *suggestedVideosTableView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) DownloadButtonWebView *downloadButtonWebView;
@property (strong, nonatomic) CBAutoScrollLabel *videoTitle;
@property (strong, nonatomic) UITextView *videoDescription;
@property (strong, nonatomic) UIButton *expandTextViewButton;
@property (strong, nonatomic) UISwitch *autoPlaySwitch;
@property (strong, nonatomic) UILabel *videoViewsLabel;
@property (strong, nonatomic) UILabel *autoPlayLabel;
@property (strong, nonatomic) UILabel *downloadFinishedLabel;
@property (strong, nonatomic) NSMutableDictionary<NSString *, VideoModel *> *playlistVideosDict;

@property double timer;
@property double descriptionHeight;
@property BOOL isNextPageEnabled;
@property BOOL isPlayingFromPlaylist;
@property BOOL isSegueDone;

@end

@implementation YoutubePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

- (void)reloadView {
    [self startAnimation];
    
    self.youtubePlayer.delegate = self;
    
    self.currentVideoModel = self.youtubePlaylist.playlistItems.firstObject;
    
    self.descriptionHeight = 50;
    
    self.suggestedVideosTableView.delegate = self;
    self.suggestedVideosTableView.dataSource = self;
    
    if (self.youtubePlaylist.playlistItems.count <= 1) {
        [self setYoutubePlayerForVideoModel:self.currentVideoModel];
        [self makeSearchForSuggestedVideosForVideoId:self.currentVideoModel.entityId];
        self.isPlayingFromPlaylist = NO;
    }
    else {
        [self setYoutubePlayerForVideoModel:self.youtubePlaylist.playlistItems.firstObject];
        self.suggestedVideos = self.youtubePlaylist.playlistItems;
        [self makeSearchForVideoDurationsWithVideoModels:self.suggestedVideos withStartingIndex:0];
        self.playlistVideosDict = [[NSMutableDictionary alloc] initWithObjects:self.suggestedVideos forKeys:[self.suggestedVideos valueForKey:@"entityId"]];
        self.isPlayingFromPlaylist = YES;
        self.isNextPageEnabled = YES;
    }
    
    UIBarButtonItem *nextVideoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(playNextVideo)];
    UIBarButtonItem *addToFavourites = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(addVideoToFavourites)];
    
    if (self.isPlayingFromPlaylist) {
        UIBarButtonItem *previousVideoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playPreviousVideo)];
        self.navigationItem.rightBarButtonItems = @[nextVideoButton, previousVideoButton, addToFavourites];
    }
    else
        self.navigationItem.rightBarButtonItems = @[nextVideoButton, addToFavourites];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self.youtubePlayer selector:@selector(pauseVideo) name:NOTIFICATION_AVPLAYER_STARTED_PLAYING object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didStartDownloading:) name:NOTIFICATION_DID_START_DOWNLOADING object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(stopDownloadingAnimation:) name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
    
    self.isSegueDone = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_SEGUE_DONE];
    
    if ([self.currentVideoModel.entityId isEqualToString:@"P_XaNKWZsXc"] || [self.currentVideoModel.entityId isEqualToString:@"ROAVuLc28IY"]) {
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkForSegue:) userInfo:nil repeats:YES];
    }
}

- (void)checkForSegue:(NSTimer *)timer {
    if ([self.currentVideoModel.entityId isEqualToString:@"ROAVuLc28IY"]) {
        if (self.youtubePlayer.currentTime < 13.0 && self.youtubePlayer.currentTime > 12.0) {
            [NSUserDefaults.standardUserDefaults setBool:NO forKey:USER_DEFAULTS_SEGUE_DONE];
            [NSUserDefaults.standardUserDefaults synchronize];
            self.isSegueDone = NO;
            
            MainTabBarController *mainTabBarController = (MainTabBarController *)self.parentViewController.parentViewController;
            dispatch_async(dispatch_get_main_queue(), ^{
                [mainTabBarController checkIfSegueDone];
            });
            [timer invalidate];
            [self.suggestedVideosTableView reloadData];
        }
    }
    else {
        if (self.youtubePlayer.currentTime < 127.2 && self.youtubePlayer.currentTime > 126.2) {
            [NSUserDefaults.standardUserDefaults setBool:YES forKey:USER_DEFAULTS_SEGUE_DONE];
            [NSUserDefaults.standardUserDefaults synchronize];
            self.isSegueDone = YES;
            
            MainTabBarController *mainTabBarController = (MainTabBarController *)self.parentViewController.parentViewController;
            [mainTabBarController checkIfSegueDone];
            [timer invalidate];
            [self.suggestedVideosTableView reloadData];
        }
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [MPRemoteCommandCenter.sharedCommandCenter.playCommand removeTarget:nil];
    [MPRemoteCommandCenter.sharedCommandCenter.pauseCommand removeTarget:nil];
    [MPRemoteCommandCenter.sharedCommandCenter.nextTrackCommand removeTarget:nil];
    [MPRemoteCommandCenter.sharedCommandCenter.previousTrackCommand removeTarget:nil];
    [MPRemoteCommandCenter.sharedCommandCenter.changePlaybackPositionCommand removeTarget:nil];
    [MPRemoteCommandCenter.sharedCommandCenter.togglePlayPauseCommand removeTarget:nil];
    
    if (self.isSegueDone) {
        [MPRemoteCommandCenter.sharedCommandCenter.playCommand setEnabled:YES];
        [MPRemoteCommandCenter.sharedCommandCenter.pauseCommand setEnabled:YES];
        [MPRemoteCommandCenter.sharedCommandCenter.playCommand addTarget:self.youtubePlayer action:@selector(playVideo)];
        [MPRemoteCommandCenter.sharedCommandCenter.pauseCommand addTarget:self.youtubePlayer action:@selector(pauseVideo)];
        [MPRemoteCommandCenter.sharedCommandCenter.nextTrackCommand addTarget:self action:@selector(playNextVideo)];
        if (self.isPlayingFromPlaylist) {
            [MPRemoteCommandCenter.sharedCommandCenter.previousTrackCommand addTarget:self action:@selector(playPreviousVideo)];
        }
    }
    else {
        [MPRemoteCommandCenter.sharedCommandCenter.playCommand setEnabled:NO];
        [MPRemoteCommandCenter.sharedCommandCenter.pauseCommand setEnabled:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAnimation];
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self updateMPNowPlayingInfoCenterWithLoadedSongInfoAndPlaybackRate:0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MEMORY WARNING");
}

- (void)setYoutubePlayerForVideoModel:(VideoModel *)videoModel {
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"origin" : @"https://www.example.com"
                                 };
    [self.youtubePlayer loadWithVideoId:videoModel.entityId playerVars:playerVars];
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    [self.youtubePlayer playVideo];
    [self updateMPNowPlayingInfoCenterWithLoadedSongInfoAndPlaybackRate:1];
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

- (void)didStartDownloading:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeLineScalePulseOutRapid];
        self.activityIndicatorView.tintColor = [UIColor blackColor];
        UITableViewCell *cell = [self.suggestedVideosTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        self.activityIndicatorView.frame = self.downloadButtonWebView.frame;
        [cell addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    });
    self.downloadButtonWebView.hidden = YES;
    
}

- (void)stopDownloadingAnimation:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        UITableViewCell *cell = [self.suggestedVideosTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
//        CGRect frame = cell.frame;
        self.downloadFinishedLabel = [[UILabel alloc] initWithFrame:self.downloadButtonWebView.frame];
        self.downloadFinishedLabel.text = @"Download finished.";
        self.downloadFinishedLabel.textAlignment = NSTextAlignmentCenter;
        self.downloadFinishedLabel.font = [UIFont boldSystemFontOfSize:20];
        [cell addSubview:self.downloadFinishedLabel];
        self.downloadButtonWebView = nil;
    });
}

- (void)stopAnimation {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    [self.blurEffectView removeFromSuperview];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    if (state == kYTPlayerStatePaused){}
    if (state == kYTPlayerStatePlaying){}
    if (self.view.window) {
        if (state == kYTPlayerStatePlaying) {
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_YOUTUBE_VIDEO_STARTED_PLAYING object:nil];
            [self updateMPNowPlayingInfoCenterWithLoadedSongInfoAndPlaybackRate:1.0];
        }
        if (state == kYTPlayerStatePaused) {
            [self updateMPNowPlayingInfoCenterWithLoadedSongInfoAndPlaybackRate:0];
        }
        if (state == kYTPlayerStateEnded && self.autoPlaySwitch.isOn && (self.suggestedVideos.count > 0)) {
            [self startAutoPlayAnimation];
        }
        if (state == kYTPlayerStateUnstarted) {
            
        }
    }
    else {
    }
 
}

- (void)didEnterBackground:(NSNotification *)notification {

    if (self.youtubePlayer.playerState == kYTPlayerStatePlaying && self.isSegueDone) {
        
        [self.youtubePlayer playVideo];
    }
}

- (void)autoPlaySwitchTap:(id)sender {
    if (self.autoPlaySwitch.isOn && self.youtubePlayer.playerState == kYTPlayerStateEnded && (self.suggestedVideos.count > 0)) {
        [self startAutoPlayAnimation];
    }
}

#pragma mark Youtube requests

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
                self.suggestedVideos = [[NSMutableArray alloc] init];
                for (NSDictionary *item in items) {
                    NSString *videoId = [[item objectForKey:@"id"] objectForKey:@"videoId"];
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    VideoModel *videoModel = [[VideoModel alloc] initWithSnippet:snippet andVideoId:videoId];
                    
                    [self.suggestedVideos addObject:videoModel];
                }
                [self makeSearchForVideoDurationsWithVideoModels:self.suggestedVideos withStartingIndex:0];
            }
        }
    }];
}

- (void)makeSearchForVideoDurationsWithVideoModels:(NSArray<VideoModel *> *)videoModels withStartingIndex:(NSUInteger)indexToStart {
    NSArray<NSString *> *videoIds = [[NSArray alloc] initWithArray:[videoModels valueForKey:@"entityId"]];
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
                NSUInteger index = indexToStart;
                NSArray *items = [responseDict objectForKey:@"items"];
                for (NSDictionary *item in items) {
                    NSString *duration = [[item objectForKey:@"contentDetails"] objectForKey:@"duration"];
                    NSString *views = [[item objectForKey:@"statistics"] objectForKey:@"viewCount"];
                    self.suggestedVideos[index].videoDuration = duration;
                    self.suggestedVideos[index].videoViews = views;
                    index++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                    [self.suggestedVideosTableView reloadData];
                });
            }
        }
    }];
}

- (void)makeSearchForPlaylistItemsWithPlaylist:(YoutubePlaylistModel *)youtubePlaylistModel andNextPageToken:(NSString *)nextPageToken {
    [YoutubeConnectionManager makeYoutubeRequestForPlaylistItemsForPlaylistId:youtubePlaylistModel.entityId withNextPageToken:nextPageToken andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error searching for playlist items = %@", error);
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
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    NSDictionary *contentDetails = [item objectForKey:@"contentDetails"];
                    NSString *entityId = [contentDetails objectForKey:@"videoId"];
                    VideoModel *entity = [[VideoModel alloc] initWithSnippet:snippet entityId:entityId andKind:@"youtube#video"];
                    [youtubePlaylistModel addPlaylistItem:entity];
                }
                NSString *totalResults = [[responseDict objectForKey:@"pageInfo"] objectForKey:@"totalResults"];
                NSString *resultsPerPage = [[responseDict objectForKey:@"pageInfo"] objectForKey:@"resultsPerPage"];
                if (totalResults.integerValue != youtubePlaylistModel.playlistItems.count) {
                    NSString *newNextPageToken = [responseDict objectForKey:@"nextPageToken"];
                    self.nextPageToken = newNextPageToken;
                }
                else {
                    self.nextPageToken = nil;
                }
                    NSRange range = NSMakeRange(self.suggestedVideos.count - resultsPerPage.integerValue, resultsPerPage.integerValue);
                    NSArray<VideoModel *> *videosToSearch = [self.suggestedVideos subarrayWithRange:range];
                    [self makeSearchForVideoDurationsWithVideoModels:videosToSearch withStartingIndex:self.suggestedVideos.count - resultsPerPage.integerValue];
            }
        }
    }];
}

#pragma mark tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return self.suggestedVideos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 2) {
            return self.descriptionHeight;
        }
        if (indexPath.row == 3 && !self.isSegueDone) {
            return 0.0f;
        }
        return 50.0f;
    }
    return 255.0f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            [self addVideoTitleInCell:cell];
        }
        else if (indexPath.row == 1) {
            [self addVideoViewsAndAutoPlaySwitchInCell:cell];
        }
        else if (indexPath.row == 2) {
            [self addVideoDescriptionInCell:cell];
        }
        else if (indexPath.row == 3) {
            [self addDownloadButtonInCell:cell];
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
        VideoModel *videoModel = self.suggestedVideos[indexPath.row];
        UIImage *thumbnail = [ImageCacher.sharedInstance imageForSearchResultId:videoModel.entityId];
        if (!thumbnail) {
            thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[videoModel.thumbnails objectForKey:@"high"].url]];
            [ImageCacher.sharedInstance cacheImage:thumbnail forSearchResultId:videoModel.entityId];
        }
        cell.videoImage.image = thumbnail;
        cell.videoTitle.text = videoModel.title;
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
    else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1)
        [self loadNextVideoWithVideoModel:self.suggestedVideos[indexPath.row]];
}

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) return YES;
    if (indexPath.section == 0 && indexPath.row == 2) return YES;
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if ((maximumOffset - offset) <= 200) {
        if (self.nextPageToken && self.isNextPageEnabled && self.isPlayingFromPlaylist) {
            self.isNextPageEnabled = NO;
            [self makeSearchForPlaylistItemsWithPlaylist:self.youtubePlaylist andNextPageToken:self.nextPageToken];
        }
    }
}

- (void)playNextVideo {
    [self loadNextVideoWithVideoModel:[self nextVideoModelForVideoModel:self.currentVideoModel]];
}

- (void)playPreviousVideo {
    [self loadNextVideoWithVideoModel:[self previousVideoModelForVideoModel:self.currentVideoModel]];
}

- (void)loadNextVideoWithVideoModel:(VideoModel *)videoModel {
    
    self.currentVideoModel = videoModel;
    
    [self.youtubePlayer cueVideoById:videoModel.entityId startSeconds:0.1 suggestedQuality:kYTPlaybackQualityAuto];
    [self.youtubePlayer playVideo];
    
    if (!self.isPlayingFromPlaylist) {
        [self makeSearchForSuggestedVideosForVideoId:videoModel.entityId];
    }
    [self.downloadFinishedLabel removeFromSuperview];
    self.downloadFinishedLabel = nil;
    
    
    
    
//    removes the added information about next song and play and cancel buttons
    for (UIView *view in self.youtubePlayer.subviews) {
        if (![view isKindOfClass:UIWebView.class]) {
            [view removeFromSuperview];
        }
    }
   
//  reload table view and scroll to top if you're not in tableview
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.suggestedVideosTableView reloadData];
        [self.suggestedVideosTableView layoutIfNeeded];
        if (!self.isPlayingFromPlaylist) {
            [self.suggestedVideosTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.suggestedVideos indexOfObject:videoModel] inSection:1];
            [self.suggestedVideosTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [self.suggestedVideosTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }

    });
}

- (void)playNextButtonTap {
    self.timer = 6;
}

- (void)startAutoPlayAnimation {
    VideoModel *nextVideo = [self nextVideoModelForVideoModel:self.currentVideoModel];
    
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
    nextVideoLabel.text = [NSString stringWithFormat:@"Next: %@", nextVideo.title];
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
            [playNextButton removeFromSuperview];
            
        }
        self.timer += timer.timeInterval;
        circularProgressBar.value = self.timer;
        if (self.timer >= 5) {
            [timer invalidate];
            [self loadNextVideoWithVideoModel:nextVideo];
        }
    }] fire];

    
}

- (void)cancelButtonClicked {
    [self.autoPlaySwitch setOn:NO animated:YES];
}

#pragma mark Cells contents adding

- (void)addVideoTitleInCell:(UITableViewCell *)cell {
    if (!self.videoTitle) {
        self.videoTitle = [[CBAutoScrollLabel alloc] init];
        self.videoTitle.scrollSpeed = 15;
        self.videoTitle.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:self.videoTitle];
    }
    self.videoTitle.text = self.currentVideoModel.title;
    self.videoTitle.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cell.frame.size.height);
}

- (void)addVideoViewsAndAutoPlaySwitchInCell:(UITableViewCell *)cell {
    if (!self.autoPlaySwitch && !self.videoViewsLabel) {
        self.videoViewsLabel = [[UILabel alloc] init];
        
        [cell.contentView addSubview:self.videoViewsLabel];
        
        self.autoPlaySwitch = [[UISwitch alloc] init];
        self.autoPlaySwitch.on = YES;
        [self.autoPlaySwitch addTarget:self action:@selector(autoPlaySwitchTap:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:self.autoPlaySwitch];
    }
    if (!self.autoPlayLabel) {
        self.autoPlayLabel = [[UILabel alloc] init];
        self.autoPlayLabel.text = @"Autoplay";
        [cell.contentView addSubview:self.autoPlayLabel];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    numberFormatter.groupingSeparator = groupingSeparator;
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    self.videoViewsLabel.text = [[numberFormatter stringFromNumber:[numberFormatter numberFromString:self.currentVideoModel.videoViews]] stringByAppendingString:@" views"];
    
    self.videoViewsLabel.frame = CGRectMake(cell.frame.origin.x + 10, 15, self.view.frame.size.width / 2 - 30, 20);
    self.autoPlaySwitch.frame = CGRectMake(self.view.frame.size.width - 60, 10, 50, 20);
    self.autoPlayLabel.frame = CGRectMake(self.autoPlaySwitch.frame.origin.x - 90, 15, 90, 20);
}

- (void)addVideoDescriptionInCell:(UITableViewCell *)cell {
    
    if (!self.videoDescription && !self.expandTextViewButton) {
        self.videoDescription = [[UITextView alloc] init];
        self.videoDescription.editable = NO;
        self.videoDescription.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:self.videoDescription];
        
        self.expandTextViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.expandTextViewButton setImage:[UIImage imageNamed:@"expand_more_icon"] forState:UIControlStateNormal];
        [self.expandTextViewButton addTarget:self action:@selector(expandButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:self.expandTextViewButton];
    }
    self.videoDescription.text = self.currentVideoModel.entityDescription;
    if ([self.videoDescription.text isEqualToString:@""]) {
        self.videoDescription.text = @"No description.";
    }
    self.videoDescription.frame = cell.contentView.frame;
    self.expandTextViewButton.frame = CGRectMake(self.videoDescription.frame.size.width - 20, self.videoDescription.frame.size.height - 20, 20, 20);
}

- (void)addDownloadButtonInCell:(UITableViewCell *)cell {
    
    if (!self.downloadButtonWebView && !self.downloadFinishedLabel) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.allowsInlineMediaPlayback = NO;
        self.downloadButtonWebView = [[DownloadButtonWebView alloc] initWithFrame:cell.contentView.frame configuration:configuration];
        self.downloadButtonWebView.hidden = NO;
        [self.downloadFinishedLabel removeFromSuperview];
        self.downloadButtonWebView.navigationDelegate = self.downloadButtonWebView;
        [cell.contentView addSubview:self.downloadButtonWebView];
    }
    [self loadRequestForDownloadButton];
    self.downloadButtonWebView.frame = cell.contentView.frame;
}

- (void)loadRequestForDownloadButton {
    NSURLQueryItem *idItem = [NSURLQueryItem queryItemWithName:@"id" value:self.currentVideoModel.entityId];
    NSURL *buttonURL = [[NSURL URLWithString:DOWNLOAD_BUTTON_URL_PREFIX] URLByAppendingQueryItems:@[idItem]];
    [self.downloadButtonWebView loadRequest:[NSURLRequest requestWithURL:buttonURL]];
    self.downloadButtonWebView.videoModel = self.currentVideoModel;
}

- (void)updateMPNowPlayingInfoCenterWithLoadedSongInfoAndPlaybackRate:(double)playbackRate {
    if ([MPNowPlayingInfoCenter class])  {
        
        if (playbackRate == 1) {
            [MPNowPlayingInfoCenter.defaultCenter setPlaybackState:MPNowPlayingPlaybackStatePlaying];
        }
        else {
            [MPNowPlayingInfoCenter.defaultCenter setPlaybackState:MPNowPlayingPlaybackStatePaused];
        }
        
        NSNumber *elapsedTime = [NSNumber numberWithFloat:self.youtubePlayer.currentTime];
        NSNumber *duration = [NSNumber numberWithDouble:self.youtubePlayer.duration];
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(50, 50) requestHandler:^UIImage * _Nonnull(CGSize size) {
            
            UIImage *image;
            image = [ImageCacher.sharedInstance imageForSearchResultId:self.currentVideoModel.entityId];

            if (!image) {
                ThumbnailModel *thumbnail = [self.currentVideoModel.thumbnails objectForKey:@"high"];
                image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:thumbnail.url]];
            }

            return image;
        }];
        NSDictionary *info = @{ MPMediaItemPropertyArtist: self.currentVideoModel.channelTitle,
                                MPMediaItemPropertyTitle: self.currentVideoModel.title,
                                MPMediaItemPropertyPlaybackDuration: duration,
                                MPMediaItemPropertyArtwork: artwork,
                                MPNowPlayingInfoPropertyPlaybackRate: [NSNumber numberWithDouble:playbackRate],
                                MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
                                };
        [MPNowPlayingInfoCenter.defaultCenter setNowPlayingInfo:info];
        
    }
}

- (void)expandButtonClicked:(UIButton *)sender {
    [self.suggestedVideosTableView beginUpdates];
    double heightBeforeChange = self.descriptionHeight;
    if (self.descriptionHeight == 150) {
        self.descriptionHeight = 50;
        [self.expandTextViewButton setImage:[UIImage imageNamed:@"expand_more_icon"] forState:UIControlStateNormal];

    }
    else {
        self.descriptionHeight = 150;
        [self.expandTextViewButton setImage:[UIImage imageNamed:@"expand_less_icon"] forState:UIControlStateNormal];

    }
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:0
                     animations:^{
                         self.videoDescription.frame = CGRectMake(self.videoDescription.frame.origin.x, self.videoDescription.frame.origin.y, self.videoDescription.frame.size.width, (self.videoDescription.frame.size.height + self.descriptionHeight - heightBeforeChange));
                         self.expandTextViewButton.frame = CGRectMake(self.videoDescription.frame.size.width - 20, self.videoDescription.frame.size.height - 20, 20, 20);
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [self.suggestedVideosTableView endUpdates];

}

- (VideoModel *)nextVideoModelForVideoModel:(VideoModel *)videoModel {
    if (!self.isPlayingFromPlaylist) {
        return self.suggestedVideos.firstObject;
    }
    NSInteger index = [self.suggestedVideos indexOfObject:videoModel];
    if (++index < self.suggestedVideos.count) {
        return self.suggestedVideos[index];
    }
    else return self.suggestedVideos.firstObject;
}

- (VideoModel *)previousVideoModelForVideoModel:(VideoModel *)videoModel {
    NSInteger index = [self.suggestedVideos indexOfObject:videoModel];
    if (--index >= 0) {
        return self.suggestedVideos[index];
    }
    else {
        return self.suggestedVideos.lastObject;
    }
}

- (void)addVideoToFavourites {
    NSString *username = [NSUserDefaults.standardUserDefaults valueForKey:@"loggedUsername"];
    if (![username isEqualToString:@""]) {
        DataBase *db = [[DataBase alloc] init];
        [db addFavouriteVideo:self.currentVideoModel ForUsername:username];
        [Toast displayStandardToastWithMessage:@"Video added to favourites!"];
    }
}

- (void)reloadVCWithNewYoutubePlaylist:(YoutubePlaylistModel *)playlist {
    self.youtubePlaylist = playlist;
    [self reloadView];
    [self.suggestedVideosTableView reloadData];
}

@end
