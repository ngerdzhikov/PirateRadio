//
//  ThumbnailModel.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Realm.h"

@interface ThumbnailModel : RLMObject

@property (strong, nonatomic, readonly) NSString *urlString;
@property (readonly) NSUInteger width;
@property (readonly) NSUInteger height;

- (instancetype)initWithJSONDictionary:(NSDictionary<NSString *, id> *)jsonDict;
- (instancetype)initWithURL:(NSURL *)url width:(NSNumber *)width height:(NSNumber *)height;
- (NSURL *)url;

@end
