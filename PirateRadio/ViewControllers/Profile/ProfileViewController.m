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
    
    UILongPressGestureRecognizer *imageLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentGalleryImagePicker:)];
    [self.userImageView addGestureRecognizer:imageLongPressRecognizer];
    self.userImageView.userInteractionEnabled = YES;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(presentGalleryImagePicker:) name:NOTIFICATION_GALLERY_BUTTON_TAP object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(changeNameButtonTap:) name:NOTIFICATION_CHANGE_NAME_BUTTON_TAP object:nil];

    BOOL isLogged = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_IS_LOGGED];
    if (isLogged) {
        DataBase *db = [[DataBase alloc] init];
        self.userModel = [db userModelForUserID:[NSUserDefaults.standardUserDefaults URLForKey:USER_DEFAULT_LOGGED_OBJECT_ID]];
        [self updateUIForUserModel:self.userModel];
        
    }
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
    if (!isLogged && !self.presentedViewController) {
        [self presentLoginVC];
    }
    
    if ([self isLoggedInDropbox]) {
        [self.dropboxButton setTitle:@"Dropbox Sign out" forState:UIControlStateNormal];
    }
    else {
        [self.dropboxButton setTitle:@"Dropbox Sign in" forState:UIControlStateNormal];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX];
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
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:[[self class] topMostController]
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                                  
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
    loginVC.profileDelegate = self;
    self.definesPresentationContext = YES;
    [loginVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
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
        fileURL = [[[fileURL URLByAppendingPathComponent:@"profile images"] URLByAppendingPathComponent:self.userModel.objectID.lastPathComponent] URLByAppendingPathExtension:@"jpeg"];
        
        [imageData writeToURL:fileURL atomically:NO];
    }
    
    
    self.userImageView.image = [UIImage imageWithData:imageData];
    DataBase *db = [[DataBase alloc] init];
    [db updateUserProfileImageURL:imageURL forUserModel:self.userModel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeNameButtonTap:(NSNotification *)notification {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change name" message:@"New username" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New username";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertController.textFields.firstObject.text.length > 3) {
            DataBase *db = [[DataBase alloc] init];
            [db changeUsername:alertController.textFields.firstObject.text forUserModel:self.userModel];
            self.userModel = [db userModelForUserID:[NSUserDefaults.standardUserDefaults URLForKey:USER_DEFAULT_LOGGED_OBJECT_ID]];
            [self updateUIForUserModel:self.userModel];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loggedSuccessfulyWithUserModel:(UserModel *)userModel {
    self.userModel = userModel;
    [self updateUIForUserModel:userModel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateUIForUserModel:(UserModel *)user {
    self.usernameLabel.text = [NSString stringWithFormat:@"Hello %@!", user.username];
    self.userImageView.image = user.profileImage;
    if (!self.userImageView.image) {
        self.userImageView.image = [UIImage imageNamed:@"default_user_icon"];
    }
}

@end
