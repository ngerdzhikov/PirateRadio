//
//  UserPreferencesTableViewCell.h
//  PirateRadio
//
//  Created by A-Team User on 6.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPreferencesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *preferenceLabel;
@property (weak, nonatomic) IBOutlet UISwitch *preferenceSwitch;

@end
