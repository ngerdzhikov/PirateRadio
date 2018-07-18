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
#import "CoreData/CoreData.h"
#import "DataBase.h"

@interface AllSongsTableViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *allSongs;
@property (strong, nonatomic) NSArray<LocalSongModel *> *filteredSongs;
@property (strong, nonatomic) NSMutableArray<LocalSongModel *> *selectedSongs;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation AllSongsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allSongs = [[NSMutableArray alloc] init];
    [self loadSongsFromRealm];
    self.selectedSongs = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"Songs to add";
    
    UIBarButtonItem *commitSelectedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(commitSelected)];
    self.navigationItem.rightBarButtonItem = commitSelectedButton;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.searchController.searchBar.delegate = self;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSongsFromRealm {
    RLMResults *songsResult = [LocalSongModel allObjects];
    for (LocalSongModel *song in songsResult) {
        if (![self.playlist.songs containsObject:song]) {
            [self.allSongs addObject:song];
        }
    }
    
    [self.tableView reloadData];
}

- (void)commitSelected {
    [RLMRealm.defaultRealm beginWriteTransaction];
    [self.playlist.realmSongs addObjects:self.selectedSongs];
    [RLMRealm.defaultRealm commitWriteTransaction];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allSongsCell" forIndexPath:indexPath];
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
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark searchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length > 0) {
        
        self.filteredSongs = [self.allSongs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LocalSongModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            
            return ([evaluatedObject.songTitle.lowercaseString containsString:searchText.lowercaseString] ||
                    [evaluatedObject.artistName.lowercaseString containsString:searchText.lowercaseString]);
        }]];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [self.tableView reloadData];
}

- (BOOL)isFiltering {
    return ![self.searchController.searchBar.text isEqualToString:@""];
}

- (NSArray<LocalSongModel *> *)songs {
    if (self.isFiltering) {
        return self.filteredSongs;
    }
    return self.allSongs;
}

@end
