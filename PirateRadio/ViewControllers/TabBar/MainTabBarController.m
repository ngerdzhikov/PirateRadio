//
//  MainTabBarController.m
//  PirateRadio
//
//  Created by A-Team User on 13.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "MainTabBarController.h"
#import "Constants.h"

@interface MainTabBarController ()

@property NSUInteger downloadedSongs;

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(newSongDownloaded:) name:NOTIFICATION_DOWNLOAD_FINISHED object:nil];
    self.downloadedSongs = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
