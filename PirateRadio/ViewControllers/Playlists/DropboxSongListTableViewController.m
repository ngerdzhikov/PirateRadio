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
    if (![self isLoggedInDropbox]) {
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:[[self class] topMostController]
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                                  if ([self isLoggedInDropbox]) {
                                                      
                                                  }
                                                  else {
                                                      [self.navigationController popViewControllerAnimated:YES];
                                                  }
                                              }];
                                          }];
    }
    
    UIImage *image = [UIImage imageNamed:@"dropbox_background"];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [image drawInRect:self.view.bounds blendMode:kCGBlendModeNormal alpha:0.27];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    
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
    cell.backgroundColor = [UIColor clearColor];
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

- (BOOL)isLoggedInDropbox {
    return [DBClientsManager authorizedClient] != nil;
}

+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
