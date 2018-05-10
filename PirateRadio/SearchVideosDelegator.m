//
//  SearchVideosDelegator.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SearchVideosDelegator.h"

@implementation SearchVideosDelegator

- (void) makeRequestWithVideoTitle:(NSString *)title {
    NSString *urlString =@"https://developers.google.com/apis-explorer/#p/youtube/v3/youtube.search.list?part=snippet&q=";
    urlString = [urlString stringByAppendingString:title];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:urlString]];
    
    NSHTTPURLResponse *responseCode = nil;

    
    
    
    
    
    
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    NSError *error;
    NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        
    }
    else {
        NSLog(@"%@",jsonArray);
    }
}


@end
