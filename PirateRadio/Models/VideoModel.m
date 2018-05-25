//
//  VideoModel.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "VideoModel.h"
#import "ThumbnailModel.h"
#import "ImageCacher.h"

@interface VideoModel ()

@property (strong, nonatomic) NSString *videoId;
@property (strong, nonatomic) NSDictionary<NSString *,ThumbnailModel *> *thumbnails;
@property (strong, nonatomic) UIImage *thumb;
@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *videoDescription;
@property (strong, nonatomic) NSString *publishedAt;
@property (strong, nonatomic) NSString *channelTitle;

@end

@implementation VideoModel

- (instancetype)initWithSnippet:(NSDictionary<NSString *, id> *)snippet andVideoId:(NSString *)videoId {
    self = [super init];
    if (self)
    {
        self.videoId = videoId;
        self.videoTitle = [snippet objectForKey:@"title"];
        self.videoDescription = [snippet objectForKey:@"description"];
        self.publishedAt = [snippet objectForKey:@"publishedAt"];
        NSDictionary<NSString *, id> *thumbnailsDict = [snippet objectForKey:@"thumbnails"];
        NSMutableDictionary<NSString *,ThumbnailModel *> *temp = [[NSMutableDictionary alloc] init];
        for (NSString *quality in thumbnailsDict.allKeys) {
            NSDictionary *thumbDict = [thumbnailsDict objectForKey:quality];
            ThumbnailModel *thumbnail = [[ThumbnailModel alloc] initWithJSONDictionary:thumbDict];
            [temp setObject:thumbnail forKey:quality];
        }
        self.thumbnails = temp.copy;
        self.thumb = [UIImage imageWithData:[NSData dataWithContentsOfURL:[self.thumbnails objectForKey:@"high"].url]];
        [ImageCacher.sharedInstance cacheImage:self.thumb forVideoId:videoId];
        self.channelTitle = [snippet objectForKey:@"channelTitle"];
    }
    
    return self;
}

- (NSString*)formattedDuration {
    NSInteger hours = 0;
    NSInteger minutes = 0;
    NSInteger seconds = 0;
    NSString *duration = self.videoDuration;
    //Get Time part from ISO 8601 formatted duration http://en.wikipedia.org/wiki/ISO_8601#Durations
    duration = [duration substringFromIndex:[duration rangeOfString:@"T"].location];
    
    while ([duration length] > 1) { //only one letter remains after parsing
        duration = [duration substringFromIndex:1];
        
        NSScanner *scanner = [[NSScanner alloc] initWithString:duration];
        
        NSString *durationPart = [[NSString alloc] init];
        [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] intoString:&durationPart];
        
        NSRange rangeOfDurationPart = [duration rangeOfString:durationPart];
        
        duration = [duration substringFromIndex:rangeOfDurationPart.location + rangeOfDurationPart.length];
        
        if ([[duration substringToIndex:1] isEqualToString:@"H"]) {
            hours = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"M"]) {
            minutes = [durationPart intValue];
        }
        if ([[duration substringToIndex:1] isEqualToString:@"S"]) {
            seconds = [durationPart intValue];
        }
    }
    if (hours == 0) {
       return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}


@end
