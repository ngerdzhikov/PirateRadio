//
//  ITunesRequestManager.m
//  PirateRadio
//
//  Created by A-Team User on 17.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "ITunesRequestManager.h"
#import "NSURL+URLWithQueryItems.h"

#define ITUNES_SEARCH_PREFIX @"https://itunes.apple.com/search?"

@implementation ITunesRequestManager

+ (void)makeItunesSearchRequestWithKeywords:(NSArray<NSString *> *)keywords andCompletion:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion {
    NSURL *url = [NSURL URLWithString:ITUNES_SEARCH_PREFIX];
    NSArray<NSURLQueryItem *> *queryItems = @[
//                                              [NSURLQueryItem queryItemWithName:@"contry" value:@"US"],
                                              [NSURLQueryItem queryItemWithName:@"term" value:[keywords componentsJoinedByString:@"+"]],
//                                              [NSURLQueryItem queryItemWithName:@"media" value:@"music"],
//                                              [NSURLQueryItem queryItemWithName:@"callback" value:@"wsSearchCB"],
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
