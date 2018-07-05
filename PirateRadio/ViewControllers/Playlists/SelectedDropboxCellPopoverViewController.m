//
//  SelectedDropboxCellPopoverViewController.m
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SelectedDropboxCellPopoverViewController.h"
#import "DropBox.h"

@interface SelectedDropboxCellPopoverViewController ()

@end

@implementation SelectedDropboxCellPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)copyMp3LinkButtonTap:(id)sender {
    
}

- (IBAction)downloadButtonTap:(id)sender {
    [DropBox downloadSongWithName:self.songName];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
