//
//  ImageCacher.m
//  PirateRadio
//
//  Created by A-Team User on 22.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ImageCacher.h"

@interface ImageCacher ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation ImageCacher

+ (instancetype)sharedInstance {
    static ImageCacher *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)cacheImage:(UIImage *)image forSearchResultId:(NSString *)searchResultId {
    [self.cache setObject:image forKey:searchResultId];
}

- (UIImage *)imageForSearchResultId:(NSString *)searchResultId {
    return [self.cache objectForKey:searchResultId];
}

- (void)clearCache {
    [self.cache removeAllObjects];
}

@end
