//
//  SavedMusicTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicTableViewController.h"
#import "SavedMusicTableViewCell.h"
#import "MusicPlayerViewController.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>
#import "Constants.h"
#import "LocalSongModel.h"


typedef enum {
    EnumCellMediaPlaybackStatePlay,
    EnumCellMediaPlaybackStatePause
} EnumCellMediaPlaybackState;

@interface SavedMusicTableViewController ()

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *songs;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSIndexPath *indexPathOfLastPlayedSong;
@property BOOL isSeekInProgress;
@property BOOL isSliding;
@property CMTime chaseTime;
@property AVPlayerStatus playerCurrentItemStatus; // your player.currentItem.status

@end

@implementation SavedMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)updateProgressBar:(NSNumber *)value {
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathOfLastPlayedSong];
    cell.circleProgressBar.value = [value doubleValue] * 100;
    if (cell.circleProgressBar.value >= 10) {
        if ([value doubleValue] >= 10) {
            cell.circleProgressBar.textOffset = CGPointMake(-3.5, -1.5);
        }
        else {
            cell.circleProgressBar.textOffset = CGPointMake(-2.5, -1.5);
        }
    }
}

- (void)loadFirstItemForPlayerAtBeginning {
    self.indexPathOfLastPlayedSong = [NSIndexPath indexPathForRow:0 inSection:0];
    LocalSongModel *song = [self.songs objectAtIndex:self.indexPathOfLastPlayedSong.row];
    [NSNotificationCenter.defaultCenter postNotificationName:@"newSongLoaded" object:nil userInfo:[NSDictionary dictionaryWithObject:song forKey:@"song"]];
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
    [self.tableView reloadData];
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
    SavedMusicTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    LocalSongModel *song = self.songs[indexPath.row];
    if ([song.artistName isEqualToString:@"Uknown artist"]) {
        cell.musicTitle.text = song.songTitle;
    }
    else {
        cell.musicTitle.text = [[song.artistName stringByAppendingString:@" - "] stringByAppendingString:song.songTitle];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPlayButtonTap:)];
    [cell.circleProgressBar addGestureRecognizer:tap];

    if ([indexPath isEqual:self.indexPathOfLastPlayedSong] && self.musicPlayerDelegate.avPlayerStatusIsPlaying) {
        cell.circleProgressBar.unitString = BUTTON_TITLE_PAUSE_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(-1.5, -1.5);
    }
    else {
        cell.circleProgressBar.unitString = BUTTON_TITLE_PLAY_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(0, -0.5);
    }
    
    
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
    
    if ([indexPath isEqual:self.indexPathOfLastPlayedSong]) {
        if (self.musicPlayerDelegate.avPlayerStatusIsPlaying) {
            [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay];
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PAUSE_BUTTON_PRESSED object:nil];
        }
        else {
            [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause];
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil];
        }
    }
    else {
        [self clearLastCellProgress];
        [self.musicPlayerDelegate replaceCurrentSongWithSong:self.songs[indexPath.row]];
        [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_PLAY_BUTTON_PRESSED object:nil];
        self.indexPathOfLastPlayedSong = indexPath;
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause];
    }
}

- (LocalSongModel *)firstSong {
    return self.songs[0];
}

- (LocalSongModel *)previousSong {
    [self clearLastCellProgress];
    
    NSIndexPath *indexPath;
    if ((self.indexPathOfLastPlayedSong.row - 1) < 0) {
        indexPath = [NSIndexPath indexPathForRow:self.songs.count - 1 inSection:self.indexPathOfLastPlayedSong.section];
    }
    else {
        indexPath = [NSIndexPath indexPathForRow:(self.indexPathOfLastPlayedSong.row - 1) inSection:self.indexPathOfLastPlayedSong.section];
    }
    self.indexPathOfLastPlayedSong = indexPath;
    
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause];
    
    return self.songs[indexPath.row];
}

- (LocalSongModel *)nextSong {
    [self clearLastCellProgress];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.indexPathOfLastPlayedSong.row + 1) % self.songs.count inSection:self.indexPathOfLastPlayedSong.section];
    self.indexPathOfLastPlayedSong = indexPath;
    
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause];
    
    return self.songs[indexPath.row];
}

- (void)clearLastCellProgress {
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathOfLastPlayedSong];
    cell.circleProgressBar.unitString = BUTTON_TITLE_PLAY_STRING;
    cell.circleProgressBar.textOffset = CGPointMake(0, -0.5);
    cell.circleProgressBar.value = 0;
}

- (void)setMediaPlayBackState:(EnumCellMediaPlaybackState) playbackState {
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathOfLastPlayedSong];
    if (playbackState == EnumCellMediaPlaybackStatePlay) {
        cell.circleProgressBar.unitString = BUTTON_TITLE_PLAY_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(0, -0.5);
    }
    else {
        cell.circleProgressBar.unitString = BUTTON_TITLE_PAUSE_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(-1.5, -1.5);
    }
}

- (void)onPlayButtonTap {
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause];
}

- (void)onPauseButtonTap {
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSongsFromDisk];
}

@end
