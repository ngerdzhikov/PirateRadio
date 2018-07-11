//
//  SavedMusicViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SongListPlusPlayerViewController.h"
#import "SavedMusicTableViewController.h"
#import "MusicPlayerViewController.h"
#import "PlaylistModel.h"
#import "DataBase.h"
#import "LocalSongModel.h"
#import "SongListFromPlaylistTableViewController.h"
#import "CoreData/CoreData.h"

@interface SongListPlusPlayerViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) SavedMusicTableViewController *songListViewController;
@property (strong, nonatomic) MusicPlayerViewController *playerViewController;
@property CGFloat musicPlayerHeight;

@end

@implementation SongListPlusPlayerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.playerViewController = self.childViewControllers.firstObject;
    [self addViewControllerToContainerView];
    
    self.songListViewController.musicPlayerDelegate = self.playerViewController;
    self.playerViewController.songListDelegate = self.songListViewController;
    
    if (self.songListViewController.allSongs.firstObject && self.playerViewController.nowPlaying == nil) {
        [self.playerViewController prepareSong:self.songListViewController.allSongs.firstObject];
    }
    
    self.navigationItem.searchController = self.songListViewController.songListSearchController;
    self.navigationItem.searchController.searchBar.delegate = self.songListViewController;
    self.navigationItem.searchController.dimsBackgroundDuringPresentation = NO;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicControllerPan:)];
    [self.musicPlayerContainer addGestureRecognizer:pan];
    self.musicPlayerHeight = self.musicPlayerContainer.frame.size.height;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMusicControllerPan:(UIPanGestureRecognizer *)recognizer {
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) | ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        CGPoint translatedPoint = [recognizer translationInView:recognizer.view.superview];
        CGFloat animationDuration = 0.1;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        CGPoint newCenter = CGPointMake(self.view.frame.size.width/2, recognizer.view.center.y + translatedPoint.y);
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (newCenter.y >= (self.tabBarController.tabBar.frame.origin.y - self.musicPlayerHeight / 2) && newCenter.y <= self.tabBarController.tabBar.frame.origin.y + self.musicPlayerHeight / 6) {
                recognizer.view.center = newCenter;
            }
        }
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (recognizer.view.center.y > self.tabBarController.tabBar.frame.origin.y - self.musicPlayerHeight / 4) {
                recognizer.view.center = CGPointMake(recognizer.view.center.x, self.tabBarController.tabBar.frame.origin.y + self.musicPlayerHeight / 6);
            }
            else {
                recognizer.view.center = CGPointMake(recognizer.view.center.x, self.tabBarController.tabBar.frame.origin.y - self.musicPlayerHeight / 2);
            }
        }
        CGRect newTableViewFrame = self.tableViewContainer.frame;
        newTableViewFrame.size.height = recognizer.view.center.y - (self.musicPlayerHeight / 2);
        self.tableViewContainer.frame = newTableViewFrame;
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
        
        [UIView commitAnimations];
    }
    

}

+(instancetype)songListPlusPlayerViewControllerWithPlaylist:(PlaylistModel *)playlist {
    SongListPlusPlayerViewController *songListPlusPlayerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SongListPlusPlayer"];
    songListPlusPlayerVC.playlist = playlist;
    return songListPlusPlayerVC;
}

- (void)addViewControllerToContainerView {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (self.playlist) {
        
        SongListFromPlaylistTableViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"songListFromPlaylistTableViewController"];
        vc.playlist = self.playlist;
        self.songListViewController = vc;
        self.songListViewController.allSongs = self.playlist.songs;
        
        self.navigationItem.title = self.playlist.name;
        UIBarButtonItem *addSongsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self.songListViewController action:@selector(addSongInPlaylist)];
        UIBarButtonItem *editSongsButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self.songListViewController action:@selector(editSongs:)];
        self.navigationItem.rightBarButtonItems = @[addSongsButton, editSongsButton];
        
    }
    else {
        self.songListViewController = [storyBoard instantiateViewControllerWithIdentifier:@"savedMusicViewController"];
        UIBarButtonItem *editSongsButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self.songListViewController action:@selector(editSongs:)];
        self.navigationItem.rightBarButtonItems = @[editSongsButton,];
        self.songListViewController.allSongs = [self songsFromDisk];
    }
    
    
    self.songListViewController.view.frame = self.tableViewContainer.bounds;
    [self.songListViewController willMoveToParentViewController:self];
    [self.tableViewContainer addSubview:self.songListViewController.view];
    [self addChildViewController:self.songListViewController];
    [self.songListViewController didMoveToParentViewController:self];
}

- (NSMutableArray<LocalSongModel *> *)songsFromDisk {
    
    DataBase *db = [[DataBase alloc] init];
    
    NSMutableArray<LocalSongModel *> * songs = [[NSMutableArray alloc] init];
    NSURL *sourcePath = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    sourcePath = [sourcePath URLByAppendingPathComponent:@"songs"];
    
    NSArray *allSongs = db.allSongs;
    for (NSManagedObject *obj in allSongs) {
        NSArray *keys = [[[obj entity] attributesByName] allKeys];
        NSDictionary *dictionary = [obj dictionaryWithValuesForKeys:keys];
        NSString *songLastPathComponent = [dictionary valueForKey:@"identityName"];
        NSURL *localURL = [sourcePath URLByAppendingPathComponent:songLastPathComponent];
        LocalSongModel *song = [[LocalSongModel alloc] initWithLocalSongURL:localURL];
        song.videoURL = [dictionary valueForKey:@"videoURL"];
        song.duration = [dictionary valueForKey:@"duration"];
        [songs addObject:song];
    }
    
    return songs;
}



@end
