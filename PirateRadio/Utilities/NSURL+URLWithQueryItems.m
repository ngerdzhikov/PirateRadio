//
//  NSURL+URLWithQueryItems.m
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "NSURL+URLWithQueryItems.h"

@implementation NSURL (URLWithQueryItems)

-(NSURL *) URLByAppendingQueryItems:(NSArray<NSURLQueryItem *> *)queryItems
{
    return [self URLByAppendingQueryItems:queryItems withCheckForDuplicates:NO];
}

-(NSURL *) URLByAppendingQueryItems:(NSArray<NSURLQueryItem *> *)queryItems withCheckForDuplicates:(BOOL)checkForDuplicates
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableArray<NSURLQueryItem*> *finalQueryItems = [[NSMutableArray alloc] init];
    
    if (checkForDuplicates)
    {
        finalQueryItems = [NSOrderedSet orderedSetWithArray:queryItems].array.mutableCopy;
    }
    else if (components.queryItems.count > 0)
    {
        finalQueryItems = components.queryItems.mutableCopy;
    }
    
    [finalQueryItems addObjectsFromArray:queryItems];
    [components setQueryItems:finalQueryItems];
    
    NSURL *result = [components URL];
    return  result;
}

@end
