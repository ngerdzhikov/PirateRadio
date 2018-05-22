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
#import "ImageCacher.h"

@interface SearchTableViewController ()

@property (strong, nonatomic) NSMutableArray<VideoModel *> *videoModels;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    //[self.navigationController pushViewController:youtubePlayer animated:YES];
    youtubePlayer.videoModel = self.videoModels[indexPath.row];
    [self.navigationController pushViewController:youtubePlayer animated:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText = searchBar.text;
    if (![searchText isEqualToString:@""]) {
        NSArray<NSString *> *keywords = [searchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self makeSearchWithKeywords:keywords];
    }
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
                for (NSDictionary *item in items) {
                    NSString *videoId = [[item objectForKey:@"id"] objectForKey:@"videoId"];
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    VideoModel *videoModel = [[VideoModel alloc] initWithSnippet:snippet andVideoId:videoId];
                    [self.videoModels addObject:videoModel];
                }
                [self makeSearchForVideoDurationsWithVideoModels:self.videoModels];
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
                    self.videoModels[i].videoDuration = duration;
                    i++;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.videoModels.count) {
        
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
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
