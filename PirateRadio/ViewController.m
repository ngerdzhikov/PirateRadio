//
//  ViewController.m
//  PirateRadio
//
//  Created by A-Team User on 9.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (strong, nonatomic) NSDictionary *jsonDict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 };
    [self.youtubePlayer loadWithVideoId:@"XR7Ev14vUh8" playerVars:playerVars];
    self.youtubePlayer.delegate = self;
    NSData *data;
    NSError *error;
    self.jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
    }
    else {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
