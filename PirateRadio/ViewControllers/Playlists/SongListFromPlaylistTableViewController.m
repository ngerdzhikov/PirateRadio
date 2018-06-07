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

- (void)editSongs {
    self.editing = !self.editing;
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
    LocalSongModel *movingSong = self.playlist.songs[fromIndexPath.row];
    LocalSongModel *replacedSong = self.playlist.songs[toIndexPath.row];
    
    [self.playlist.songs replaceObjectAtIndex:toIndexPath.row withObject:movingSong];
    [self.playlist.songs replaceObjectAtIndex:fromIndexPath.row withObject:replacedSong];
    
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
