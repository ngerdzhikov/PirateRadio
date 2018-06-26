//
//  ITunesRequestManager.h
//  PirateRadio
//
//  Created by A-Team User on 17.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITunesRequestManager : NSObject

+ (void)makeItunesSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;
+ (void)makeLastFMSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

@end
