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

- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier
                                parent:(STACellModel *)parent
                            tableModel:(STACollapsableTableModel *)tableModel
{
    if (self = [super init]) {
        _title = modelSpecifier.title;
        _specifier = modelSpecifier;
        _isExpanded = NO;
        _isSearchResult = YES; // make cells show up as black instead of gray initially
        _tableModel = tableModel;
        
        if (parent) {
            _parents = [NSMutableSet setWithObject:parent];
            _depth = parent.depth + 1;
        } else {
            _depth = 0; // no parent means this element is a root (depth of 0)
        }
        
        NSMutableArray *childrenArray = [NSMutableArray arrayWithCapacity:modelSpecifier.children.count];
        for (STATableModelSpecifier *specifier in modelSpecifier.children) {
            STACellModel *cellModel = [tableModel cellModelForSpecifier:specifier parent:self tableModel:tableModel];
            if (cellModel) {
                [childrenArray addObject:cellModel];
            }
        }
        _children = childrenArray;
        _descendantSearchResultSet = [NSCountedSet setWithCapacity:childrenArray.count];
    }
    return self;
}

- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier parent:(STACellModel *)parent {
    if (self = [self initWithModelSpecifier:modelSpecifier parent:parent tableModel:nil]) {
        
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

- (void)setIsSearchResult:(BOOL)isSearchResult {
    if (_isSearchResult != isSearchResult) {
        for (STACellModel *parent in [self.parents allObjects]) {
            [parent descendant:self isSearchResult:isSearchResult];
        }
    }
    _isSearchResult = isSearchResult;
}

#pragma mark - Public Methods

- (void)addParent:(STACellModel *)cellModel {
    [self.parents addObject:cellModel];
}

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
            if (!cellModel.isSearchResult && !cellModel.descendantsInSearchResults) {
                removableIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
            }
        } else {
            removableIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
        }
        return removableIndexPath;
    }];
}

- (NSArray *)filterContentsWithSearchString:(NSString *)searchString {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
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

- (void)descendant:(STACellModel *)cellModel isSearchResult:(BOOL)isSearchResult {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (isSearchResult) {
        [self.descendantSearchResultSet addObject:cellModel];
    } else {
        [self.descendantSearchResultSet removeObject:cellModel];
    }
    for (id parent in [self.parents allObjects]) {
        [parent descendant:self isSearchResult:isSearchResult];
    }
//    [self.parent descendant:self isSearchResult:isSearchResult];
}

#pragma mark - Helper Methods

- (BOOL)hasDescendant:(STACellModel *)cellModel {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (!cellModel.parents) {
        return NO;
    }
    if ([cellModel.parents containsObject:self]) {
        return YES;
    }
    BOOL isDescendant = NO;
    for (STACellModel *parent in [cellModel.parents allObjects]) {
        isDescendant = [self hasDescendant:parent];
        if (isDescendant) {
            return YES;
        }
    }
    return isDescendant;
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
    while (cellModel && [self hasDescendant:cellModel]) {
        NSIndexPath *removableIndexPath = block(cellModel, r + i);
        if (removableIndexPath) {
            [indexPathsToRemoveArray addObject:removableIndexPath];
        }
        i++;
        cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.indexPath.section]];
    }
    return indexPathsToRemoveArray;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"STACellModel:\ntitle: %@\nchildren: %@", self.title, self.children];
}

@end
