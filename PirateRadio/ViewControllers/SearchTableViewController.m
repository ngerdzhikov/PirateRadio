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

@property (strong, nonatomic) NSMutableDictionary<NSString *, VideoModel *> *videoModelsDict;
@property (strong, nonatomic) NSMutableArray<VideoModel *> *videoModelsArray;
@property (strong, nonatomic) SearchSuggestionsTableViewController *searchSuggestionsTable;
@property (strong, nonatomic) DGActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSString *nextPageToken;
@property BOOL isNextPageEnabled;

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
    self.isNextPageEnabled = NO;
    self.searchSuggestions = [[NSMutableArray alloc] init];
    self.videoModelsDict = [[NSMutableDictionary alloc] init];
    self.videoModelsArray = [[NSMutableArray alloc] init];
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
    return self.videoModelsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 255.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
    VideoModel *videoModel = self.videoModelsArray[indexPath.row];
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
    YoutubePlayerViewController *youtubePlayer = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YoutubePlayerViewController"];
    youtubePlayer.videoModel = self.videoModelsArray[indexPath.row];
    [self.navigationController pushViewController:youtubePlayer animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.videoModelsArray.count - 1 && self.isNextPageEnabled) {
        [self searchWithNextPageToken:self.nextPageToken];
    }
}

#pragma mark Animation

- (void)startAnimation {
    self.isNextPageEnabled = NO;
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurEffectView.frame = self.navigationController.view.bounds;
        [self.view addSubview:self.blurEffectView];
    }
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeFiveDots];
    self.activityIndicatorView.tintColor = [UIColor blackColor];
    self.activityIndicatorView.frame = CGRectMake((self.tableView.frame.origin.x - self.activityIndicatorView.frame.size.width) / 2, self.tableView.frame.origin.y / 2, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.navigationController.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}


- (void)stopAnimation {
    self.isNextPageEnabled = YES;
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    [self.blurEffectView removeFromSuperview];
}

#pragma mark HistoryAndSearchBarDelegate

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

#pragma mark Searching

- (void)makeSearchWithString:(NSString *)string {
    if (![string isEqualToString:@""]) {
        [self startAnimation];
        NSArray<NSString *> *keywords = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.videoModelsDict = [[NSMutableDictionary alloc] init];
        self.videoModelsArray = [[NSMutableArray alloc] init];
        [self.videoModelsArray removeAllObjects];
        [self makeSearchWithKeywords:keywords];
    }
    self.searchBar.text = string;
    [self.searchBar resignFirstResponder];
    [self manageSearchHistory];
    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void) makeSearchWithKeywords:(NSArray<NSString *> *)keywords {
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
                self.nextPageToken = [responseDict objectForKey:@"nextPageToken"];
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
                        [self.videoModelsArray addObject:videoModel];
                        [self.videoModelsDict setObject:videoModel forKey:videoId];
                    }
                    [self makeSearchForVideoDurationsWithVideoModels:self.videoModelsArray];
                }
            }
        }
    }];
}

- (void)makeSearchForVideoDurationsWithVideoModels:(NSMutableArray<VideoModel *> *)videoModels {
    NSMutableArray<NSString *> *videoIds = [[NSMutableArray alloc] initWithArray:[videoModels valueForKey:@"videoId"]];
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
                for (NSDictionary *item in items) {
                    NSString *duration = [[item objectForKey:@"contentDetails"] objectForKey:@"duration"];
                    NSString *views = [[item objectForKey:@"statistics"] objectForKey:@"viewCount"];
                    NSString *videoId = [item objectForKey:@"id"];
                    self.videoModelsDict[videoId].videoDuration = duration;
                    self.videoModelsDict[videoId].videoViews = views;
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
                self.nextPageToken = [responseDict objectForKey:@"nextPageToken"];
                for (NSDictionary *item in items) {
                    NSString *videoId = [item objectForKey:@"id"];
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    VideoModel *videoModel = [[VideoModel alloc] initWithSnippet:snippet andVideoId:videoId];
                    NSString *duration = [[item objectForKey:@"contentDetails"] objectForKey:@"duration"];
                    NSString *views = [[item objectForKey:@"statistics"] objectForKey:@"viewCount"];
                    videoModel.videoDuration = duration;
                    videoModel.videoViews = views;
                    [self.videoModelsArray addObject:videoModel];
                    [self.videoModelsDict setObject:videoModel forKey:videoId];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopAnimation];
                    [self.tableView reloadData];
                });
            }
        }
    }];
}

- (void)searchWithNextPageToken:(NSString *)nextPageToken {
    [YoutubeConnectionManager makeSearchWithNextPageToken:nextPageToken andKeywords:[self.searchBar.text componentsSeparatedByString:@" "] andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                self.nextPageToken = [responseDict objectForKey:@"nextPageToken"];
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
                        [self.videoModelsArray addObject:videoModel];
                        [self.videoModelsDict setObject:videoModel forKey:videoId];
                    }
                    [self makeSearchForVideoDurationsWithVideoModels:self.videoModelsArray];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
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
