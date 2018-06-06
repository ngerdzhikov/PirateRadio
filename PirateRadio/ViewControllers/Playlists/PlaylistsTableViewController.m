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

@interface PlaylistsTableViewController ()

@end

@implementation PlaylistsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *addPlaylistButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylist)];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPlaylists)];
    self.navigationItem.rightBarButtonItems = @[addPlaylistButton, editButton];
    self.navigationItem.title = @"Playlists";
    
//    clear NSUserDefaults for debug
//    [NSUserDefaults.standardUserDefaults setObject:nil forKey:@"playlists"];
    
    // load playlists from UserDefaults
    self.playlists = [[self loadPlaylistsFromUserDefaults] mutableCopy];
    // if there are no playlists allocate memory for playlists array
    if (!self.playlists) {
        self.playlists = [[NSMutableArray alloc] init];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self savePlaylistArray:self.playlists];
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistModel *playlist = self.playlists[indexPath.row];
    
    SongListPlusPlayerViewController * songListPlusPlayerVC = [SongListPlusPlayerViewController songListPlusPlayerViewControllerWithPlaylist:playlist];
    [self.navigationController pushViewController:songListPlusPlayerVC animated:YES];

}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.playlists removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    PlaylistModel *movingPlaylist = self.playlists[fromIndexPath.row];
    PlaylistModel *replacedPlaylist = self.playlists[toIndexPath.row];
    
    [self.playlists setObject:movingPlaylist atIndexedSubscript:toIndexPath.row];
    [self.playlists setObject:replacedPlaylist atIndexedSubscript:fromIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)addPlaylist {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create playlist" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Playlist name";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (alertController.textFields[0].text.length > 1) {
            PlaylistModel *playlist = [[PlaylistModel alloc] initWithName:alertController.textFields[0].text];
            [self.playlists addObject:playlist];
            [self.tableView reloadData];
        }
    }];
    [alertController addAction:okAction];
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

- (void)savePlaylistArray:(NSArray<PlaylistModel *> *)playlists {
    NSData *encodedPlaylists = [NSKeyedArchiver archivedDataWithRootObject:playlists];
    [NSUserDefaults.standardUserDefaults setObject:encodedPlaylists forKey:@"playlists"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSArray<PlaylistModel *> *)loadPlaylistsFromUserDefaults {
    NSData *encodedPlaylists = [NSUserDefaults.standardUserDefaults objectForKey:@"playlists"];
    NSArray<PlaylistModel *> *playlists = [NSKeyedUnarchiver unarchiveObjectWithData:encodedPlaylists];
    return playlists;
}

@end
