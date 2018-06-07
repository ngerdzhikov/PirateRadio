//
//  AllSongsTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 5.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "AllSongsTableViewController.h"
#import "PlaylistModel.h"
#import "LocalSongModel.h"
#import "SongListPlusPlayerViewController.h"
#import "Constants.h"
#import "PlaylistsDatabase.h"

@interface AllSongsTableViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *songs;
@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *selectedSongs;
@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *backupSongs;
@property (strong, nonatomic) NSString *searchTextBeforeEnding;

@end

@implementation AllSongsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSongsFromDisk];
    self.selectedSongs = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Songs to add";
    
    UIBarButtonItem *commitSelectedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(commitSelected)];
    self.navigationItem.rightBarButtonItem = commitSelectedButton;
    
    self.backupSongs = [NSMutableArray arrayWithArray:self.songs];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0., 0., 320., 44.)];
    searchBar.enablesReturnKeyAutomatically = NO;
    searchBar.returnKeyType = UIReturnKeyDone;
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            if (![self.playlist.songs containsObject:localSong]) {
                [self.songs addObject:localSong];
            }
        }
    }];
    
    [self.tableView reloadData];
}

- (void)commitSelected {
    [self.playlist.songs addObjectsFromArray:self.selectedSongs];
//    get playlists
    [PlaylistsDatabase updateDatabaseForChangedPlaylist:self.playlist];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allSongsCell"];
    LocalSongModel *song = self.songs[indexPath.row];
    if (![song.artistName isEqualToString:@"Unknown artist"]) {
        cell.textLabel.text = [[song.artistName stringByAppendingString: @" - "] stringByAppendingString:song.songTitle];
    }
    else {
        cell.textLabel.text = song.songTitle;
    }
    
    if ([self.selectedSongs containsObject:self.songs[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.selectedSongs containsObject:self.songs[indexPath.row]]) {
        [self.selectedSongs addObject:self.songs[indexPath.row]];
    }
    else {
        [self.selectedSongs removeObject:self.songs[indexPath.row]];
    }
    [self.tableView reloadData];
}


#pragma mark searchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.searchTextBeforeEnding = searchText;
    
    
    if (searchText.length > 0) {
        self.songs = [NSMutableArray arrayWithArray:self.backupSongs];
        self.songs = [[self.songs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LocalSongModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return ([evaluatedObject.songTitle.lowercaseString containsString:searchText.lowercaseString] ||
                    [evaluatedObject.artistName.lowercaseString containsString:searchText.lowercaseString]);
        }]] mutableCopy];
        
        [self.tableView reloadData];
    }
    else {
        self.songs = [NSMutableArray arrayWithArray:self.backupSongs];
        [self.tableView reloadData];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.text = self.searchTextBeforeEnding;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
