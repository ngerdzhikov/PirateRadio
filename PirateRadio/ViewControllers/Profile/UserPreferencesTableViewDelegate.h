//
//  UserPreferencesTableViewDelegate.h
//  PirateRadio
//
//  Created by A-Team User on 6.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface UserPreferencesTableViewDelegate : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
