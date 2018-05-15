//
//  SavedMusicTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicViewController.h"
#import "SavedMusicTableViewCell.h"
#import "MusicControllerView.h"

@interface SavedMusicViewController ()

@property (strong, nonatomic) NSMutableArray *mp3Files;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSMutableArray *isSongPlaying;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MusicControllerView *musicControllerView;

@property BOOL isPlayerPlaying;

@end

@implementation SavedMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mp3Files = [[NSMutableArray alloc] init];
    self.player = [[AVPlayer alloc] init];
    self.isSongPlaying = [[NSMutableArray alloc] init];
    [self loadAssetsForPlayer];
    self.musicControllerView.songTimeProgress.progress = 0.5f;
    self.tableView.dataSource = self;
    __weak SavedMusicViewController *weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0 / 60.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateProgressBar];
    }];
    
}

- (void)updateProgressBar {
    double time = CMTimeGetSeconds(self.player.currentTime);
    double duration = CMTimeGetSeconds(self.player.currentItem.duration);
    [self.musicControllerView.songTimeProgress setProgress:(time/duration) animated:YES];
}


- (void)loadAssetsForPlayer {
    NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    NSArray* dirs = [NSFileManager.defaultManager contentsOfDirectoryAtURL:sourcePath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"mp3"]) {
            [self.mp3Files addObject:filename];
            [self.isSongPlaying addObject:[NSNumber numberWithInt:0]];
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
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    SavedMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"savedMusicCell" forIndexPath:indexPath];
    cell.musicTitle.text = [[self.mp3Files[indexPath.row] lastPathComponent] stringByDeletingPathExtension];
    cell.playButton.tag = indexPath.row;

    
    return cell;
}
- (IBAction)cellPlayButtonTap:(UIButton*)button {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.mp3Files[button.tag] options:nil];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    if (self.isSongPlaying[button.tag] == [NSNumber numberWithInt:1]) {
        [self.player pause];
        self.isPlayerPlaying = NO;
//        [button setTitle:@"Play" forState:UIControlStateNormal];
        self.isSongPlaying[button.tag] = [NSNumber numberWithInt:0];
    }
    else {
        if (![((AVURLAsset*)self.player.currentItem.asset).URL isEqual:asset.URL]) {
            [self.player replaceCurrentItemWithPlayerItem:item];
        }
        self.musicControllerView.songName.text = [[self.mp3Files[button.tag] lastPathComponent] stringByDeletingPathExtension];
        self.isSongPlaying[button.tag] = [NSNumber numberWithInt:1];
        [self.player play];
        self.isPlayerPlaying = YES;
        [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
//        [button setTitle:@"Pause" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

- (IBAction)musicControllerPlayBtnTap:(id)sender {
    if (self.isPlayerPlaying) {
        [self.player pause];
        self.isPlayerPlaying = NO;
        [self.musicControllerView.playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else {
        [self.player play];
        self.isPlayerPlaying = YES;
        [self.musicControllerView.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

- (IBAction)previousBtnTap:(id)sender {
//    NSInteger index = [self.mp3Files indexOfObject:self.player.currentItem.asset];
//    AVURLAsset *asset = [AVURLAsset alloc] initWithURL:self.mp3Files[index-1] options:<#(nullable NSDictionary<NSString *,id> *)#>
}

- (IBAction)nextBtnTap:(id)sender {
    
}


//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return self.musicControllerView;
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 90.0f;
//}





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
