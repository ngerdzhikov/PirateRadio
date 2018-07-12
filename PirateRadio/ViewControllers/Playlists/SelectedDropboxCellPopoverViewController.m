//
//  SelectedDropboxCellPopoverViewController.m
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SelectedDropboxCellPopoverViewController.h"
#import "Reachability.h"
#import "Toast.h"
#import "DropBox.h"

@interface SelectedDropboxCellPopoverViewController ()
@property (strong, nonatomic) Reachability *reachability;
@end

@implementation SelectedDropboxCellPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reachability = Reachability.reachabilityForInternetConnection;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)copyMp3LinkButtonTap:(id)sender {
    if (self.reachability.isReachable) {
       [DropBox shareableLinkForSongName:self.songName];
    }
    else {
        [self.presentingViewController.view makeToast:@"No internet connection"];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)downloadButtonTap:(id)sender {
    if (self.reachability.isReachable) {
        [DropBox downloadSongWithName:self.songName];
    }
    else {
        [self.presentingViewController.view makeToast:@"No internet connection"];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
