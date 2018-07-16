//
//  LoginViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "LoginViewController.h"
#import "CoreData/CoreData.h"
#import "ProfileViewController.h"
#import "DataBase.h"
#import "Constants.h"
#import "UserModel.h"
#import "UIView+Toast.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UIView *smallerContainerView;

@property BOOL isLogged;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.signUpLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(signUpLabelTap)];
    [self.signUpLabel addGestureRecognizer:tapGesture];
    self.isLogged = false;
    
    self.userNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    self.smallerContainerView.layer.cornerRadius = 15;
}

- (void)signUpLabelTap {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Register" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"Username";
        textField.text = self.userNameTextField.text;
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"Password";
        textField.text = self.passwordTextField.text;
        textField.secureTextEntry = YES;
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"Confirm password";
        textField.secureTextEntry = YES;
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm password" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.userNameTextField.text = alertController.textFields.firstObject.text;
        if ([alertController.textFields[1].text isEqualToString:alertController.textFields.lastObject.text]) {
            self.passwordTextField.text = alertController.textFields.lastObject.text;
            BOOL shouldContinue = YES;
            NSString *messageToDisplay;
            if ([self.userNameTextField.text isEqualToString:@""] && shouldContinue) {
                messageToDisplay = @"Please enter a username.";
                shouldContinue = NO;
            }
            else if ([self.passwordTextField.text isEqualToString:@""] && shouldContinue) {
                messageToDisplay = @"Please enter a password.";
                shouldContinue = NO;
            }
            else if (self.userNameTextField.text.length < 4 && shouldContinue) {
                messageToDisplay = @"Please enter longer username.";
                shouldContinue = NO;
            }
            else if (self.userNameTextField.text.length < 4 && shouldContinue) {
                messageToDisplay = @"Please enter longer password.";
                shouldContinue = NO;
            }
            else {
                DataBase *db = [[DataBase alloc] init];
                if ([db doesUserWithUsernameExists:self.userNameTextField.text]) {
                    shouldContinue = NO;
                    messageToDisplay = @"User with this username already exists";
                }
                else {
                    UserModel *user = [db newUserWithUsername:self.userNameTextField.text andPassword:self.passwordTextField.text];
                    self.isLogged = YES;
                    [NSUserDefaults.standardUserDefaults setBool:YES forKey:USER_DEFAULTS_IS_LOGGED];
                    [NSUserDefaults.standardUserDefaults setURL:user.objectID forKey:USER_DEFAULT_LOGGED_OBJECT_ID];
                    [self.profileDelegate loggedSuccessfulyWithUserModel:user];
                }
            }
            if (!shouldContinue) {
                [self.view makeToast:messageToDisplay];
            }
        }
        else {
            [self.view makeToast:@"Please confirm password"];
        }

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{
        for (UITextField *textField in alertController.textFields) {
            textField.superview.backgroundColor = [UIColor clearColor];
            textField.backgroundColor = [UIColor clearColor];
        }
    }];
}

- (IBAction)loginButtonTap:(id)sender {
    NSString *username = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    [self authenticateUsername:username andPassword:password];
}

- (void)authenticateUsername:(NSString *)username andPassword:(NSString *)password {
    DataBase *db = [[DataBase alloc] init];
    UserModel *userModel = [db userModelForUsername:username];
    if (userModel) {
        if ([userModel.password isEqualToString:password]) {
            self.isLogged = YES;
            [NSUserDefaults.standardUserDefaults setBool:YES forKey:USER_DEFAULTS_IS_LOGGED];
            [NSUserDefaults.standardUserDefaults setURL:userModel.objectID forKey:USER_DEFAULT_LOGGED_OBJECT_ID];
            [self.profileDelegate loggedSuccessfulyWithUserModel:userModel];
        }
    }
    
    if (!self.isLogged) {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        [window.rootViewController.view makeToast:@"Invalid username or password"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else {
        [self loginButtonTap:nil];
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
