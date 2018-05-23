//
//  SearchTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SearchTableViewController.h"
#import "YoutubeConnectionManager.h"
#import "SearchResultTableViewCell.h"
#import "VideoModel.h"
#import "ThumbnailModel.h"
#import "YoutubePlayerViewController.h"
#import "SearchSuggestionsTableViewController.h"
#import "ImageCacher.h"
#import "DGActivityIndicatorView.h"

@interface SearchTableViewController ()<UISearchBarDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) NSMutableArray<VideoModel *> *videoModels;
@property (strong, nonatomic) SearchSuggestionsTableViewController *searchSuggestionsTable;
@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) UISearchBar *searchBar;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.navigationItem.searchController = searchController;
    self.searchBar = self.navigationItem.searchController.searchBar;
    self.searchBar.delegate = self;
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(displaySearchBar)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    self.searchHistory = [[NSUserDefaults.standardUserDefaults objectForKey:@"searchHistory"] mutableCopy];
    if (!self.searchHistory) {
        self.searchHistory = [[NSMutableArray alloc] init];
    }
    self.searchSuggestions = [[NSMutableArray alloc] init];
    self.tableView.showsVerticalScrollIndicator = YES;
    [self makeSearchForMostPopularVideos];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 255.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    VideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    UIImage *thumbnail = [ImageCacher.sharedInstance imageForVideoId:videoModel.videoId];
    if (!thumbnail) {
        thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[videoModel.thumbnails objectForKey:@"high"].url]];
    }
    cell.videoImage.image = thumbnail;
    cell.videoTitle.text = videoModel.videoTitle;
    cell.channelTitle.text = videoModel.channelTitle;
    cell.views.text = videoModel.videoViews;
    NSString *duration;
    if ([videoModel.videoDuration containsString:@"M"]) {
        NSArray<NSString *> *components = [videoModel.videoDuration componentsSeparatedByString:@"M"];
        duration = [components[0] substringFromIndex:2];
        duration = [duration stringByAppendingString:@":"];
        duration = [duration stringByAppendingString:[components[1] substringToIndex:components[1].length]];
    }
    else {
        NSArray<NSString *> *components = [videoModel.videoDuration componentsSeparatedByString:@"S"];
        duration = [components[0] substringFromIndex:2];
    }
    
    cell.duration.text = duration;
    NSArray<NSString *> *dateArr = [videoModel.publishedAt componentsSeparatedByString:@"-"];
    NSString *dateString = [dateArr[2] substringToIndex:2];
    dateString = [dateString stringByAppendingString:@"."];
    dateString = [dateString stringByAppendingString:dateArr[1]];
    dateString = [dateString stringByAppendingString:@"."];
    dateString = [dateString stringByAppendingString:dateArr[0]];
    cell.dateUploaded.text = dateString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YoutubePlayerViewController *youtubePlayer = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YoutubePlayerViewController"];
    youtubePlayer.videoModel = self.videoModels[indexPath.row];
    [self.navigationController pushViewController:youtubePlayer animated:YES];
}

- (void)startAnimation {
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
//        self.view.backgroundColor = [UIColor whiteColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView.frame = self.navigationController.view.bounds;
//        self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:self.blurEffectView];
    }
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeFiveDots];
    self.activityIndicatorView.tintColor = [UIColor blackColor];
    self.activityIndicatorView.frame = CGRectMake((self.tableView.frame.origin.x - self.activityIndicatorView.frame.size.width) / 2, self.tableView.frame.origin.y / 2, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.navigationController.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}


- (void)stopAnimation {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    [self.blurEffectView removeFromSuperview];
}

- (void)makeSearchWithString:(NSString *)string {
    if (![string isEqualToString:@""]) {
        [self startAnimation];
        NSArray<NSString *> *keywords = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self makeSearchWithKeywords:keywords];
    }
    self.searchBar.text = string;
    [self.searchBar resignFirstResponder];
    [self manageSearchHistory];
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)manageSearchHistory {
    if ([self.searchHistory containsObject:self.searchBar.text]) {
        [self.searchHistory removeObject:self.searchBar.text];
    }
    [self.searchHistory insertObject:self.searchBar.text atIndex:0];
}

- (void)displaySearchBar {
    self.navigationItem.hidesSearchBarWhenScrolling = !self.navigationItem.hidesSearchBarWhenScrolling;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self makeSearchWithString:searchBar.text];
    [self.searchBar resignFirstResponder];
}

- (void) makeSearchWithKeywords:(NSArray<NSString *> *)keywords {
    self.videoModels = [[NSMutableArray alloc] init];
    [YoutubeConnectionManager makeYoutubeSearchRequestWithKeywords:keywords andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error = %@", error.localizedDescription);
        }
        else {
            NSError *serializationError;
            NSDictionary<NSString *, id> *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                NSLog(@"Error = %@", serializationError.localizedDescription);
            }
            else {
                NSArray *items = [responseDict objectForKey:@"items"];
                if (items.count == 0) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"WTF" message:@"What the hell are you trying to find? Please use normal keywords (e.g. Azis, Mile Kitic etc)." preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alertController animated:YES completion:^{
                        [self stopAnimation];
                    }];
                }
                else {
                    for (NSDictionary *item in items) {
                        NSString *videoId = [[item objectForKey:@"id"] objectForKey:@"videoId"];
                        NSDictionary *snippet = [item objectForKey:@"snippet"];
                        VideoModel *videoModel = [[VideoModel alloc] initWithSnippet:snippet andVideoId:videoId];
                        [self.videoModels addObject:videoModel];
                    }
                    [self makeSearchForVideoDurationsWithVideoModels:self.videoModels];
                }
            }
        }
    }];
}

- (void)makeSearchForVideoDurationsWithVideoModels:(NSArray<VideoModel *> *)videoModels {
    NSMutableArray<NSString *> *videoIds = [[NSMutableArray alloc] init];
    for (VideoModel *video in videoModels) {
        [videoIds addObject:video.videoId];
    }
    [YoutubeConnectionManager makeYoutubeRequestForVideoDurationsWithVideoIds:[videoIds copy] andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error searching for video durations = %@", error);
        }
        else {
            NSError *serializationError;
            NSDictionary<NSString *, id> *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            if (serializationError) {
                NSLog(@"Error = %@", serializationError.localizedDescription);
            }
            else {
                NSArray *items = [responseDict objectForKey:@"items"];
                int i = 0;
                for (NSDictionary *item in items) {
                    NSString *duration = [[item objectForKey:@"contentDetails"] objectForKey:@"duration"];
                    NSString *views = [[item objectForKey:@"statistics"] objectForKey:@"viewCount"];
                    self.videoModels[i].videoDuration = duration;
                    self.videoModels[i].videoViews = views;
                    i++;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopAnimation];
            [self.tableView reloadData];
        });
    }];
}

- (void)makeSearchForMostPopularVideos {
    [self startAnimation];
    self.videoModels = [[NSMutableArray alloc] init];
    [YoutubeConnectionManager makeYoutubeRequestForMostPopularVideosWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error = %@", error.localizedDescription);
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
                    NSString *videoId = [item objectForKey:@"id"];
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    VideoModel *videoModel = [[VideoModel alloc] initWithSnippet:snippet andVideoId:videoId];
                    NSString *duration = [[item objectForKey:@"contentDetails"] objectForKey:@"duration"];
                    NSString *views = [[item objectForKey:@"statistics"] objectForKey:@"viewCount"];
                    videoModel.videoDuration = duration;
                    videoModel.videoViews = views;
                    [self.videoModels addObject:videoModel];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)presentSearchSuggestoinsTableView {
    self.searchSuggestionsTable = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchSuggestionsTableViewController"];
    self.searchSuggestionsTable.delegate = self;
    self.searchSuggestionsTable.modalPresentationStyle = UIModalPresentationPopover;
    self.searchSuggestionsTable.popoverPresentationController.sourceView = self.searchBar;
    self.searchSuggestionsTable.popoverPresentationController.sourceRect = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y, self.searchBar.frame.size.width, self.searchBar.frame.size.height);
    self.searchSuggestionsTable.popoverPresentationController.delegate = self;
    [self presentViewController:self.searchSuggestionsTable animated:YES completion:nil];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self presentSearchSuggestoinsTableView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [YoutubeConnectionManager makeSuggestionsSearchWithPrefix:searchText andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *serializationError;
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
        if (serializationError) {
            NSLog(@"serializationError = %@", serializationError);
            [self.searchSuggestions removeAllObjects];
        }
        else {
            [self.searchSuggestions removeAllObjects];
            for (NSString *suggestion in responseArray[1]) {
                [self.searchSuggestions addObject:suggestion];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchSuggestionsTable.tableView reloadData];
        });
    }];
}



- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


- (void)viewWillDisappear:(BOOL)animated {
    [NSUserDefaults.standardUserDefaults setObject:self.searchHistory forKey:@"searchHistory"];
    [NSUserDefaults.standardUserDefaults synchronize];
}


- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    [self.searchBar resignFirstResponder];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
