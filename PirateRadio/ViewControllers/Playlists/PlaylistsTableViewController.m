//
//  PlaylistsTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 4.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "PlaylistsTableViewController.h"
#import "PlaylistModel.h"
#import "SongListPlusPlayerViewController.h"
#import "DropboxSongListTableViewController.h"
#import "FavouriteVideosTableViewController.h"
#import "Constants.h"
#import "DataBase.h"

@interface PlaylistsTableViewController ()

@property (strong, nonatomic) SongListPlusPlayerViewController * songListPlusPlayerVC;

@end

@implementation PlaylistsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addPlaylistButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editPlaylists)];
    self.navigationItem.rightBarButtonItems = @[addPlaylistButton, editButton];
    self.navigationItem.title = @"Playlists";

    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onCellLongPress:)];
    [self.tableView addGestureRecognizer:longPressGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.playlists = [[NSMutableArray alloc] init];
    PlaylistModel *favouriteVideosPlaylist = [[PlaylistModel alloc] initWithName:@"Favourite Videos"];
    PlaylistModel *dropboxFiles = [[PlaylistModel alloc] initWithName:@"Dropbox"];
    
    [self.playlists addObject:favouriteVideosPlaylist];
    [self.playlists addObject:dropboxFiles];
    
    DataBase *db = [[DataBase alloc] init];
    [self.playlists addObjectsFromArray:db.allPlaylists];
    // if there are no playlists allocate memory for playlists array
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"playlistCell"];
    PlaylistModel *playlist = self.playlists[indexPath.row];
    
    cell.textLabel.text = playlist.name;
    
    if ([self.songListPlusPlayerVC.playlist.name isEqualToString:playlist.name]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"dropbox_icon"];
    }
    else if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"video_icon"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"playlist_icon"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistModel *playlist = self.playlists[indexPath.row];
    
    if (indexPath.row == 0) {
        FavouriteVideosTableViewController *favouriteVideosTVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FavouriteVideosTableViewController"];
        [self.navigationController pushViewController:favouriteVideosTVC animated:YES];
    }
    else if (indexPath.row == 1) {
        DropboxSongListTableViewController *dropboxSongListVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DropboxSongList"];
        [self.navigationController pushViewController:dropboxSongListVC animated:YES];
    }
    else {
        if (![self.songListPlusPlayerVC.playlist.name isEqualToString:playlist.name]) {
            self.songListPlusPlayerVC = [SongListPlusPlayerViewController songListPlusPlayerViewControllerWithPlaylist:playlist];
        }
        [self.navigationController pushViewController:self.songListPlusPlayerVC animated:YES];
    }

}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row < 2) {
        return sourceIndexPath;
    }
    else {
        return proposedDestinationIndexPath;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 2) return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DataBase *db = [[DataBase alloc] init];
        if ([db deletePlaylist:self.playlists[indexPath.row]]) {
            [self.playlists removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    PlaylistModel *movingPlaylist = self.playlists[fromIndexPath.row];
    PlaylistModel *replacedPlaylist = self.playlists[toIndexPath.row];
    
    [self.playlists setObject:movingPlaylist atIndexedSubscript:toIndexPath.row];
    [self.playlists setObject:replacedPlaylist atIndexedSubscript:fromIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}


- (void)addPlaylist {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Playlist name";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (alertController.textFields[0].text.length > 1 && ![(NSArray<NSString *> *)[self.playlists valueForKey:@"name"] containsObject:alertController.textFields[0].text]) {
            PlaylistModel *playlist = [[PlaylistModel alloc] initWithName:alertController.textFields[0].text];

            DataBase *db = [[DataBase alloc] init];
            if ([db addNewPlaylist:playlist]) {
                [self.playlists addObject:playlist];
                
                [self.tableView reloadData];
                
            }
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // Called when user taps outside
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onCellLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchPoint = [recognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
        
        if (indexPath) {
            PlaylistModel *playlist = self.playlists[indexPath.row];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Rename playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"New playlist name";
                textField.text = playlist.name;
            }];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                // Called when user taps outside
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (alertController.textFields[0].text.length > 1) {
                    DataBase *db = [[DataBase alloc] init];
                    [db renamePlaylistWithNewName:alertController.textFields[0].text forOldPlaylistName:playlist.name];
                    playlist.name = alertController.textFields[0].text;
                    [self.tableView reloadData];
                    
                }
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

- (void)editPlaylists {
    self.editing = !self.editing;
    if (self.editing) {
        self.navigationItem.rightBarButtonItems[1].title = @"Done";
    }
    else {
        self.navigationItem.rightBarButtonItems[1].title = @"Edit";
    }
}


@end
