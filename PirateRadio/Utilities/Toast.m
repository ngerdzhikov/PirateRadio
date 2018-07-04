//
//  Toast.m
//  PirateRadio
//
//  Created by A-Team User on 3.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "Toast.h"
#import "UIKit/UIKit.h"

@implementation Toast

+ (void)displayStandardToastWithMessage:(NSString *)toastMessage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        UILabel *toastView = [[UILabel alloc] init];
        toastView.text = toastMessage;
        toastView.font = [UIFont systemFontOfSize:15];
        toastView.textColor = [UIColor whiteColor];
        toastView.backgroundColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width/2.0, 30);
        toastView.layer.cornerRadius = 5;
        toastView.layer.masksToBounds = YES;
        toastView.center = CGPointMake(keyWindow.center.x, keyWindow.frame.size.height - 100);
        
        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 1.0f
                              delay: 1.5
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             toastView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [toastView removeFromSuperview];
                         }
         ];
    }];
}

+ (void)displayToastWithMessage:(NSString *)toastMessage andDuration:(double)duration {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        UILabel *toastView = [[UILabel alloc] init];
        toastView.text = toastMessage;
        toastView.font = [UIFont systemFontOfSize:15];
        toastView.textColor = [UIColor whiteColor];
        toastView.backgroundColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1.0];
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.frame = CGRectMake(0.0, 0.0, keyWindow.frame.size.width/2.0, 30);
        toastView.layer.cornerRadius = 5;
        toastView.layer.masksToBounds = YES;
        toastView.center = CGPointMake(keyWindow.center.x, keyWindow.frame.size.height - 100);
        
        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 1.0f
                              delay: duration
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             toastView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [toastView removeFromSuperview];
                         }
         ];
    }];
}

@end
