//
//  YoutubeConnectionManager.m
//  
//
//  Created by A-Team User on 10.05.18.
//

#import "YoutubeConnectionManager.h"
#import "NSURL+URLWithQueryItems.h"

#define API_KEY @"AIzaSyAkI_vw709cQDKruiKdjJ8K1sIXjA7PztI"
#define YOUTUBE_API_SEARCH_PREFIX @"https://www.googleapis.com/youtube/v3/search"

@implementation YoutubeConnectionManager

+ (void) makeYoutubeSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:YOUTUBE_API_SEARCH_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"part" value:@"snippet"],
                                              [NSURLQueryItem queryItemWithName:@"q" value:[keywords componentsJoinedByString:@"|"]],
                                              [NSURLQueryItem queryItemWithName:@"type" value:@"video"],
                                              [NSURLQueryItem queryItemWithName:@"key" value:API_KEY]
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void) makeGetRequestWithURLRequest:(NSURLRequest *)urlRequest withCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:completion];
    [dataTask resume];
}

@end