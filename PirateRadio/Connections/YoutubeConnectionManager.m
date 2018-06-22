//
//  YoutubeConnectionManager.m
//  
//
//  Created by A-Team User on 10.05.18.
//

#import "YoutubeConnectionManager.h"
#import "NSURL+URLWithQueryItems.h"

#define YOUTUBE_API_SEARCH_PREFIX @"https://www.googleapis.com/youtube/v3/search"
#define YOUTUBE_API_VIDEO_DURATION_REQUEST_PREFIX @"https://www.googleapis.com/youtube/v3/videos"
#define SEARCH_SUGGESTION_REQUEST_PREFIX @"http://clients1.google.com/complete/search"
#define YOUTUBE_API_PLAYLISTITEMS_PREFIX @"https://www.googleapis.com/youtube/v3/playlistItems"
#define YOUTUBE_API_PLAYLIST_PREFIX @"https://www.googleapis.com/youtube/v3/playlists"

@implementation YoutubeConnectionManager

+ (void)makeSearchWithNextPageToken:(NSString *)nextPageToken andKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:YOUTUBE_API_SEARCH_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet"],
                                              [NSURLQueryItem queryItemWithName:@"type" value:@"video,playlist"],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY],
                                              [NSURLQueryItem queryItemWithName:@"q" value:[keywords componentsJoinedByString:@"+"]],
                                              [NSURLQueryItem queryItemWithName:@"maxResults" value:@"15"],
                                              [NSURLQueryItem queryItemWithName:@"pageToken" value:nextPageToken]
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeYoutubeRequestForVideoDurationsWithVideoIds:(NSArray<NSString *> *)videoIds andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:YOUTUBE_API_VIDEO_DURATION_REQUEST_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet,contentDetails,statistics"],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY],
                                              [NSURLQueryItem queryItemWithName:@"id" value:[videoIds componentsJoinedByString:@","]]
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeYoutubeRequestForMostPopularVideosWithNextPageToken:(NSString *)nextPageToken andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
     NSURL *url = [NSURL URLWithString:YOUTUBE_API_VIDEO_DURATION_REQUEST_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet,contentDetails,statistics"],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY],
                                              [NSURLQueryItem queryItemWithName:@"chart" value:@"mostPopular"],
                                              [NSURLQueryItem queryItemWithName:@"regionCode" value:@"BG"],
                                              [NSURLQueryItem queryItemWithName:@"pageToken" value:nextPageToken]
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeSuggestionsSearchWithPrefix:(NSString *)prefix andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:SEARCH_SUGGESTION_REQUEST_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"output" value:@"firefox"],
                                              [NSURLQueryItem queryItemWithName:@"hl" value:@"en"],
                                              [NSURLQueryItem queryItemWithName:@"ds" value:@"yt"],
                                              [NSURLQueryItem queryItemWithName:@"q" value:prefix]
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeYoutubeRequestForSuggestedVideosForVideoId:(NSString *)videoId andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:YOUTUBE_API_SEARCH_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet"],
                                              [NSURLQueryItem queryItemWithName:@"type" value:@"video"],
                                              [NSURLQueryItem queryItemWithName:@"maxResults" value:@"10"],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY],
                                              [NSURLQueryItem queryItemWithName:@"relatedToVideoId" value:videoId],
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeYoutubeRequestForPlaylistItemsForPlaylistId:(NSString *)playlistId withNextPageToken:(NSString *)nextPageToken andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:YOUTUBE_API_PLAYLISTITEMS_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet,contentDetails"],
                                              [NSURLQueryItem queryItemWithName:@"playlistId" value:playlistId],
                                              [NSURLQueryItem queryItemWithName:@"maxResults" value:@"50"],
                                              [NSURLQueryItem queryItemWithName:@"pageToken" value:nextPageToken],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY],
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeSearchForPlaylistItemsCountForPlaylistIds:(NSArray<NSString *> *)playlistIds andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:YOUTUBE_API_PLAYLIST_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet,contentDetails"],
                                              [NSURLQueryItem queryItemWithName:@"id" value:[playlistIds componentsJoinedByString:@","]],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY],
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeGetRequestWithURLRequest:(NSURLRequest *)urlRequest withCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:completion];
    [dataTask resume];
}

@end
