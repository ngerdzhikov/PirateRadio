//
//  SavedMusicTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicTableViewController.h"
#import "SavedMusicTableViewCell.h"

@interface SavedMusicTableViewController ()

@property (strong, nonatomic) NSMutableArray *mp3Files;
@property (strong, nonatomic) AVQueuePlayer *player;
@property (strong, nonatomic) NSMutableArray *isPlaying;

@end

@implementation SavedMusicTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp3Files = [[NSMutableArray alloc] init];
    self.player = [[AVQueuePlayer alloc] init];
    self.isPlaying = [[NSMutableArray alloc] init];
    [self loadAssetsForPlayer];
    
}

- (void)loadAssetsForPlayer {
    NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSArray* dirs = [NSFileManager.defaultManager contentsOfDirectoryAtURL:sourcePath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"mp3"]) {
            [self.mp3Files addObject:filename];
            [self.isPlaying addObject:[NSNumber numberWithInt:0]];
        }
    }];
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
    return self.mp3Files.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SavedMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    cell.musicTitle.text = [[self.mp3Files[indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    cell.playButton.tag = indexPath.row;
//    [cell.playButton addTarget:self action:@selector(playButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}
- (IBAction)playButtonTap:(UIButton*)button {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.mp3Files[button.tag] options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    if (self.isPlaying[button.tag] == [NSNumber numberWithInt:1]) {
        [self.player pause];
        button.titleLabel.text = @"Paused";
        self.isPlaying[button.tag] = [NSNumber numberWithInt:0];
    }
    else {
        if (![((AVURLAsset*)self.player.currentItem.asset).URL isEqual:asset.URL]) {
            [self.player replaceCurrentItemWithPlayerItem:item];
        }
        self.isPlaying[button.tag] = [NSNumber numberWithInt:1];
        [self.player play];
        button.titleLabel.text = @"Play";
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    AVAsset *asset = [AVAsset assetWithURL:self.mp3Files[indexPath.row]];
//    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
//    [self.player replaceCurrentItemWithPlayerItem:item];
//
//}



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
