//
//  SearchSuggestionsTableViewController.m
//  PirateRadio
//
//  Created by A-Team User on 22.05.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

#import "SearchSuggestionsTableViewController.h"
#import "YoutubeConnectionManager.h"

@interface SearchSuggestionsTableViewController ()

@end

@implementation SearchSuggestionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchHistory = [[NSUserDefaults.standardUserDefaults objectForKey:@"searchHistory"] mutableCopy];
    if (!self.searchHistory) {
        self.searchHistory = [[NSMutableArray alloc] init];
    }
    self.searchSuggestions = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSUserDefaults.standardUserDefaults setObject:self.searchHistory forKey:@"searchHistory"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchSuggestions.count < 1) {
        return self.searchHistory.count;
    }
    return self.searchSuggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestionsCell" forIndexPath:indexPath];
    if (self.searchSuggestions.count < 1) {
        cell.textLabel.text = self.searchHistory[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"history_icon"];
    }
    else {
        cell.textLabel.text = self.searchSuggestions[indexPath.row];
        cell.imageView.image = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self.delegate makeSearchWithString:cell.textLabel.text];
    [self didMakeSearchWithText:cell.textLabel.text];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.searchHistory removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchSuggestions.count < 1) {
        return YES;
    }
    return NO;
}

- (void)searchForSuggestionsWithText:(NSString *)searchText {
    [YoutubeConnectionManager makeSuggestionsSearchWithPrefix:searchText andCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *serializationError;
        NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
        if (serializationError) {
            NSLog(@"serializationError = %@", serializationError);
            [self.searchSuggestions removeAllObjects];
        }
        else {
            [self.searchSuggestions removeAllObjects];
            for (NSString *suggestion in responseArray[1]) {
                [self.searchSuggestions addObject:suggestion];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didMakeSearchWithText:(NSString *)searchText {
    if ([self.searchHistory containsObject:searchText]) {
        [self.searchHistory removeObject:searchText];
    }
    [self.searchHistory insertObject:searchText atIndex:0];
}

- (void)didChangeText:(NSString *)searchText {
    [self searchForSuggestionsWithText:searchText];
}

@end
