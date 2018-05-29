//
//  SavedMusicTableViewController.h
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "Protocols.h"

@class MusicPlayerViewController;

@interface SavedMusicTableViewController : UITableViewController<SavedMusicTableDelegate>

@property (weak, nonatomic) id<MusicPlayerDelegate> musicPlayerDelegate;

@end
