//
//  SavedMusicTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//


#import "SavedMusicViewController.h"
#import "SavedMusicTableViewCell.h"
#import "MusicControllerView.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>

#import "Constants.h"

#define PLAY 1
#define PAUSE 2

@interface SavedMusicViewController ()

@property (strong, nonatomic) NSMutableArray *mp3Files;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) IBOutlet MusicControllerView *musicControllerView;
@property (strong, nonatomic) NSIndexPath *indexPathOfLastTappedMediaPlaybackButton;

@end

@implementation SavedMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mp3Files = [[NSMutableArray alloc] init];
    self.player = [[AVPlayer alloc] init];
    
    [self loadAssetsForPlayer];
    [self configureMusicControllerView];
    
    __weak SavedMusicViewController *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateProgressBar];
    }];
}

- (void)updateProgressBar {
    double time = CMTimeGetSeconds(self.player.currentTime);
    double duration = CMTimeGetSeconds(self.player.currentItem.duration);
    [self.musicControllerView.songTimeProgress setProgress:(time/duration) animated:NO];
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathOfLastTappedMediaPlaybackButton];
    cell.circleProgressBar.value = time / duration * 100;
}

- (void)configureMusicControllerView {
    self.musicControllerView.songTimeProgress.progress = 0.0f;
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.2];
//    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
//                           forView:self.musicControllerView
//                             cache:YES];
    [self.musicControllerView setCenter:(CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 56))];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicControllerPan:)];
    [self.musicControllerView addGestureRecognizer:pan];
    [self.navigationController.view addSubview:self.musicControllerView];
    [self loadFirstItemForPlayerAtBeginning];
}

- (void)loadFirstItemForPlayerAtBeginning {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.mp3Files[0] options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.musicControllerView.songImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://ih1.redbubble.net/image.500263370.2910/flat,800x800,070,f.u2.jpg"]]];
    self.musicControllerView.songName.text = [[self.mp3Files[0] lastPathComponent] stringByDeletingPathExtension];
    [self.player replaceCurrentItemWithPlayerItem:item];
    self.indexPathOfLastTappedMediaPlaybackButton = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)loadAssetsForPlayer {
    NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSArray* dirs = [NSFileManager.defaultManager contentsOfDirectoryAtURL:sourcePath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"mp3"]) {
            [self.mp3Files addObject:filename];
        }
    }];
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
    return self.mp3Files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SavedMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    NSString *fileName = [[self.mp3Files[indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    cell.musicTitle.text = fileName;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPlayButtonTap:)];
    [cell.circleProgressBar addGestureRecognizer:tap];

    return cell;
}


- (void)cellPlayButtonTap:(UITapGestureRecognizer *)recognizer {
    
    CGPoint touchLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    AVURLAsset *assetToPlay = [[AVURLAsset alloc] initWithURL:self.mp3Files[indexPath.row] options:nil];
    AVPlayerItem *itemToPlay = [AVPlayerItem playerItemWithAsset:assetToPlay];
    
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([indexPath isEqual:self.indexPathOfLastTappedMediaPlaybackButton]) {
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil userInfo:@{@"cell" : cell}];
            [self.player pause];
            [self.musicControllerView.playButton setTitle:@"Play" forState:UIControlStateNormal];
        }
        else {
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : cell}];
            [self.player play];
            [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        }
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : cell}];
        [self.player replaceCurrentItemWithPlayerItem:itemToPlay];
        [self.player play];
        [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
        self.musicControllerView.songName.text = [[self.mp3Files[indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    }
    
    self.indexPathOfLastTappedMediaPlaybackButton = indexPath;
}


#pragma mark - music view button actions

- (IBAction)musicControllerPlayBtnTap:(id)sender {
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:self.indexPathOfLastTappedMediaPlaybackButton]}];
        [self.player pause];
        [self.musicControllerView.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:self.indexPathOfLastTappedMediaPlaybackButton]}];
        [self.player play];
        [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)previousBtnTap:(id)sender {
    NSIndexPath *indexPath;
    if ((self.indexPathOfLastTappedMediaPlaybackButton.row - 1) < 0) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:self.indexPathOfLastTappedMediaPlaybackButton.section];
        [self replacePlayerSongWithIndexPath:indexPath];
    }
    else {
        indexPath = [NSIndexPath indexPathForRow:(self.indexPathOfLastTappedMediaPlaybackButton.row - 1) inSection:self.indexPathOfLastTappedMediaPlaybackButton.section];
        [self replacePlayerSongWithIndexPath:indexPath];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:indexPath]}];
    self.indexPathOfLastTappedMediaPlaybackButton = indexPath;
}

- (IBAction)nextBtnTap:(id)sender {
    NSIndexPath *indexPath;
    if ((self.indexPathOfLastTappedMediaPlaybackButton.row + 1) >= self.mp3Files.count) {
        indexPath = [NSIndexPath indexPathForRow:(self.mp3Files.count - 1) inSection:self.indexPathOfLastTappedMediaPlaybackButton.section];
        [self replacePlayerSongWithIndexPath:indexPath];
    }
    else {
        indexPath = [NSIndexPath indexPathForRow:(self.indexPathOfLastTappedMediaPlaybackButton.row + 1) inSection:self.indexPathOfLastTappedMediaPlaybackButton.section];
        [self replacePlayerSongWithIndexPath:indexPath];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:indexPath]}];
    self.indexPathOfLastTappedMediaPlaybackButton = indexPath;
}


- (void)onMusicControllerPan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityY = (0.2*[recognizer velocityInView:self.view].y);
        CGPoint translatedPoint = [recognizer translationInView:recognizer.view.superview];
        CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        if (translatedPoint.y < -100) {
            [recognizer.view setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-0.5*self.musicControllerView.frame.size.height)];
        }
        if (translatedPoint.y > 100) {
            [recognizer.view setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height+56)];
        }
        [UIView commitAnimations];
    }
}

- (void)replacePlayerSongWithIndexPath:(NSIndexPath *)indexPath {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.mp3Files[indexPath.row] options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    self.musicControllerView.songImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://ih1.redbubble.net/image.500263370.2910/flat,800x800,070,f.u2.jpg"]]];
    self.musicControllerView.songName.text = [[self.mp3Files[indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
    [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    self.indexPathOfLastTappedMediaPlaybackButton = indexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath != self.indexPathOfLastTappedMediaPlaybackButton){
            NSError *error;
            [NSFileManager.defaultManager removeItemAtURL:self.mp3Files[indexPath.row] error:&error];
            if (error) {
                NSLog(@"Error deleting file from url = %@", error);
            }
            else {
                [self.mp3Files removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            }
        }
        else {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            [alertController setMessage:@"You can't delete a song that is currently playing."];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Okay!" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.musicControllerView removeFromSuperview];
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
