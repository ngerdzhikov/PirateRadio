//
//  ProfileViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ProfileViewController.h"
#import <CoreData/CoreData.h>
#import "VideoModel.h"
#import "FavouriteVideoTableViewCell.h"
#import "LoginViewController.h"
#import "DataBase.h"
#import "ThumbnailModel.h"
#import "YoutubePlaylistModel.h"
#import "YoutubePlayerViewController.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *favouriteVideosLabel;
@property (weak, nonatomic) IBOutlet UITableView *favouriteVideosTableView;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) NSArray<VideoModel *> *favouriteVideos;
@property (strong, nonatomic) NSString *username;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.favouriteVideosTableView.delegate = self;
    self.favouriteVideosTableView.dataSource = self;
    
    BOOL isLogged = [NSUserDefaults.standardUserDefaults boolForKey:@"isLogged"];
    if (!isLogged) {
        LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [loginVC setModalPresentationStyle:UIModalPresentationCurrentContext];
        [self presentViewController:loginVC animated:YES completion:^{
            
        }];
    }
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onCellLongPress:)];
    [self.favouriteVideosTableView addGestureRecognizer:longPressRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DataBase *db = [[DataBase alloc] init];
    self.username = [NSUserDefaults.standardUserDefaults valueForKey:@"loggedUsername"];
    self.usernameLabel.text = [NSString stringWithFormat:@"Hello %@!", self.username];
    self.favouriteVideos = [[NSArray alloc] initWithArray:[db favouriteVideosForUsername:self.username]];
    [self.favouriteVideosTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutButtonTap:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isLogged"];
    [NSUserDefaults.standardUserDefaults setValue:@"" forKey:@"loggedUsername"];
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [loginVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];
}

#pragma mark - Table view data source

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
        [db deleteFavouriteVideo:video ForUsername:self.username];
        
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
        CGPoint touchPoint = [recognizer locationInView:self.favouriteVideosTableView];
        NSIndexPath *indexPath = [self.favouriteVideosTableView indexPathForRowAtPoint:touchPoint];
        VideoModel *video = self.favouriteVideos[indexPath.row];
        
        NSString *strURL = [@"https://www.youtube.com/watch?v=" stringByAppendingString:video.entityId];
        
        NSURL *videoURL = [NSURL URLWithString:strURL];
        
        [UIPasteboard generalPasteboard].string = videoURL.absoluteString;
        NSLog(@"URL copied");
    }
}


@end
