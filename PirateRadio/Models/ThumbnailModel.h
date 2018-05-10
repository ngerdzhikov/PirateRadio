//
//  ThumbnailModel.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbnailModel : NSObject

- (instancetype)initWithJSONDictionary:(NSDictionary<NSString *, id> *)jsonDict;

@end
