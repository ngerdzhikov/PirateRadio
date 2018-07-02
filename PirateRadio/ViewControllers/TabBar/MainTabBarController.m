//
//  MainTabBarController.m
//  PirateRadio
//
//  Created by A-Team User on 13.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "MainTabBarController.h"
#import "Constants.h"
#import "SearchTableViewController.h"

@interface MainTabBarController ()

@property NSUInteger downloadedSongs;

@property (strong, nonatomic) NSArray *allVCs;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSongDownloaded:) name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
    self.downloadedSongs = 0;
    
    self.allVCs = self.viewControllers;
    
    [self checkIfSegueDone];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkIfSegueDone {
    BOOL segueDone = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_SEGUE_DONE];
    
    if (!segueDone) {
        [self setViewControllers:@[self.allVCs[0],self.allVCs[3]]];
    }
    else {
        [self setViewControllers:self.allVCs];
    }
}

- (void)newSongDownloaded:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.selectedIndex != 1) {
            self.downloadedSongs++;
            self.viewControllers[1].tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.downloadedSongs];
        }
    });
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([item.title isEqualToString:@"Music"]) {
        item.badgeValue = nil;
        self.downloadedSongs = 0;
    }
}


@end
