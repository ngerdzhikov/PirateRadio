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


@interface SavedMusicViewController ()

@property (strong, nonatomic) NSMutableArray *mp3Files;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) IBOutlet MusicControllerView *musicControllerView;
@property (strong, nonatomic) NSIndexPath *indexOfPlayingSong;

@property BOOL isPlayerPlaying;

@end

@implementation SavedMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp3Files = [[NSMutableArray alloc] init];
    self.player = [[AVPlayer alloc] init];
    [self loadAssetsForPlayer];
    self.musicControllerView.songTimeProgress.progress = 0.5f;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    __weak SavedMusicViewController *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateProgressBar];
    }];
}

- (void)updateProgressBar {
    double time = CMTimeGetSeconds(self.player.currentTime);
    double duration = CMTimeGetSeconds(self.player.currentItem.duration);
    [self.musicControllerView.songTimeProgress setProgress:(time/duration) animated:YES];
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexOfPlayingSong];
    MBCircularProgressBarView *progressView = (MBCircularProgressBarView*)cell.progressPlaceHolderView.subviews[0];
    progressView.value = time/duration*100;
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
    MBCircularProgressBarView *circleProgressBar = [self createCircularProgressBarWithFrame:cell.progressPlaceHolderView.bounds];
    circleProgressBar.tag = indexPath.row;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPlayButtonTap:)];
    [circleProgressBar addGestureRecognizer:tap];
    [cell.progressPlaceHolderView addSubview:circleProgressBar];
    
    return cell;
}

- (MBCircularProgressBarView *) createCircularProgressBarWithFrame:(CGRect) frame {
    MBCircularProgressBarView *circleProgressBar = [[MBCircularProgressBarView alloc] initWithFrame:frame];
    circleProgressBar.backgroundColor = [UIColor clearColor];
    circleProgressBar.progressColor = [UIColor blueColor];
    circleProgressBar.progressStrokeColor = [UIColor blueColor];
    circleProgressBar.emptyLineColor = [UIColor clearColor];
    circleProgressBar.emptyLineStrokeColor = [UIColor clearColor];
    circleProgressBar.progressLineWidth = 3;
    circleProgressBar.showValueString = YES;
    circleProgressBar.showUnitString = YES;
    circleProgressBar.value = 0;
    circleProgressBar.unitString = @"c";
    circleProgressBar.unitFontSize = 15;
    circleProgressBar.valueFontName = @"Icons South St";
    circleProgressBar.unitFontName = @"Icons South St";
    return circleProgressBar;
}

- (void)cellPlayButtonTap:(UITapGestureRecognizer *)recognizer {
    NSInteger index = recognizer.view.tag;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.mp3Files[index] options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    
    if (self.isPlayerPlaying) {
        if (![((AVURLAsset*)self.player.currentItem.asset).URL isEqual:asset.URL]) {
            [self.player replaceCurrentItemWithPlayerItem:item];
            self.musicControllerView.songName.text = [[self.mp3Files[index] lastPathComponent] stringByDeletingPathExtension];
            [self clearCurrentCellProgress];
            self.indexOfPlayingSong = [NSIndexPath indexPathForRow:index inSection:0];
            self.isPlayerPlaying = YES;
            [self setPlayOrPauseButtonForCurrentCell:NO];
        }
        else {
            [self.player pause];
            self.isPlayerPlaying = NO;
            [self setPlayOrPauseButtonForCurrentCell:YES];
        }
    }
    else {
        if (![((AVURLAsset*)self.player.currentItem.asset).URL isEqual:asset.URL]) {
            [self.player replaceCurrentItemWithPlayerItem:item];
            self.musicControllerView.songName.text = [[self.mp3Files[index] lastPathComponent] stringByDeletingPathExtension];
            [self clearCurrentCellProgress];
            self.indexOfPlayingSong = [NSIndexPath indexPathForRow:index inSection:0];
            [self.player play];
            self.isPlayerPlaying = YES;
        }
        else {
            [self.player play];
            self.isPlayerPlaying = YES;
        }
        [self setPlayOrPauseButtonForCurrentCell:NO];
    }
}

- (void)clearCurrentCellProgress {
    if (self.indexOfPlayingSong) {
        SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexOfPlayingSong];
        MBCircularProgressBarView *progressView = cell.progressPlaceHolderView.subviews[0];
        progressView.value = 0;
        progressView.unitString = @"c";
    }
}

- (void)setPlayOrPauseButtonForCurrentCell:(BOOL) play {
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexOfPlayingSong];
    MBCircularProgressBarView *progressView = cell.progressPlaceHolderView.subviews[0];
    if (play) {
        progressView.unitString = @"c";
    }
    else {
        progressView.unitString = @"d";
    }
}

#pragma mark - music view button actions

- (IBAction)musicControllerPlayBtnTap:(id)sender {
    if (self.isPlayerPlaying) {
        [self.player pause];
        self.isPlayerPlaying = NO;
        [self.musicControllerView.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else {
        [self.player play];
        self.isPlayerPlaying = YES;
        [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)previousBtnTap:(id)sender {
//    NSInteger index = [self.mp3Files indexOfObject:self.player.currentItem.asset];
//    AVURLAsset *asset = [AVURLAsset alloc] initWithURL:self.mp3Files[index-1] options:<#(nullable NSDictionary<NSString *,id> *)#>
}

- (IBAction)nextBtnTap:(id)sender {
    
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
