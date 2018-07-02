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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property BOOL isLogged;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.isLogged = [NSUserDefaults.standardUserDefaults boolForKey:@"isLogged"];
    self.isLogged = false;
    [self checkIfUserIsLogged];
    // Do any additional setup after loading the view.
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
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject *transaction = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        [transaction setValue:self.userNameTextField.text forKey:@"username"];
        [transaction setValue:self.passwordTextField.text forKey:@"password"];
        
        NSError *err;
        if (![context save:&err]) {
            NSLog(@"Save Error");
        }
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Register Fail" message:messageToDisplay preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:^{
            
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (IBAction)loginButtonTap:(id)sender {
    NSString *username = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    [self authenticateUsername:username andPassword:password];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    context = [delegate managedObjectContext];
    return context;
}

- (void)authenticateUsername:(NSString *)username andPassword:(NSString *)password {
    NSArray *users = DataBase.sharedManager.users;
    for (NSManagedObject *user in users) {
        NSArray *keys = [[[user entity] attributesByName] allKeys];
        NSDictionary *userInfo = [user dictionaryWithValuesForKeys:keys];
        if ([[userInfo valueForKey:@"username"] isEqualToString:username]) {
            if ([[userInfo valueForKey:@"password"] isEqualToString:password]) {
                self.isLogged = YES;
                [NSUserDefaults.standardUserDefaults setValue:username forKey:@"loggedUsername"];
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"isLogged"];
                [self checkIfUserIsLogged];
            }
        }
    }
}

- (void)checkIfUserIsLogged {
    if (self.isLogged) {
        ProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        [self.navigationController setViewControllers:@[profileVC]];
    }
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
