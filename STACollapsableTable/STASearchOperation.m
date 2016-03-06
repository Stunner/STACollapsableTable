//
//  STASearchOperation.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STASearchOperation.h"
#import "STACellModel.h"

@interface STASearchOperation ()

@end

@implementation STASearchOperation

- (instancetype)initWithDataArray:(NSArray *)dataArray withSearchString:(NSString *)searchString {
    if (self = [super init]) {
        // no need to make a copy as dataArray should never change once set
        _dataArray = dataArray;
        _searchString = [searchString copy];
    }
    return self;
}

- (void)main {
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(STACellModel *object, NSDictionary *bindings) {
        if (self.searchString.length < 1 ||
            [object.title rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            object.isSearchResult = YES;
            return YES;
        }
        object.isSearchResult = NO;
        return NO;
    }];
    NSMutableArray *searchResults = [NSMutableArray arrayWithArray:[self.dataArray filteredArrayUsingPredicate:filterPredicate]];
    
    NSMutableArray *allSearchResults = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.dataArray.count; i++) {
        
        if ([self isCancelled]) {
            break;
        }
        
        STACellModel *cellModel = self.dataArray[i];
        NSArray *filteredArray = [cellModel filterContentsWithSearchString:self.searchString];
        if (filteredArray.count > 0) { // maintain nested heirarchy
            [allSearchResults addObject:cellModel]; // container
            [allSearchResults addObjectsFromArray:filteredArray]; // filteredArray
            continue;
        }
        
        if ([self isCancelled]) {
            break;
        }
        
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title = %@", cellModel.title];
        STACellModel *matchingContainer = [[searchResults filteredArrayUsingPredicate:titlePredicate] firstObject];
        if (matchingContainer) {
            [allSearchResults addObject:matchingContainer];
        }
    }
    self.allSearchResults = allSearchResults;
}

@end
