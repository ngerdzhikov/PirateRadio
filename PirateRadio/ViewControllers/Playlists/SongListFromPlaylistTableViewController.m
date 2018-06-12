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
#import "PlaylistsDatabase.h"
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

- (void)editSongs:(id)sender {
    self.editing = !self.editing;
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
        if (self.editing) {
            [editButton setTitle:@"Done"];
        }
        else {
            [editButton setTitle:@"Edit"];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.playlist.songs removeObjectAtIndex:indexPath.row];
        [PlaylistsDatabase updateDatabaseForChangedPlaylist:self.playlist];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSMutableArray<LocalSongModel *> *rearrangedSongs = [[NSMutableArray alloc] initWithCapacity:self.songs.count];
    if (toIndexPath.row - fromIndexPath.row > 0) {
        [rearrangedSongs addObjectsFromArray:[self.songs subarrayWithRange:NSMakeRange(fromIndexPath.row + 1, toIndexPath.row - fromIndexPath.row)]];
        [rearrangedSongs addObject:self.songs[fromIndexPath.row]];
        [rearrangedSongs addObjectsFromArray:[self.songs subarrayWithRange:NSMakeRange(toIndexPath.row + 1, self.songs.count - toIndexPath.row - 1)]];
        self.songs = [NSMutableArray arrayWithArray:rearrangedSongs];
    }
    else if (toIndexPath.row - fromIndexPath.row < 0) {
        [rearrangedSongs addObjectsFromArray:[self.songs subarrayWithRange:NSMakeRange(0, toIndexPath.row)]];
        [rearrangedSongs addObject:self.songs[fromIndexPath.row]];
        [rearrangedSongs addObjectsFromArray:[self.songs subarrayWithRange:NSMakeRange(toIndexPath.row, fromIndexPath.row - toIndexPath.row)]];
        if (fromIndexPath.row < self.songs.count - 1) {
            [rearrangedSongs addObjectsFromArray:[self.songs subarrayWithRange:NSMakeRange(fromIndexPath.row + 1, self.songs.count - 1 - fromIndexPath.row)]];
        }
        self.songs = [NSMutableArray arrayWithArray:rearrangedSongs];
    }
    self.playlist.songs = self.songs;

    [PlaylistsDatabase updateDatabaseForChangedPlaylist:self.playlist];
    
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
        
        [PlaylistsDatabase updateDatabaseForChangedPlaylist:self.playlist];
        
        [self.tableView reloadData];
    }
}


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
