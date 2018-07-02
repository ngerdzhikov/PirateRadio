//
//  AppDelegate.h
//  PirateRadio
//
//  Created by A-Team User on 9.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

