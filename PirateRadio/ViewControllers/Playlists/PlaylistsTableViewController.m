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
#import "Constants.h"
#import "PlaylistsDatabase.h"

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
    
//    clear NSUserDefaults for debug
//    [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"playlists"];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [PlaylistsDatabase savePlaylistArray:self.playlists];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // load playlists from UserDefaults
    self.playlists = [[PlaylistsDatabase loadPlaylistsFromUserDefaults] mutableCopy];
    // if there are no playlists allocate memory for playlists array
    if (!self.playlists) {
        self.playlists = [[NSMutableArray alloc] init];
    }
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistModel *playlist = self.playlists[indexPath.row];
    
    if (![self.songListPlusPlayerVC.playlist.name isEqualToString:playlist.name])
        self.songListPlusPlayerVC = [SongListPlusPlayerViewController songListPlusPlayerViewControllerWithPlaylist:playlist];
    [self.navigationController pushViewController:self.songListPlusPlayerVC animated:YES];

}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.playlists removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if (alertController.textFields[0].text.length > 1 && ![(NSArray<NSString *> *)[self.playlists valueForKey:@"name"] containsObject:alertController.textFields[0].text]) {
            PlaylistModel *playlist = [[PlaylistModel alloc] initWithName:alertController.textFields[0].text];
            [self.playlists addObject:playlist];
            
            [self.tableView reloadData];
            
            [PlaylistsDatabase savePlaylistArray:self.playlists];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Called when user taps outside
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:NO completion:^{
        
    }];
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
