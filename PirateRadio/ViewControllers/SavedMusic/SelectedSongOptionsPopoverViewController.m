//
//  SelectedSongOptionsPopoverViewController.m
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SelectedSongOptionsPopoverViewController.h"
#import "LocalSongModel.h"
#import "DataBase.h"
#import "DropBox.h"
#import "Toast.h"

@interface SelectedSongOptionsPopoverViewController ()

@end

@implementation SelectedSongOptionsPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)copyVideoLinkButtonTap:(id)sender {    
    NSURL *videoURL = self.song.videoURL;
    
    if ([videoURL.absoluteString isEqualToString:@""]) {
        [self.presentingViewController.view makeToast:@"This song doesn't have a video url"];
    }
    else {
        [UIPasteboard generalPasteboard].string = videoURL.absoluteString;
        [self.presentingViewController.view makeToast:@"Video url copied!"];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)uploadToDropboxButtonTap:(id)sender {
    BOOL doesExist = [DropBox doesSongExists:self.song];
    
    if (doesExist) {
        [self.presentingViewController.view makeToast:@"File already exists in dropbox"];
    }
    else {
        [DropBox uploadLocalSong:self.song];
        [DropBox uploadArtworkForLocalSong:self.song];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (IBAction)shareSongButtonTap:(id)sender {
    NSURL *url = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingString:self.song.properMusicTitle] stringByAppendingString:@".mp3"]];
    
    NSData *data = [NSData dataWithContentsOfURL:self.song.localSongURL];
    
    [data writeToURL:url atomically:NO];
    
    NSArray *activityItems = @[url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    [activityVC setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        NSError *errorBlock;
        if([[NSFileManager defaultManager] removeItemAtURL:url error:&errorBlock] == NO) {
            NSLog(@"error deleting file %@",activityError);
            return;
        }
    }];
    UITabBarController *presentingVC = (UITabBarController *)self.presentingViewController;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            activityVC.popoverPresentationController.sourceView = presentingVC.tabBar;
            activityVC.popoverPresentationController.sourceRect = CGRectMake(presentingVC.view.bounds.size.width / 2, presentingVC.view.bounds.size.height / 4, 0, 0);
        }
        [presentingVC presentViewController:activityVC animated:YES completion:nil];
        
    }];
}

@end
