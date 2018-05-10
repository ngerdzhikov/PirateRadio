//
//  ThumbnailModel.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ThumbnailModel.h"

@interface ThumbnailModel ()

@property (strong, nonatomic) NSURL *url;
@property (assign) NSUInteger width;
@property (assign) NSUInteger height;

@end

@implementation ThumbnailModel

- (instancetype)initWithJSONDictionary:(NSDictionary<NSString *, id> *)jsonDict {
    self = [super init];
    if (self) {
        self.url = [jsonDict objectForKey:@"url"];
        self.width = ((NSNumber *)[jsonDict objectForKey:@"width"]).unsignedIntegerValue;
        self.height = ((NSNumber *)[jsonDict objectForKey:@"height"]).unsignedIntegerValue;
    }
    return self;
}

@end
