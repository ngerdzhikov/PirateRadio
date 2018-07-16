//
//  UserPreferencesTableViewCell.h
//  PirateRadio
//
//  Created by A-Team User on 6.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface UserPreferencesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *preferenceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *preferenceSwitch;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;

@property (weak, nonatomic) id<ProfileUserPreferencesDelegate> profileDelegate;

@end
