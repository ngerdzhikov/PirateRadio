//
//  ProfileViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "DataBase.h"
#import "Constants.h"
#import "UserModel.h"
#import "UserPreferencesTableViewDelegate.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *dropboxButton;
@property (weak, nonatomic) IBOutlet UITableView *preferencesTableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) UserModel *userModel;
@property (strong, nonatomic) UserPreferencesTableViewDelegate *tableViewDelegate;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableViewDelegate = [[UserPreferencesTableViewDelegate alloc] initWithTableView:self.preferencesTableView];
    
    if ([self isLoggedInDropbox]) {
        [self.dropboxButton setTitle:@"Dropbox Sign out" forState:UIControlStateNormal];
    }
    else {
        [self.dropboxButton setTitle:@"Dropbox Sign in" forState:UIControlStateNormal];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX];
    }
    UILongPressGestureRecognizer *imageLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentGalleryImagePicker:)];
    [self.userImageView addGestureRecognizer:imageLongPressRecognizer];
    self.userImageView.userInteractionEnabled = YES;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(presentGalleryImagePicker:) name:@"galleryButtonTap" object:nil];
}

- (void)viewDidLayoutSubviews {
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height/2;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.userImageView.layer.borderWidth = 1.0f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL isLogged = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_IS_LOGGED];
    if (!isLogged && !self.dismissingPresentedViewController) {
        [self presentLoginVC];
    }
    else {
        NSString *username = [NSUserDefaults.standardUserDefaults objectForKey:USER_DEFAULTS_LOGGED_USERNAME];
        DataBase *db = [[DataBase alloc] init];
        self.userModel = [db userModelForUsername:username];
        
    }
    self.dismissingPresentedViewController = NO;
    self.usernameLabel.text = [NSString stringWithFormat:@"Hello %@!", self.userModel.username];
    self.userImageView.image = self.userModel.profileImage;
    if (!self.userImageView.image) {
        self.userImageView.image = [UIImage imageNamed:@"default_user_icon"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOutButtonTap:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:USER_DEFAULTS_IS_LOGGED];
    [self presentLoginVC];
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
                                                  if ([self isLoggedInDropbox]) {
                                                      [self.dropboxButton setTitle:@"Dropbox Sign out" forState:UIControlStateNormal];
                                                  }
                                                  else {
                                                      [self.dropboxButton setTitle:@"Dropbox Sign in" forState:UIControlStateNormal];
                                                  }
                                              }];
                                          }];
    }
    
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

- (void)presentLoginVC {
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [loginVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)presentGalleryImagePicker:(NSNotification *)notification {
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = YES;
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSURL *imageURL = [info objectForKey:UIImagePickerControllerImageURL];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    if (imageData) {
        NSURL *fileURL = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        fileURL = [[[fileURL URLByAppendingPathComponent:@"profile images"] URLByAppendingPathComponent:self.userModel.username] URLByAppendingPathExtension:@"jpeg"];
        
        [imageData writeToURL:fileURL atomically:NO];
    }
    
    
    self.userImageView.image = [UIImage imageWithData:imageData];
    DataBase *db = [[DataBase alloc] init];
    [db updateUserProfileImageURL:imageURL forUserModel:self.userModel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
