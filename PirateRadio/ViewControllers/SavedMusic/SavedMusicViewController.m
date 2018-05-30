//
//  SavedMusicViewController.m
//  PirateRadio
//
//  Created by A-Team User on 28.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SavedMusicViewController.h"
#import "SavedMusicTableViewController.h"
#import "MusicPlayerViewController.h"

@interface SavedMusicViewController ()

@property (strong, nonatomic) SavedMusicTableViewController *savedMusicTableView;
@property (strong, nonatomic) MusicPlayerViewController *musicControllerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicPlayerHeightConstraint;
@property CGFloat musicPlayerHeight;
@property CGFloat tableViewHeight;

@end

@implementation SavedMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.savedMusicTableView = self.childViewControllers.firstObject;
    self.musicControllerView = self.childViewControllers.lastObject;
    self.musicControllerView.savedMusicTableDelegate = self.savedMusicTableView;
    self.savedMusicTableView.musicPlayerDelegate = self.musicControllerView;
    
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
        if (newCenter.y >= self.tableViewHeight + (self.musicPlayerHeight / 2) && newCenter.y <= self.view.frame.size.height) {
            recognizer.view.center = newCenter;
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.center.y > self.tableViewHeight + self.musicPlayerHeight) {
            recognizer.view.center = CGPointMake(recognizer.view.center.x, self.view.frame.size.height);
        }
        else {
            recognizer.view.center = CGPointMake(recognizer.view.center.x, self.tableViewHeight + self.musicPlayerHeight/2);
        }
        CGRect newTableViewFrame = self.tableViewContainer.frame;
        newTableViewFrame.size.height = recognizer.view.center.y - (self.musicPlayerHeight / 2);
        self.tableViewContainer.frame = newTableViewFrame;
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    [UIView commitAnimations];
}


@end
