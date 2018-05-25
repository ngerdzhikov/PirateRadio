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
#import "LocalSongModel.h"

@interface SavedMusicViewController ()

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *songs;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) IBOutlet MusicControllerView *musicControllerView;
@property (strong, nonatomic) NSIndexPath *indexPathOfLastPlayedSong;
@property BOOL isSeekInProgress;
@property BOOL isSliding;
@property CMTime chaseTime;
@property AVPlayerStatus playerCurrentItemStatus; // your player.currentItem.status

@end

@implementation SavedMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[AVPlayer alloc] init];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playButtonTap:) name:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(pauseButtonTap:) name:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil];
    
    [self loadSongsFromDisk];
    [self.navigationController.view addSubview:self.musicControllerView];
    
    __weak SavedMusicViewController *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateProgressBar];
    }];
}

- (void)updateProgressBar {
    if (!self.isSliding) {
        double time = CMTimeGetSeconds(self.player.currentTime);
        double duration = CMTimeGetSeconds(self.player.currentItem.duration);
        self.musicControllerView.songTimeProgress.value = time;
        SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathOfLastPlayedSong];
        cell.circleProgressBar.value = time / duration * 100;
        if (cell.circleProgressBar.value >= 10) {
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_VALUE_CHANGED object:cell.circleProgressBar userInfo:[NSDictionary dictionaryWithObject:cell.circleProgressBar forKey:@"progressBar"]];
        }
    }
}

- (void)configureMusicControllerView {
    [self.musicControllerView.songTimeProgress addTarget:self action:@selector(sliderIsSliding) forControlEvents:UIControlEventValueChanged];
    [self.musicControllerView.songTimeProgress addTarget:self action:@selector(sliderEndedSliding) forControlEvents:UIControlEventTouchUpInside];
    self.musicControllerView.songTimeProgress.value = 0.0f;
    self.musicControllerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.musicControllerView.frame.size.height);
    [self.musicControllerView setCenter:(CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height + 65)))];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicControllerPan:)];
    [self.musicControllerView addGestureRecognizer:pan];
    
}

- (void)loadFirstItemForPlayerAtBeginning {
    self.indexPathOfLastPlayedSong = [NSIndexPath indexPathForRow:0 inSection:0];
    [self replacePlayerSongWithSongAtIndexPath:self.indexPathOfLastPlayedSong];
    [self setMusicPlayerSongNameAndImage];
}

- (void)loadSongsFromDisk {
    self.songs = [[NSMutableArray alloc] init];
    NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    sourcePath = [sourcePath URLByAppendingPathComponent:@"songs"];
    NSArray* dirs = [NSFileManager.defaultManager contentsOfDirectoryAtURL:sourcePath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filePath = ((NSURL *)obj).absoluteString;
        NSString *extension = [[filePath pathExtension] lowercaseString];
        if ([extension isEqualToString:@"mp3"]) {
            LocalSongModel *localSong = [[LocalSongModel alloc] initWithLocalSongURL:[NSURL URLWithString:filePath]];
            [self.songs addObject:localSong];
        }
    }];
    if (self.songs.count > 0) {
        [self loadFirstItemForPlayerAtBeginning];
    }
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
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SavedMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    LocalSongModel *song = self.songs[indexPath.row];
    if ([song.artistName isEqualToString:@"Uknown artist"]) {
        cell.musicTitle.text = song.songTitle;
    }
    else {
        cell.musicTitle.text = [[song.artistName stringByAppendingString:@" - "] stringByAppendingString:song.songTitle];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPlayButtonTap:)];
    [cell.circleProgressBar addGestureRecognizer:tap];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    LocalSongModel *song = self.songs[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath != self.indexPathOfLastPlayedSong){
            NSError *error;
            [NSFileManager.defaultManager removeItemAtURL:song.localSongURL error:&error];
            [NSFileManager.defaultManager removeItemAtURL:song.localArtworkURL error:&error];
            if (error) {
                NSLog(@"Error deleting file from url = %@", error);
            }
            else {
                [self.songs removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                if (indexPath.section == self.indexPathOfLastPlayedSong.section) {
                    if (indexPath.row < self.indexPathOfLastPlayedSong.row) {
                        self.indexPathOfLastPlayedSong = [NSIndexPath indexPathForRow:(self.indexPathOfLastPlayedSong.row - 1) inSection:self.indexPathOfLastPlayedSong.section];
                    }
                }
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

- (void)cellPlayButtonTap:(UITapGestureRecognizer *)recognizer {
    
    CGPoint touchLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    AVURLAsset *assetToPlay = [[AVURLAsset alloc] initWithURL:self.songs[indexPath.row].localSongURL options:nil];
    AVPlayerItem *itemToPlay = [AVPlayerItem playerItemWithAsset:assetToPlay];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nextBtnTap:) name:AVPlayerItemDidPlayToEndTimeNotification object:itemToPlay];
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([indexPath isEqual:self.indexPathOfLastPlayedSong]) {
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil userInfo:@{@"cell" : cell}];
        }
        else {
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : cell}];
        }
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : cell}];
        [self.player replaceCurrentItemWithPlayerItem:itemToPlay];
    }
    
    self.indexPathOfLastPlayedSong = indexPath;
    [self setMusicPlayerSongNameAndImage];
}

#pragma mark - music view button actions

- (IBAction)musicControllerPlayBtnTap:(id)sender {
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:self.indexPathOfLastPlayedSong]}];
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:self.indexPathOfLastPlayedSong]}];
    }
}

- (IBAction)previousBtnTap:(id)sender {
    NSIndexPath *indexPath;
    if ((self.indexPathOfLastPlayedSong.row - 1) < 0) {
        indexPath = [NSIndexPath indexPathForRow:self.songs.count - 1 inSection:self.indexPathOfLastPlayedSong.section];
        [self replacePlayerSongWithSongAtIndexPath:indexPath];
    }
    else {
        indexPath = [NSIndexPath indexPathForRow:(self.indexPathOfLastPlayedSong.row - 1) inSection:self.indexPathOfLastPlayedSong.section];
        [self replacePlayerSongWithSongAtIndexPath:indexPath];
    }
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:indexPath]}];
    self.indexPathOfLastPlayedSong = indexPath;
    [self setMusicPlayerSongNameAndImage];
}

- (IBAction)nextBtnTap:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.indexPathOfLastPlayedSong.row + 1) % self.songs.count inSection:self.indexPathOfLastPlayedSong.section];
    [self replacePlayerSongWithSongAtIndexPath:indexPath];
    [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil userInfo:@{@"cell" : [self.tableView cellForRowAtIndexPath:indexPath]}];
    self.indexPathOfLastPlayedSong = indexPath;
    [self setMusicPlayerSongNameAndImage];
}


- (void)onMusicControllerPan:(UIPanGestureRecognizer *)recognizer {
    CGFloat velocityY = (0.2*[recognizer velocityInView:self.view].y);
    CGPoint translatedPoint = [recognizer translationInView:recognizer.view.superview];
    CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGPoint newCenter = CGPointMake(self.view.frame.size.width/2, recognizer.view.center.y + translatedPoint.y);
    
    if (newCenter.y >= ((self.view.frame.size.height) - self.musicControllerView.frame.size.height/2) && newCenter.y <= (self.view.frame.size.height + 65)) {
        recognizer.view.center = newCenter;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.center.y > ((self.view.frame.size.height + 100) - self.musicControllerView.frame.size.height/2)) {
            recognizer.view.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height + 65));
        }
        else {
            recognizer.view.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - (self.musicControllerView.frame.size.height/2)));
        }
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    [UIView commitAnimations];
}

- (void)replacePlayerSongWithSongAtIndexPath:(NSIndexPath *)indexPath {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.songs[indexPath.row].localSongURL options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(nextBtnTap:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    [self.player replaceCurrentItemWithPlayerItem:item];
    NSKeyValueObservingOptions options =
    NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    
    // Register as an observer of the player item's status property
    [item addObserver:self
           forKeyPath:@"status"
              options:options
              context:nil];
    
    
    self.indexPathOfLastPlayedSong = indexPath;
    [self setMusicPlayerSongNameAndImage];
}

- (void)playButtonTap:(NSNotification *)notification {
    [self.player play];
    [self.musicControllerView.playButton setImage:[UIImage imageNamed:@"pause_button_icon"] forState:UIControlStateNormal];
}

- (void)pauseButtonTap:(NSNotification *)notification {
    [self.player pause];
    [self.musicControllerView.playButton setImage:[UIImage imageNamed:@"play_button_icon"] forState:UIControlStateNormal];
}

- (void)setMusicPlayerSongNameAndImage {
    LocalSongModel *song = self.songs[self.indexPathOfLastPlayedSong.row];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:song.localArtworkURL]];
    if (image) {
        self.musicControllerView.songImage.image = image;
    }
    else {
        self.musicControllerView.songImage.image = [UIImage imageNamed:@"unknown_artist_transperent"];
    }
    self.musicControllerView.songName.text = song.songTitle;
}


- (void)stopPlayingAndSeekSmoothlyToTime:(CMTime)newChaseTime {
    [self.player pause];
    NSLog(@"time = %llf", CMTimeGetSeconds(newChaseTime));
    if (CMTIME_COMPARE_INLINE(newChaseTime, !=, self.chaseTime))
    {
        self.chaseTime = newChaseTime;
        
        if (!self.isSeekInProgress)
            [self trySeekToChaseTime];
    }
}

- (void)trySeekToChaseTime {
    if (self.playerCurrentItemStatus == AVPlayerItemStatusUnknown)
    {
        // wait until item becomes ready (KVO player.currentItem.status)
    }
    else if (self.playerCurrentItemStatus == AVPlayerItemStatusReadyToPlay)
    {
        
        [self actuallySeekToTime];
    }
}

- (void)actuallySeekToTime {
    self.isSeekInProgress = YES;
    CMTime seekTimeInProgress = self.chaseTime;
    [self.player seekToTime:seekTimeInProgress toleranceBefore:kCMTimeZero
              toleranceAfter:kCMTimeZero completionHandler:
     ^(BOOL isFinished)
     {
         if (CMTIME_COMPARE_INLINE(seekTimeInProgress, ==, self.chaseTime)) {
             self.isSeekInProgress = NO;
             [self.player play];
         }
         else
             [self trySeekToChaseTime];
     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                self.playerCurrentItemStatus = AVPlayerStatusReadyToPlay;
                self.musicControllerView.songTimeProgress.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                break;
            case AVPlayerItemStatusFailed:
                // Failed. Examine AVPlayerItem.error
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                break;
        }
    }
}

- (void)sliderIsSliding {
    self.isSliding = YES;
}

-(void) sliderEndedSliding {
    [self stopPlayingAndSeekSmoothlyToTime:CMTimeMake(self.musicControllerView.songTimeProgress.value * 600, 600)];
    self.isSliding = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
    [self.musicControllerView removeFromSuperview];
}

- (void)viewDidLayoutSubviews {
    [self configureMusicControllerView];
}

@end
