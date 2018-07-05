//
//  ProfileViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "Constants.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *dropboxButton;
@property (weak, nonatomic) IBOutlet UISwitch *dropboxSwitch;
@property (strong, nonatomic) NSString *username;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isLogged = [NSUserDefaults.standardUserDefaults boolForKey:@"isLogged"];
    if (!isLogged) {
        LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [loginVC setModalPresentationStyle:UIModalPresentationCurrentContext];
        [self presentViewController:loginVC animated:YES completion:^{
            
        }];
    }    
    if ([self isLoggedInDropbox]) {
        [self.dropboxButton setTitle:@"Dropbox Sign out" forState:UIControlStateNormal];
    }
    else {
        [self.dropboxButton setTitle:@"Dropbox Sign in" forState:UIControlStateNormal];
    }
    [self.dropboxSwitch setOn:[NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.username = [NSUserDefaults.standardUserDefaults valueForKey:@"loggedUsername"];
    self.usernameLabel.text = [NSString stringWithFormat:@"Hello %@!", self.username];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutButtonTap:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isLogged"];
    [NSUserDefaults.standardUserDefaults setValue:@"" forKey:@"loggedUsername"];
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [loginVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:loginVC animated:YES completion:^{

    }];
}

- (IBAction)dropboxButtonTap:(id)sender {
    if ([self isLoggedInDropbox]) {
        [DBClientsManager unlinkAndResetClients];
        [self.dropboxButton setTitle:@"Dropbox Sign in" forState:UIControlStateNormal];
    }
    else {
        [self.dropboxButton setTitle:@"Dropbox Sign out" forState:UIControlStateNormal];
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:[[self class] topMostController]
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                                  
                                              }];
                                          }];
    }
    
}
- (IBAction)dropboxSwitchToggle:(UISwitch *)sender {
    [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX];
}


- (BOOL)isLoggedInDropbox {
    return [DBClientsManager authorizedClient] != nil;
}

+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}




@end
