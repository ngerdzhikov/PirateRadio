//
//  Toast.h
//  PirateRadio
//
//  Created by A-Team User on 3.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Toast : NSObject

+ (void)displayStandardToastWithMessage:(NSString *)toastMessage;
+ (void)displayToastWithMessage:(NSString *)toastMessage andDuration:(double)duration;

@end
