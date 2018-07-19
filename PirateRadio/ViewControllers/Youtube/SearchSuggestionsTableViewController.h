//
//  SearchSuggestionsTableViewController.h
//  PirateRadio
//
//  Created by A-Team User on 22.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface SearchSuggestionsTableViewController : UITableViewController <SearchSuggestionsDelegate>

@property (strong, nonatomic) NSMutableArray<NSString *> *searchSuggestions;
@property (strong, nonatomic) NSMutableArray<NSString *> *searchHistory;
@property (weak, nonatomic) id<SearchTableViewDelegate> delegate;

@end
