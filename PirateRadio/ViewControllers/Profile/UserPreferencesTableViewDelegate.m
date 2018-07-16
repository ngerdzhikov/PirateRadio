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
    NSString *cellIdentifier = [@"userPreferencesCell" stringByAppendingString:[NSString stringWithFormat:@"%ld",(indexPath.row+1)]];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 1) {
        if ([NSUserDefaults.standardUserDefaults boolForKey:USER_DEFAULTS_UPLOAD_TO_DROPBOX]) {
            cell.contentView.alpha = 1;
            cell.userInteractionEnabled = YES;
        }
        else {
            cell.contentView.alpha = 0.33;
            cell.userInteractionEnabled = NO;
        }
    }
    cell.profileDelegate = self.profileDelegate;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        return @"User Preferences";
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
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
