//
//  ViewController.h
//  PirateRadio
//
//  Created by A-Team User on 9.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"


@interface ViewController : UIViewController<YTPlayerViewDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) IBOutlet YTPlayerView *youtubePlayer;

@end

