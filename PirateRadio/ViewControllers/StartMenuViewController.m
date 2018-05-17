//
//  StartMenuViewController.m
//  PirateRadio
//
//  Created by A-Team User on 17.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "StartMenuViewController.h"
#import "SavedMusicViewController.h"
#import "SearchTableViewController.h"

@interface StartMenuViewController ()

@end

@implementation StartMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)savedMusicButtonTap:(id)sender {
    SavedMusicViewController *savedMusicViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"savedMusicViewController"];
    [self.navigationController pushViewController:savedMusicViewController animated:NO];
}

- (IBAction)youtubeSearchButtonTap:(id)sender {
    SearchTableViewController *searchTableViewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"searchTableViewController"];
    [self.navigationController pushViewController:searchTableViewController animated:YES];
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
