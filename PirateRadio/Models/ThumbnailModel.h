//
//  ThumbnailModel.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbnailModel : NSObject

@property (strong, nonatomic, readonly) NSURL *url;
@property (readonly) NSUInteger width;
@property (readonly) NSUInteger height;

- (instancetype)initWithJSONDictionary:(NSDictionary<NSString *, id> *)jsonDict;

@end
