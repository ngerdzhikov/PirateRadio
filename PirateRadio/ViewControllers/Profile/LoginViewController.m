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
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissSelf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                if ([db doesUserExists:self.userNameTextField.text]) {
                    shouldContinue = NO;
                    messageToDisplay = @"User with this username already exists";
                }
                else {
                    [db addUser:self.userNameTextField.text forPassword:self.passwordTextField.text];
                    self.isLogged = YES;
                    [NSUserDefaults.standardUserDefaults setValue:self.userNameTextField.text forKey:USER_DEFAULTS_USERNAME];
                    [NSUserDefaults.standardUserDefaults setBool:YES forKey:USER_DEFAULTS_IS_LOGGED];
                    [self checkIfUserIsLogged];
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
    NSArray *users = db.users;
    for (NSManagedObject *user in users) {
        NSArray *keys = [[[user entity] attributesByName] allKeys];
        NSDictionary *userInfo = [user dictionaryWithValuesForKeys:keys];
        if ([[userInfo valueForKey:@"username"] isEqualToString:username]) {
            if ([[userInfo valueForKey:@"password"] isEqualToString:password]) {
                self.isLogged = YES;
                [NSUserDefaults.standardUserDefaults setValue:username forKey:USER_DEFAULTS_USERNAME];
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:USER_DEFAULTS_IS_LOGGED];
                [self checkIfUserIsLogged];
                break;
            }
        }
    }
    if (!self.isLogged) {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        [window.rootViewController.view makeToast:@"Invalid username or password"];
    }
}

- (void)checkIfUserIsLogged {
    if (self.isLogged) {
        [self dismissSelf];
    }
}

- (void)dismissSelf {
    ProfileViewController *profileVC = (ProfileViewController *)self.presentingViewController.childViewControllers.lastObject;
    profileVC.dismissingPresentedViewController = YES;
    [profileVC dismissViewControllerAnimated:YES completion:nil];
}

@end
