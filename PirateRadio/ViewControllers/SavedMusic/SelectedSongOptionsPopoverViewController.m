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
#import "UIView+Toast.h"

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
    DataBase *db = [[DataBase alloc] init];
    
    NSURL *videoURL = [db videoURLForLocalSongModel:self.song];
    
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
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
