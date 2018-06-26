//
//  ArtworkRequest.m
//  PirateRadio
//
//  Created by A-Team User on 17.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ArtworkRequest.h"
#import "NSURL+URLWithQueryItems.h"

#define LAST_FM_API_KEY @"170edf925171e574a3ac568a6557f7e9"
#define LAST_FM_SEARCH_PREFIX @"http://ws.audioscrobbler.com/2.0/?method=album.search&"

#define ITUNES_SEARCH_PREFIX @"https://itunes.apple.com/search?"

@implementation ArtworkRequest

+ (void)makeLastFMSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:LAST_FM_SEARCH_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"album" value:[keywords componentsJoinedByString:@"+"]],
                                              [NSURLQueryItem queryItemWithName:@"api_key" value:LAST_FM_API_KEY],
                                              [NSURLQueryItem queryItemWithName:@"format" value:@"json"]
                                              ];
    url = [url URLByAppendingQueryItems:queryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [self.class makeGetRequestWithURLRequest:request withCompletion:completion];
}

+ (void)makeItunesSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:ITUNES_SEARCH_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
                                              [NSURLQueryItem queryItemWithName:@"contry" value:@"US"],
                                              [NSURLQueryItem queryItemWithName:@"term" value:[keywords componentsJoinedByString:@"+"]],
                                              [NSURLQueryItem queryItemWithName:@"limit" value:@"5"]
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
