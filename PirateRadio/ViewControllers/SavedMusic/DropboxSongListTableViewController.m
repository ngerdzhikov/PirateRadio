//
//  DropboxSongListTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "DropboxSongListTableViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "SelectedDropboxCellPopoverViewController.h"
#import "DropBox.h"

@interface DropboxSongListTableViewController ()

@property (strong, nonatomic) NSMutableArray<NSString *> *songs;

@end

@implementation DropboxSongListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.songs = [[NSMutableArray alloc] init];
    
    [self loadContentsOfSongsDirectory];
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
    return self.songs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dropboxCell" forIndexPath:indexPath];
    NSString *songName = self.songs[indexPath.row];
    cell.textLabel.text = [songName substringToIndex:songName.length - 4];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *songName = self.songs[indexPath.row];

    
    SelectedDropboxCellPopoverViewController *selectedSongVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectedDropboxCellPopover"];
    selectedSongVC.songName = songName;
    selectedSongVC.modalPresentationStyle = UIModalPresentationPopover;
    selectedSongVC.preferredContentSize = CGSizeMake(150, 75);
    UIPopoverPresentationController *popOverController = selectedSongVC.popoverPresentationController;
    popOverController.delegate = selectedSongVC;
    popOverController.sourceView = cell;
    popOverController.sourceRect = cell.bounds;
    popOverController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:selectedSongVC animated:YES completion:nil];
    
}


- (void)loadContentsOfSongsDirectory {
    DBUserClient *client = [DBClientsManager authorizedClient];
    
    [[client.filesRoutes listFolder:@"/PirateRadio/songs"]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             
             for (DBFILESMetadata *entry in entries) {
                 if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
                     DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
                     [self.songs addObject:fileMetadata.name];
                 }
             }
             
             if (hasMore) {
                 NSLog(@"Folder is large enough where we need to call `listFolderContinue:`");
                 
                 [self addMoreFolderContentsforContinueWithClient:client cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }];
}

- (void)addMoreFolderContentsforContinueWithClient:(DBUserClient *)client cursor:(NSString *)cursor {
    [[client.filesRoutes listFolderContinue:cursor]
     setResponseBlock:^(DBFILESListFolderResult *response, DBFILESListFolderContinueError *routeError,
                        DBRequestError *networkError) {
         if (response) {
             NSArray<DBFILESMetadata *> *entries = response.entries;
             NSString *cursor = response.cursor;
             BOOL hasMore = [response.hasMore boolValue];
             
             for (DBFILESMetadata *entry in entries) {
                 if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
                     DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
                     [self.songs addObject:fileMetadata.pathDisplay];
                 }
             }
             
             if (hasMore) {
                 [self  addMoreFolderContentsforContinueWithClient:client cursor:cursor];
             } else {
                 NSLog(@"List folder complete.");
             }
         } else {
             NSLog(@"%@\n%@\n", routeError, networkError);
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
     }];
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
