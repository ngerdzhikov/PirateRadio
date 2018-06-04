//
//  SavedMusicViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SongListPlusPlayerViewController.h"
#import "SavedMusicTableViewController.h"
#import "MusicPlayerViewController.h"

@interface SongListPlusPlayerViewController ()

@property (strong, nonatomic) SavedMusicTableViewController *songListViewController;
@property (strong, nonatomic) MusicPlayerViewController *playerViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicPlayerHeightConstraint;
@property CGFloat musicPlayerHeight;
@property CGFloat tableViewHeight;

@end

@implementation SongListPlusPlayerViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.songListViewController = self.childViewControllers.firstObject;
    self.playerViewController = self.childViewControllers.lastObject;
    
    self.songListViewController.musicPlayerDelegate = self.playerViewController;
    self.playerViewController.songListDelegate = self.songListViewController;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicControllerPan:)];
    [self.musicPlayerContainer addGestureRecognizer:pan];
    self.musicPlayerHeight = self.musicPlayerContainer.frame.size.height;
    self.tableViewHeight = self.tableViewContainer.frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMusicControllerPan:(UIPanGestureRecognizer *)recognizer {
    CGFloat velocityY = (0.2*[recognizer velocityInView:self.view].y);
    CGPoint translatedPoint = [recognizer translationInView:recognizer.view.superview];
    CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGPoint newCenter = CGPointMake(self.view.frame.size.width/2, recognizer.view.center.y + translatedPoint.y);
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"newCenter y = %lf", newCenter.y);
        if (newCenter.y >= (self.tabBarController.tabBar.frame.origin.y - self.musicPlayerHeight / 2) && newCenter.y <= self.tabBarController.tabBar.frame.origin.y + self.musicPlayerHeight / 6) {
            recognizer.view.center = newCenter;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.center.y > self.tabBarController.tabBar.frame.origin.y - self.musicPlayerHeight / 4) {
            recognizer.view.center = CGPointMake(recognizer.view.center.x, self.tabBarController.tabBar.frame.origin.y + self.musicPlayerHeight / 6);
        }
        else {
//            recognizer.view.center = CGPointMake(recognizer.view.center.x, self.tableViewHeight + self.musicPlayerHeight/2);
            recognizer.view.center = CGPointMake(recognizer.view.center.x, self.tabBarController.tabBar.frame.origin.y - self.musicPlayerHeight / 2);
        }
        
    }
    CGRect newTableViewFrame = self.tableViewContainer.frame;
    newTableViewFrame.size.height = recognizer.view.center.y - (self.musicPlayerHeight / 2);
    self.tableViewContainer.frame = newTableViewFrame;
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    [UIView commitAnimations];
}


@end
