//
//  SearchTableViewController.h
//  PirateRadio
//
//  Created by A-Team User on 10.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface SearchTableViewController : UITableViewController<UISearchBarDelegate,SearchSuggestionsDelegate>

@property (strong, nonatomic) NSMutableArray<NSString *> *searchSuggestions;
@property (strong, nonatomic) NSMutableArray<NSString *> *searchHistory;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


- (void)makeSearchWithString:(NSString *)string;

@end
