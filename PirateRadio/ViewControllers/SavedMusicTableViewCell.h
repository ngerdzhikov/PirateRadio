//
//  SavedMusicTableViewCell.h
//  PirateRadio
//
//  Created by A-Team User on 14.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHRadialProgressView;

@interface SavedMusicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *musicTitle;
@property (weak, nonatomic) IBOutlet UIView *progressPlaceHolderView;

@end
