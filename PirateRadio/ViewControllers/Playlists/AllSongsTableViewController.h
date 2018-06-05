//
//  AllSongsTableViewController.h
//  PirateRadio
//
//  Created by A-Team User on 5.06.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaylistModel;

@interface AllSongsTableViewController : UITableViewController

@property (strong, nonatomic) PlaylistModel *playlist;

@end
