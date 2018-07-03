//
//  SongListFromPlaylistTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 6.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SongListFromPlaylistTableViewController.h"
#import <MBCircularProgressBar/MBCircularProgressBarView.h>
#import "AllSongsTableViewController.h"
#import "MusicPlayerViewController.h"
#import "SavedMusicTableViewCell.h"
#import "DataBase.h"
#import "LocalSongModel.h"
#import "PlaylistModel.h"
#import "Constants.h"



@interface SongListFromPlaylistTableViewController ()

@end

@implementation SongListFromPlaylistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onSongDelete:) name:NOTIFICATION_REMOVED_SONG_FROM_FILES object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addSongInPlaylist {
    
    AllSongsTableViewController *allSongsTVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"allSongsTableView"];
    allSongsTVC.playlist = self.playlist;
    [self.navigationController pushViewController:allSongsTVC animated:YES];
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DataBase *db = [[DataBase alloc] init];
        [db removeArrayOfSongs:@[self.playlist.songs[indexPath.row]] fromPlaylist:self.playlist];
        [self.playlist.songs removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [super displayEmptyListImageIfNeeded];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSMutableArray<LocalSongModel *> *rearrangedSongs = [[NSMutableArray alloc] initWithCapacity:self.allSongs.count];
    if (toIndexPath.row - fromIndexPath.row > 0) {
        [rearrangedSongs addObjectsFromArray:[self.allSongs subarrayWithRange:NSMakeRange(0, fromIndexPath.row)]];
        [rearrangedSongs addObjectsFromArray:[self.allSongs subarrayWithRange:NSMakeRange(fromIndexPath.row + 1, toIndexPath.row - fromIndexPath.row)]];
        [rearrangedSongs addObject:self.allSongs[fromIndexPath.row]];
        [rearrangedSongs addObjectsFromArray:[self.allSongs subarrayWithRange:NSMakeRange(toIndexPath.row + 1, self.allSongs.count - toIndexPath.row - 1)]];
        self.allSongs = [NSMutableArray arrayWithArray:rearrangedSongs];
    }
    else if (toIndexPath.row - fromIndexPath.row < 0) {
        [rearrangedSongs addObjectsFromArray:[self.allSongs subarrayWithRange:NSMakeRange(0, toIndexPath.row)]];
        [rearrangedSongs addObject:self.allSongs[fromIndexPath.row]];
        [rearrangedSongs addObjectsFromArray:[self.allSongs subarrayWithRange:NSMakeRange(toIndexPath.row, fromIndexPath.row - toIndexPath.row)]];
        if (fromIndexPath.row < self.allSongs.count - 1) {
            [rearrangedSongs addObjectsFromArray:[self.allSongs subarrayWithRange:NSMakeRange(fromIndexPath.row + 1, self.allSongs.count - 1 - fromIndexPath.row)]];
        }
        self.allSongs = [NSMutableArray arrayWithArray:rearrangedSongs];
    }
    self.playlist.songs = self.allSongs;

    DataBase *db = [[DataBase alloc] init];
//    [db updatePlaylist:self.playlist];
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)didRecieveNewSong:(NSNotification *)notification {
// override with nothing because it's in the playlist
    return;
}

- (void)onSongDelete:(NSNotification *)notification {
    LocalSongModel *song = [notification.userInfo objectForKey:@"song"];
    
    if ([self.playlist.songs containsObject:song]) {
        
        [self.playlist.songs removeObject:song];
        
        DataBase *db = [[DataBase alloc] init];
        [db removeArrayOfSongs:@[song] fromPlaylist:self.playlist];
        
        [super displayEmptyListImageIfNeeded];
        
        [self.tableView reloadData];
    }
}


@end
