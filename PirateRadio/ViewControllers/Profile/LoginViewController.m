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
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property BOOL isLogged;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)registerButtonTap:(id)sender {
    BOOL shouldContinue = YES;
    NSString *messageToDisplay;
    if ([self.userNameTextField.text isEqualToString:@""] && shouldContinue) {
        messageToDisplay = @"Please enter a username.";
        shouldContinue = NO;
    }
    if ([self.passwordTextField.text isEqualToString:@""] && shouldContinue) {
        messageToDisplay = @"Please enter a password.";
        shouldContinue = NO;
    }
    if (self.userNameTextField.text.length < 4 && shouldContinue) {
        messageToDisplay = @"Please enter longer username.";
        shouldContinue = NO;
    }
    if (self.userNameTextField.text.length < 4 && shouldContinue) {
        messageToDisplay = @"Please enter longer password.";
        shouldContinue = NO;
    }
    if (shouldContinue) {
        DataBase *db = [[DataBase alloc] init];
        [db addUser:self.userNameTextField.text forPassword:self.passwordTextField.text];
    }
    else {
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        [window.rootViewController.view makeToast:messageToDisplay];
    }
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
