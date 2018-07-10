//
//  Toast.h
//  PirateRadio
//
//  Created by A-Team User on 3.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Toast : NSObject

+ (void)displayStandardToastWithMessage:(NSString *)toastMessage;
+ (void)displayToastWithMessage:(NSString *)toastMessage andDuration:(double)duration;
+ (void)displayToastWithMessage:(NSString *)toastMessage andDuration:(double)duration andCenterPoint:(CGPoint)center;

@end
