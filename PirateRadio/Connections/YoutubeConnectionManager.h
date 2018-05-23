//
//  YoutubeConnectionManager.h
//  
//
//  Created by A-Team User on 10.05.18.
//

#import <Foundation/Foundation.h>

@interface YoutubeConnectionManager : NSObject

+ (void) makeYoutubeSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;
+ (void)makeYoutubeRequestForVideoDurationsWithVideoIds:(NSArray<NSString *> *)videoIds andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;
+ (void)makeSuggestionsSearchWithPrefix:(NSString *)prefix andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;
+ (void)makeYoutubeRequestForMostPopularVideosWithCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion;

@end
