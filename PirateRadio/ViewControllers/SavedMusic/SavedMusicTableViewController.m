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



@interface SavedMusicTableViewController ()

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *songs;

@end

@implementation SavedMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didRecieveNewSong:) name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
    [self loadSongsFromDisk];
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

-(NSString *)properMusicTitleForSong:(LocalSongModel *)song {
    
    NSString *songTitle = [[song.artistName stringByAppendingString:@" - "] stringByAppendingString:song.songTitle];
    if ([song.artistName isEqualToString:@"Uknown artist"]) {
        songTitle = song.songTitle;
    }

    return songTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SavedMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];;
    LocalSongModel *song = self.songs[indexPath.row];
    cell.musicTitle.text = [self properMusicTitleForSong:song];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPlayButtonTap:)];
    [cell.circleProgressBar addGestureRecognizer:tap];
   

    if ([indexPath isEqual:[self indexPathOfLastPlayed]] && self.musicPlayerDelegate.isPlaying) {
        cell.circleProgressBar.unitString = BUTTON_TITLE_PAUSE_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(-1.5, -1.5);
    }
    else {
        cell.circleProgressBar.unitString = BUTTON_TITLE_PLAY_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(0, -0.5);
        cell.circleProgressBar.value = 0;
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.musicPlayerDelegate pauseLoadedSong];
    [self.musicPlayerDelegate prepareSong:[self nextSongForSong:self.musicPlayerDelegate.nowPlaying]];
    [self.musicPlayerDelegate setPlayerPlayPauseButtonState:EnumCellMediaPlaybackStatePlay];
    LocalSongModel *song = self.songs[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSError *error;
        [NSFileManager.defaultManager removeItemAtURL:song.localSongURL error:&error];
        UIImage *artwork = [UIImage imageWithData:[NSData dataWithContentsOfURL:song.localArtworkURL]];
        if (artwork != nil) {
            [NSFileManager.defaultManager removeItemAtURL:song.localArtworkURL error:&error];
        }
        if (error) {
            NSLog(@"Error deleting file from url = %@", error);
        }
        else {
            [self.songs removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(NSIndexPath *)indexPathOfLastPlayed {
    
    LocalSongModel *nowPlayingSong = self.musicPlayerDelegate.nowPlaying;
    NSIndexPath *indexPath;
    if (nowPlayingSong) {
        
        indexPath = [NSIndexPath indexPathForRow:[self.songs indexOfObject:nowPlayingSong] inSection:0] ;
    }
    
    return indexPath;
}

- (void)cellPlayButtonTap:(UITapGestureRecognizer *)recognizer {
    
    CGPoint touchLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
    
    // index of last previously played song;
    NSIndexPath *previouslyPlayedIndexPath = [NSIndexPath indexPathForRow:[self.songs indexOfObject:self.musicPlayerDelegate.nowPlaying] inSection:0];
    LocalSongModel *songToPlay = self.songs[indexPath.row];
    
    if (![songToPlay isEqual:self.musicPlayerDelegate.nowPlaying]) {
        [self clearProgressForCellAtIndexPath:previouslyPlayedIndexPath];
        [self.musicPlayerDelegate prepareSong:songToPlay];
        [self.musicPlayerDelegate playLoadedSong];
        
        [self.musicPlayerDelegate setPlayerPlayPauseButtonState:EnumCellMediaPlaybackStatePause];
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
    }
    else {
        if (self.musicPlayerDelegate.isPlaying) {
            
            [self.musicPlayerDelegate pauseLoadedSong];
            
            [self.musicPlayerDelegate setPlayerPlayPauseButtonState:EnumCellMediaPlaybackStatePlay];
            [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay forCellAtIndexPath:indexPath];
        }
        else {
            [self.musicPlayerDelegate playLoadedSong];
            
            [self.musicPlayerDelegate setPlayerPlayPauseButtonState:EnumCellMediaPlaybackStatePause];
            [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
        }
    }
}



- (LocalSongModel *)previousSongForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];;
    
    if ((previousIndexPath.row - 1) < 0) {
        previousIndexPath = [NSIndexPath indexPathForRow:self.songs.count - 1 inSection:indexPath.section];
    }
    
    
    return self.songs[previousIndexPath.row];
}

- (LocalSongModel *)nextSongForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) % self.songs.count inSection:indexPath.section];
    
    return self.songs[nextIndexPath.row];
}

- (void)clearProgressForCellAtIndexPath:(NSIndexPath *)indexPath {
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay forCellAtIndexPath:indexPath];
    cell.circleProgressBar.value = 0;
}

- (void)setMediaPlayBackState:(EnumCellMediaPlaybackState) playbackState forCellAtIndexPath:(NSIndexPath *)indexPath {
    
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (playbackState == EnumCellMediaPlaybackStatePlay) {
        
        cell.circleProgressBar.unitString = BUTTON_TITLE_PLAY_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(0, -0.5);
    }
    else {
        
        cell.circleProgressBar.unitString = BUTTON_TITLE_PAUSE_STRING;
        cell.circleProgressBar.textOffset = CGPointMake(-1.5, -1.5);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadSongsFromDisk];
}

//TODO: Add optimisations for index path getting here
-(NSIndexPath *)indexPathForSong:(LocalSongModel *)song {
    
    NSInteger row = [self.songs indexOfObject:song];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    return indexPath;
}

-(SavedMusicTableViewCell *)cellForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    SavedMusicTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)updateProgress:(double)progress forSong:(LocalSongModel *)song {
    
    SavedMusicTableViewCell *cell = [self cellForSong:song];
    cell.circleProgressBar.value = progress;
    if (progress >= 10) {
        cell.circleProgressBar.textOffset = CGPointMake(-3.5, -1.5);
    }
    else {
        cell.circleProgressBar.textOffset = CGPointMake(-2.5, -1.5);
    }
}

- (void)didPauseSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay forCellAtIndexPath:indexPath];
}

- (void)didStartPlayingSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
}

- (void)didRequestNextForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    [self clearProgressForCellAtIndexPath:indexPath];
    
    
    LocalSongModel *nextSong = [self nextSongForSong:song];
    [self.musicPlayerDelegate prepareSong:nextSong];
    
    indexPath = [self indexPathForSong:nextSong];
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
}

- (void)didRequestPreviousForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    [self clearProgressForCellAtIndexPath:indexPath];
    
    LocalSongModel *previousSong = [self previousSongForSong:song];
    [self.musicPlayerDelegate prepareSong:previousSong];
    
    indexPath = [self indexPathForSong:previousSong];
    [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
}

- (void)didRecieveNewSong:(NSNotification *)notification {
    LocalSongModel *newSong = [notification.userInfo objectForKey:@"song"];
    [self.songs addObject:newSong];
    NSArray *paths = @[[NSIndexPath indexPathForRow:self.songs.count - 1 inSection:0]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

@end
