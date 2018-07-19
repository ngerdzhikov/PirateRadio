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
#import "SavedMusicTableViewCell.h"
#import "LocalSongModel.h"
#import "PlaylistModel.h"
#import "Constants.h"



@interface SongListFromPlaylistTableViewController ()

@end

@implementation SongListFromPlaylistTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onSongDelete:) name:NOTIFICATION_REMOVED_SONG_FROM_FILES object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
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
        
        [RLMRealm.defaultRealm beginWriteTransaction];
        [self.playlist.realmSongs removeObjectAtIndex:indexPath.row];
        [RLMRealm.defaultRealm commitWriteTransaction];
        
        [self.allSongs removeObjectAtIndex:indexPath.row];
        
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
    
    [RLMRealm.defaultRealm beginWriteTransaction];
    [self.playlist.realmSongs removeAllObjects];
    [self.playlist.realmSongs addObjects:self.allSongs];
    [RLMRealm.defaultRealm commitWriteTransaction];

    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)onSongDelete:(NSNotification *)notification {
//    LocalSongModel *song = [notification.userInfo objectForKey:@"song"];
//
//    if ([self.playlist.songs containsObject:song]) {
//
//        [self.playlist.realmSongs removeObjectAtIndex:[self.playlist.realmSongs indexOfObject:song]];
//
//        [super displayEmptyListImageIfNeeded];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//    });
//
//    }
}

- (void)editSongs:(id)sender {
    if (!self.isFiltering) {
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
}

-(NSArray<LocalSongModel *> *)songs {
    if (self.isFiltering) {
        return self.filteredSongs;
    }
    return self.playlist.songs;
}

@end
