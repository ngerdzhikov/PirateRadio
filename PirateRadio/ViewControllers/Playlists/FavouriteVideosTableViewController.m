//
//  FavouriteVideosTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 5.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "FavouriteVideosTableViewController.h"
#import "VideoModel.h"
#import "ThumbnailModel.h"
#import "FavouriteVideoTableViewCell.h"
#import "YoutubePlaylistModel.h"
#import "YoutubePlayerViewController.h"
#import "UIView+Toast.h"
#import "Constants.h"
#import "UserModel.h"
#import "DataBase.h"

@interface FavouriteVideosTableViewController ()

@property (strong, nonatomic) NSArray<VideoModel *> *favouriteVideos;
@property (strong, nonatomic) UserModel *userModel;

@end

@implementation FavouriteVideosTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onCellLongPress:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DataBase *db = [[DataBase alloc] init];
    self.userModel = [db userModelForUsername:[NSUserDefaults.standardUserDefaults objectForKey:USER_DEFAULTS_LOGGED_USERNAME]];
    self.favouriteVideos = [[NSArray alloc] initWithArray:[db favouriteVideosForUsername:self.userModel.username]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favouriteVideos.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FavouriteVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavouriteVideoCell" forIndexPath:indexPath];
    VideoModel *video = self.favouriteVideos[indexPath.row];
    ThumbnailModel *thumbnail = [video.thumbnails objectForKey:@"high"];
    NSURL *imageURL = thumbnail.url;
    cell.videoThumbnail.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    
    cell.videoTitle.text = video.title;
    cell.channelTitle.text = video.channelTitle;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSString *groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    numberFormatter.groupingSeparator = groupingSeparator;
    numberFormatter.groupingSize = 3;
    numberFormatter.alwaysShowsDecimalSeparator = NO;
    numberFormatter.usesGroupingSeparator = YES;
    
    if ([video.videoDuration isEqualToString:@"PT0S"]) {
        cell.videoDuration.text = @"Live";
    }
    else {
        cell.videoDuration.text = video.formattedDuration;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoModel *video = self.favouriteVideos[indexPath.row];
    [self.tabBarController setSelectedIndex:0];
    YoutubePlaylistModel *playlist = [[YoutubePlaylistModel alloc] initWithVideoModel:video];
    YoutubePlayerViewController *youtubeVC;
    if (self.tabBarController.selectedViewController.childViewControllers.count > 1) {
        youtubeVC = (YoutubePlayerViewController *)self.tabBarController.selectedViewController.childViewControllers[1];
        [youtubeVC reloadVCWithNewYoutubePlaylist:playlist];
    }
    else {
        youtubeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YoutubePlayerViewController"];
        youtubeVC.youtubePlaylist = playlist;
        [self.tabBarController.selectedViewController pushViewController:youtubeVC animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        VideoModel *video = self.favouriteVideos[indexPath.row];
        NSMutableArray *mutableCopy = self.favouriteVideos.mutableCopy;
        [mutableCopy removeObjectAtIndex:indexPath.row];
        self.favouriteVideos = [NSArray arrayWithArray:mutableCopy];
        
        DataBase *db = [[DataBase alloc] init];
        [db deleteFavouriteVideo:video ForUsername:self.userModel.username];
        
        [tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)onCellLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
        
        if (indexPath) {
            VideoModel *video = self.favouriteVideos[indexPath.row];
            
            NSString *strURL = [@"https://www.youtube.com/watch?v=" stringByAppendingString:video.entityId];
            
            NSURL *videoURL = [NSURL URLWithString:strURL];
            
            [UIPasteboard generalPasteboard].string = videoURL.absoluteString;
            
            UIWindow *window=[UIApplication sharedApplication].keyWindow;
            [window.rootViewController.view makeToast:@"Video url copied!"];
        }
        
    }
}


@end
