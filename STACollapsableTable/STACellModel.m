//
//  STACellModel.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/7/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACellModel.h"
#import <UIKit/UIKit.h>
#import "STACollapsableTableModel.h"

typedef NSIndexPath * (^ObjectEnumeratorBlock)(STACellModel *cellModel, NSUInteger row);

@implementation STACellModel

- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier parent:(STACellModel *)parent {
    if (self = [super init]) {
        _title = modelSpecifier.title;
        _specifier = modelSpecifier;
        _isExpanded = NO;
        
        if (parent) {
            _parent = parent;
            _depth = parent.depth + 1;
        } else {
            _depth = 0; // no parent means this element is a root (depth of 0)
        }
        
        NSMutableArray *childrenArray = [NSMutableArray arrayWithCapacity:modelSpecifier.children.count];
        for (STATableModelSpecifier *specifier in modelSpecifier.children) {
            STACellModel *cellModel = [[STACellModel alloc] initWithModelSpecifier:specifier parent:self];
            [childrenArray addObject:cellModel];
        }
        _children = childrenArray;
    }
    return self;
}

- (NSUInteger)descendantsInSearchResults {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self.descendantSearchResultSet.count;
}

- (NSUInteger)displayedDescendantsCount {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.isExpanded) {
        return self.children.count;
    }
    return self.descendantsInSearchResults;
}

- (void)setIsExpanded:(BOOL)isExpanded {
    if (!isExpanded) {
        // collapsing the parent collapses all of its children
        for (STACellModel *cellModel in self.children) {
            cellModel.isExpanded = NO;
        }
    } else {
        if (self.children.count == 0) { // a cell with no children can't be expanded!
            return;
        }
    }
    _isExpanded = isExpanded;
}

#pragma mark - Public Methods

- (NSArray *)indexPathsToAddForExpansionFromIndexPath:(NSIndexPath *)indexPath
                                         inTableModel:(STACollapsableTableModel *)tableModel
                                          isSearching:(BOOL)isSearching
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableArray *addedIndexPaths = [NSMutableArray array];
    NSUInteger offsetCount = 1;
    NSUInteger rowsCounter = indexPath.row;
    for (STACellModel *cellModel in self.children) {
        if (isSearching) {
            if (!cellModel.isSearchResult && !cellModel.descendantsInSearchResults) {
                [addedIndexPaths addObject:@{@"container" : cellModel,
                                             @"index" : @(rowsCounter + offsetCount)}];
            } else {
                if (cellModel.isExpanded) {
                    offsetCount += cellModel.children.count;
                } else {
                    offsetCount += cellModel.descendantsInSearchResults;
                }
            }
        } else {
            [addedIndexPaths addObject:@{@"container" : cellModel,
                                         @"index" : @(rowsCounter + offsetCount)}];
        }
        offsetCount++;
    }
    return addedIndexPaths;
}

- (NSArray *)indexPathsToRemoveForCollapseFromIndexPath:(NSIndexPath *)indexPath
                                           inTableModel:(STACollapsableTableModel *)tableModel
                                            isSearching:(BOOL)isSearching
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    self.indexPath = indexPath;
    self.tableModel = tableModel;
    
    return [self enumerateObjects:^NSIndexPath * (STACellModel *cellModel, NSUInteger row) {
        NSIndexPath *removableIndexPath = nil;
        if (isSearching) {
            if (!cellModel.isSearchResult) {
                removableIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
            }
        } else {
            removableIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        }
        return removableIndexPath;
    }];
}

- (NSArray *)filterContentsWithSearchString:(NSString *)searchString {
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(STACellModel *object, NSDictionary *bindings) {
        if (searchString.length > 0 &&
            [object.title rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            object.isSearchResult = YES;
            return YES;
        }
        object.isSearchResult = NO;
        return NO;
    }];
    NSArray *searchResults = [NSMutableArray arrayWithArray:[self.children filteredArrayUsingPredicate:filterPredicate]];
    
    NSMutableArray *allSearchResults = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.children.count; i++) {
        STACellModel *container = self.children[i];
        NSArray *filteredArray = [container filterContentsWithSearchString:searchString];
        if (filteredArray.count > 0) {
            [allSearchResults addObject:container];
            // if is not of Accessibility type
//            if (!(container.locationsArray.count > 0 && ((Location *)[container.locationsArray firstObject]).locations)) {
                [allSearchResults addObjectsFromArray:filteredArray]; // filteredArray
//            }
            continue;
        }
        
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title = %@", container.title];
        STACellModel *matchingContainer = [[searchResults filteredArrayUsingPredicate:titlePredicate] firstObject];
        if (matchingContainer) {
            [allSearchResults addObject:matchingContainer];
        }
    }
    return allSearchResults;
}

#pragma mark - Helper Methods

- (BOOL)isDescendant:(STACellModel *)cellModel {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (!cellModel.parent) {
        return NO;
    }
    if (cellModel.parent == self) {
        return YES;
    }
    return [self isDescendant:cellModel.parent];
}

/**
 Enumerates through already displaying objects.
 */
- (NSArray *)enumerateObjects:(ObjectEnumeratorBlock)block {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSUInteger displayedDescendantsCount = self.displayedDescendantsCount;
    NSMutableArray *indexPathsToRemoveArray = [NSMutableArray arrayWithCapacity:displayedDescendantsCount];
    NSUInteger r = self.indexPath.row;
    
    NSInteger i = 1;
    STACellModel *cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.indexPath.section]];
    while (cellModel && [self isDescendant:cellModel]) {
        NSIndexPath *removableIndexPath = block(cellModel, r + i);
        if (removableIndexPath) {
            [indexPathsToRemoveArray addObject:removableIndexPath];
        }
        i++;
        cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.indexPath.section]];
    }
    return indexPathsToRemoveArray;
}

@end
