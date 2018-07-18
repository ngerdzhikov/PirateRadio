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
#import "Toast.h"
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
    self.tableViewDelegate.profileDelegate = self;
    
    UILongPressGestureRecognizer *imageLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeProfilePicture)];
    [self.userImageView addGestureRecognizer:imageLongPressRecognizer];
    self.userImageView.userInteractionEnabled = YES;

    BOOL isLogged = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_IS_LOGGED];
    if (isLogged) {
        NSInteger userID = [NSUserDefaults.standardUserDefaults integerForKey:USER_DEFAULT_LOGGED_USER_ID];
        self.userModel = [UserModel objectsWhere:@"userID = %ld", userID].firstObject;
        [self updateUIForUserModel:self.userModel];
    }
    
    [self setDropboxButtonDependingOnAuthorization];
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
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(setDropboxButtonDependingOnAuthorization) name:@"dropboxAuthorization" object:nil];
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                                                  
                                              }];
                                          }];
    }
}

- (void)setDropboxButtonDependingOnAuthorization {
    if ([self isLoggedInDropbox]) {
        [self.dropboxButton setTitle:@"Dropbox Sign out" forState:UIControlStateNormal];
    }
    else {
        [self.dropboxButton setTitle:@"Dropbox Sign in" forState:UIControlStateNormal];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX];
    }
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"dropboxAuthorization" object:nil];
}

- (BOOL)isLoggedInDropbox {
    return [DBClientsManager authorizedClient] != nil;
}

- (void)presentLoginVC {
    LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    loginVC.profileDelegate = self;
    self.definesPresentationContext = YES;
    [loginVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)changeProfilePicture {
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
        fileURL = [[[fileURL URLByAppendingPathComponent:@"profile images"] URLByAppendingPathComponent:self.userModel.userID.stringValue] URLByAppendingPathExtension:@"jpeg"];
        
        [imageData writeToURL:fileURL atomically:NO];
    }
    
    
    self.userImageView.image = [UIImage imageWithData:imageData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeName {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change username" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New username";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertController.textFields.firstObject.text.length > 3) {
            [RLMRealm.defaultRealm transactionWithBlock:^{
                self.userModel.username = alertController.textFields.firstObject.text;
            }];
            [self updateUIForUserModel:self.userModel];
            [self.view makeToast:@"Username changed!"];
        }
        else {
            [self.view makeToast:@"New username too short!"];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changePassword {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change password" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Old password";
        textField.secureTextEntry = YES;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New password";
        textField.secureTextEntry = YES;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Confirm new password";
        textField.secureTextEntry = YES;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([alertController.textFields.firstObject.text isEqualToString:self.userModel.password]) {
            if (![alertController.textFields.firstObject.text isEqualToString:alertController.textFields[1].text] && ![alertController.textFields.firstObject.text isEqualToString:alertController.textFields.lastObject.text]) {
                if ([alertController.textFields[1].text isEqualToString:alertController.textFields[2].text]) {
                    if (alertController.textFields[1].text.length > 3) {
                        [RLMRealm.defaultRealm transactionWithBlock:^{
                            self.userModel.password = alertController.textFields.lastObject.text;
                        }];
                        [self updateUIForUserModel:self.userModel];
                        [self.view makeToast:@"Password changed!"];
                    }
                    else {
                        [self.view makeToast:@"New password too short!"];
                    }
                }
                else {
                    [self.view makeToast:@"Please confirm password!"];
                }
            }
            else {
                [self.view makeToast:@"New password is the same as old password!"];
            }
        }
        else {
            [self.view makeToast:@"Wrong old password!"];
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
