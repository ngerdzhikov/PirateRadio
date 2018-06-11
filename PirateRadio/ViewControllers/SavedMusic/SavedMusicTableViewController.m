//
//  SavedMusicTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <MBCircularProgressBar/MBCircularProgressBarView.h>
#import "SavedMusicTableViewController.h"
#import "AllSongsTableViewController.h"
#import "MusicPlayerViewController.h"
#import "SavedMusicTableViewCell.h"
#import "LocalSongModel.h"
#import "PlaylistModel.h"
#import "Constants.h"


@interface SavedMusicTableViewController ()

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *filteredSongs;
@property (strong, nonatomic) NSString *searchTextBeforeEnding;
@property BOOL isFiltered;

@end

@implementation SavedMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didRecieveNewSong:) name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0., 0., 320., 44.)];
    searchBar.enablesReturnKeyAutomatically = NO;
    searchBar.returnKeyType = UIReturnKeyDone;
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    if (self.songs.count == 0) {
//        UIImageView *noSongsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty_chest_image"]];
//        noSongsImageView.frame = CGRectMake(self.tableView.frame.size.width / 4, self.tableView.frame.size.height / 4, self.tableView.frame.size.width / 2, self.tableView.frame.size.height / 2);
//        [self.view addSubview:noSongsImageView];
//        self.tableView.tableHeaderView = nil;
//    }
    
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
    if (self.isFiltered) {
        return self.filteredSongs.count;
    }
    return self.songs.count;
}

-(NSString *)properMusicTitleForSong:(LocalSongModel *)song {
    
    NSString *songTitle = [[song.artistName stringByAppendingString:@" - "] stringByAppendingString:song.songTitle];
    if ([song.artistName isEqualToString:@"Unknown artist"]) {
        songTitle = song.songTitle;
    }

    return songTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SavedMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    
    LocalSongModel *song;
    if (self.isFiltered) {
        song = self.filteredSongs[indexPath.row];
    }
    else {
        song = self.songs[indexPath.row];
    }
    cell.musicTitle.text = [self properMusicTitleForSong:song];

    if ([song isEqual:self.musicPlayerDelegate.nowPlaying]) {
        if (self.musicPlayerDelegate.isPlaying) {
            cell.circleProgressBar.unitString = BUTTON_TITLE_PAUSE_STRING;
            cell.circleProgressBar.textOffset = CGPointMake(-1.5, -1.5);
        }
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
    
    if ([[self indexPathOfLastPlayed] isEqual:[self indexPathForSong:self.musicPlayerDelegate.nowPlaying]]) {
        [self.musicPlayerDelegate pauseLoadedSong];
        [self.musicPlayerDelegate prepareSong:[self nextSongForSong:self.musicPlayerDelegate.nowPlaying]];
        [self.musicPlayerDelegate setPlayerPlayPauseButtonState:YES];
    }
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
            
//            remove from dataSource
            [self.songs removeObjectAtIndex:indexPath.row];
//            post notification that song is deleted and pass it
            [NSNotificationCenter.defaultCenter postNotificationName:NOTIFICATION_REMOVED_SONG_FROM_FILES object:nil userInfo:[NSDictionary dictionaryWithObject:song forKey:@"song"]];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectSongFromCellForIndexPath:indexPath];
}

-(NSIndexPath *)indexPathOfLastPlayed {
    
    LocalSongModel *nowPlayingSong = self.musicPlayerDelegate.nowPlaying;
    NSIndexPath *indexPath;
    if (nowPlayingSong) {
        
        indexPath = [NSIndexPath indexPathForRow:[self.songs indexOfObject:nowPlayingSong] inSection:0] ;
    }
    
    return indexPath;
}



- (void)didSelectSongFromCellForIndexPath:(NSIndexPath *)indexPath {
    // index of last previously played song;
    NSIndexPath *previouslyPlayedIndexPath = [self indexPathOfLastPlayed];
    LocalSongModel *songToPlay = self.songs[indexPath.row];
    
    if (![songToPlay isEqual:self.musicPlayerDelegate.nowPlaying]) {
        [self clearProgressForCellAtIndexPath:previouslyPlayedIndexPath];
        [self.musicPlayerDelegate prepareSong:songToPlay];
        [self.musicPlayerDelegate playLoadedSong];
        
        [self.musicPlayerDelegate setPlayerPlayPauseButtonState:NO];
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
    }
    else {
        if (self.musicPlayerDelegate.isPlaying) {
            
            [self.musicPlayerDelegate pauseLoadedSong];
            
            [self.musicPlayerDelegate setPlayerPlayPauseButtonState:YES];
            [self setMediaPlayBackState:EnumCellMediaPlaybackStatePlay forCellAtIndexPath:indexPath];
        }
        else {
            [self.musicPlayerDelegate playLoadedSong];
            
            [self.musicPlayerDelegate setPlayerPlayPauseButtonState:NO];
            [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
        }
    }
}


- (LocalSongModel *)previousSongForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(indexPath.row - 1) inSection:indexPath.section];;
    
    if (previousIndexPath.row < 0) {
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

#pragma mark songListDelegate

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
    if (indexPath.row <= self.songs.count) {
        
        [self clearProgressForCellAtIndexPath:indexPath];
        
        LocalSongModel *nextSong = [self nextSongForSong:song];
        [self.musicPlayerDelegate prepareSong:nextSong];
        
        indexPath = [self indexPathForSong:nextSong];
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
    }
}

- (void)didRequestPreviousForSong:(LocalSongModel *)song {
    
    NSIndexPath *indexPath = [self indexPathForSong:song];
    if (indexPath.row <= self.songs.count) {
        
        [self clearProgressForCellAtIndexPath:indexPath];
        
        LocalSongModel *previousSong = [self previousSongForSong:song];
        [self.musicPlayerDelegate prepareSong:previousSong];
        
        indexPath = [self indexPathForSong:previousSong];
        [self setMediaPlayBackState:EnumCellMediaPlaybackStatePause forCellAtIndexPath:indexPath];
    }
}

- (void)didRecieveNewSong:(NSNotification *)notification {
    LocalSongModel *newSong = [notification.userInfo objectForKey:@"song"];
    [self.songs addObject:newSong];
    NSArray *paths = @[[NSIndexPath indexPathForRow:self.songs.count - 1 inSection:0]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark searchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    self.searchTextBeforeEnding = searchText;
    
    
    if (searchText.length > 0) {
        self.isFiltered = YES;
        self.filteredSongs = [[self.songs filteredArrayUsingPredicate:
                               [NSPredicate predicateWithBlock:^BOOL(LocalSongModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            
            return ([[self properMusicTitleForSong:evaluatedObject].lowercaseString containsString:searchText.lowercaseString] ||
                    [evaluatedObject.songTitle.lowercaseString containsString:searchText.lowercaseString] ||
                    [evaluatedObject.artistName.lowercaseString containsString:searchText.lowercaseString]);
        }]] mutableCopy];
        
        [self.tableView reloadData];
    }
    else {
        self.isFiltered = NO;
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.text = self.searchTextBeforeEnding;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end
