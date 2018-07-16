//
//  UserPreferencesTableViewCell.m
//  PirateRadio
//
//  Created by A-Team User on 6.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "UserPreferencesTableViewCell.h"
#import "Constants.h"

@implementation UserPreferencesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setSwitchStateForUserPreferences];
    [self.preferenceSwitch addTarget:self action:@selector(switchToggle:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)switchToggle:(UISwitch *)sender {
    if ([self.reuseIdentifier isEqualToString:@"userPreferencesCell1"]) {
        [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX];
        [NSUserDefaults.standardUserDefaults synchronize];
        [NSNotificationCenter.defaultCenter postNotificationName:@"disableSwitch" object:nil];
    }
    else if ([self.reuseIdentifier isEqualToString:@"userPreferencesCell2"]) {
        [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX_VIA_CELLULAR];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    else if ([self.reuseIdentifier isEqualToString:@"userPreferencesCell3"]) {
        [NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:USER_DEFAULTS_THEME];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (void)setSwitchStateForUserPreferences {
    BOOL isOn = NO;
    if ([self.reuseIdentifier isEqualToString:@"userPreferencesCell1"]) {
        isOn = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX];
    }
    else if ([self.reuseIdentifier isEqualToString:@"userPreferencesCell2"]) {
        isOn = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX_VIA_CELLULAR];
    }
    else if ([self.reuseIdentifier isEqualToString:@"userPreferencesCell3"]) {
        isOn = [NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_THEME];
    }
    [self.preferenceSwitch setOn:isOn]; 
}

- (IBAction)galleryButtonTap:(id)sender {
    [self.profileDelegate changeProfilePicture];
}

- (IBAction)changeNameButtonTap:(id)sender {
    [self.profileDelegate changeName];
}

- (IBAction)changePasswordButtonTap:(id)sender {
    [self.profileDelegate changePassword];
}


@end
