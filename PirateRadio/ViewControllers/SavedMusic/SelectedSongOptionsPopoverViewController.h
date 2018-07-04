//
//  SelectedSongOptionsPopoverViewController.h
//  PirateRadio
//
//  Created by A-Team User on 4.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalSongModel;

@interface SelectedSongOptionsPopoverViewController : UIViewController<UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) LocalSongModel *song;

@end
