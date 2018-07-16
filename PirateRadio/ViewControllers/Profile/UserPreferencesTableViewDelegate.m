//
//  UserPreferencesTableViewDelegate.m
//  PirateRadio
//
//  Created by A-Team User on 6.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "UserPreferencesTableViewDelegate.h"
#import "UserPreferencesTableViewCell.h"
#import "Constants.h"

@implementation UserPreferencesTableViewDelegate

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.tableView.allowsSelection = NO;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(setCellStateForUserPreferences) name:@"disableSwitch" object:nil];
    }
    return self;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UserPreferencesTableViewCell *cell;
    switch (indexPath.row) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"userPreferencesCell1" forIndexPath:indexPath];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"userPreferencesCell2" forIndexPath:indexPath];
            if ([NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX]) {
                cell.contentView.alpha = 1;
                cell.userInteractionEnabled = YES;
            }
            else {
                cell.contentView.alpha = 0.33;
                cell.userInteractionEnabled = NO;
            }
            break;
            
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"userPreferencesCell3" forIndexPath:indexPath];
            break;
            
        case 3:
            cell = [tableView dequeueReusableCellWithIdentifier:@"userPreferencesCell4" forIndexPath:indexPath];
            break;
            
        case 4:
            cell = [tableView dequeueReusableCellWithIdentifier:@"userPreferencesCell5" forIndexPath:indexPath];
            break;
            
        default:
            cell = [[UserPreferencesTableViewCell alloc] init];
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return @"User Preferences";
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)setCellStateForUserPreferences {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UserPreferencesTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX]) {
        cell.contentView.alpha = 1;
        cell.userInteractionEnabled = YES;
    }
    else {
        cell.contentView.alpha = 0.33;
        cell.userInteractionEnabled = NO;
    }
}

@end
