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

@end

@implementation SavedMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicControllerPan:)];
    self.savedMusicTableView = self.childViewControllers.firstObject;
    self.musicControllerView = self.childViewControllers.lastObject;
    [self.musicControllerView.view addGestureRecognizer:pan];
    self.musicControllerView.savedMusicTableDelegate = self.savedMusicTableView;
    self.savedMusicTableView.musicPlayerDelegate = self.musicControllerView;
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
    CGRect tableViewFrame = CGRectMake(self.tableViewContainer.frame.origin.x, self.tableViewContainer.frame.origin.y, self.tableViewContainer.frame.size.width, self.view.frame.origin.y - CGRectGetMaxY(self.musicPlayerContainer.frame));
    NSLog(@"newCenter y = %lf", newCenter.y);
    if (newCenter.y >= ((CGRectGetMinY(self.tableViewContainer.frame) - self.musicPlayerContainer.frame.size.height) && newCenter.y <= (self.view.frame.size.height - 50))) {
        recognizer.view.center = newCenter;
        self.tableViewContainer.frame = tableViewFrame;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        recognizer.view.center = CGPointMake(self.view.frame.size.width/2, (CGRectGetMaxY(self.tableViewContainer.frame) + (self.musicPlayerContainer.frame.size.height/2)));
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    [UIView commitAnimations];
}


@end
