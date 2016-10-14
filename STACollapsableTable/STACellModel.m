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
#import "STACollapsableTableModel+Private.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NSIndexPath * (^ObjectEnumeratorBlock)(STACellModel *cellModel, NSUInteger row);

@interface STACellModel ()

@property (atomic, strong) NSCountedSet *descendantSearchResultSet;
@property (nonatomic, assign, readonly) NSUInteger displayedDescendantsCount;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, weak, readwrite) STACollapsableTableModel *tableModel;

@end

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
        _section = -1;
        
        if (parent) {
            _parents = [NSMutableSet setWithObject:parent];
            _depth = parent.depth + 1;
        } else {
            _depth = 0; // no parent means this element is a root (depth of 0)
        }
        
        [self updateSelfBasedOnSearchStatusOfTableModel];
        @weakify(self);
        [[RACObserve(tableModel, isSearching)
          combinePreviousWithStart:@(tableModel.isSearching)
          reduce:^id(NSNumber *previousValue, NSNumber *currentValue)
          {
              return @(([previousValue boolValue] != [currentValue boolValue]));
          }] subscribeNext:^(NSNumber *statusChanged) {
              @strongify(self);
              if ([statusChanged boolValue]) {
                  [self updateSelfBasedOnSearchStatusOfTableModel];
              }
          }];
        
        NSMutableArray<STACellModel *> *childrenArray = [NSMutableArray arrayWithCapacity:modelSpecifier.children.count];
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

#pragma mark - Getters

- (NSUInteger)descendantsInSearchResults {
    
    return self.descendantSearchResultSet.count;
}

- (NSUInteger)displayedDescendantsCount {
    
    if (self.isExpanded) {
        return self.children.count;
    }
    return self.descendantsInSearchResults;
}

#pragma mark - Setters

- (void)setIsExpanded:(BOOL)isExpanded {
    if (!isExpanded) {
        // collapsing the parent collapses all of its children
        if (!self.tableModel.isSearching) {
            for (STACellModel *cellModel in self.children) {
                cellModel.isExpanded = NO;
            }
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

- (NSArray *)indexPathsToAddForExpansionFromIndexPath:(NSIndexPath *)indexPath {
    NSUInteger offsetCount = 1;
    NSUInteger rowsCounter = indexPath.row;
    return [self indexPathsToAddFromOffset:offsetCount rowsCounter:rowsCounter];
}

- (NSArray *)indexPathsToAddForExpansionFromSection:(NSInteger)section {
    NSUInteger offsetCount = 0;
    NSUInteger rowsCounter = 0;
    return [self indexPathsToAddFromOffset:offsetCount rowsCounter:rowsCounter];
}

- (NSArray *)indexPathsToRemoveForCollapseFromIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    return [self indexPathsToBeRemovedFromSection:indexPath.section];
}

- (NSArray *)indexPathsToRemoveForCollapseFromSection:(NSInteger)section {
    self.section = section;
    
    return [self indexPathsToBeRemovedFromSection:section];
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
    NSArray<STACellModel *> *searchResults = [NSMutableArray arrayWithArray:[self.children filteredArrayUsingPredicate:filterPredicate]];
    
    NSMutableArray<STACellModel *> *allSearchResults = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.children.count; i++) {
        STACellModel *container = self.children[i];
        NSArray<STACellModel *> *filteredArray = [container filterContentsWithSearchString:searchString];
        if (filteredArray.count > 0) {
            [allSearchResults addObject:container];
            [allSearchResults addObjectsFromArray:filteredArray]; // filteredArray
            continue;
        }
        
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title = %@", container.title];
        STACellModel *matchingContainer = [[searchResults filteredArrayUsingPredicate:titlePredicate] firstObject];
        if (matchingContainer) {
            [allSearchResults addObject:matchingContainer];
        }
    }
    
    // Update collapse/expand triangles according with how many children are displaying
    if (self.descendantsInSearchResults == self.children.count) {
        self.isExpanded = YES;
        [self.tableModel cellModelExpanded:self];
    } else {
        self.isExpanded = NO;
        [self.tableModel cellModelCollapsed:self];
    }
    
    return allSearchResults;
}

- (void)descendant:(STACellModel *)cellModel isSearchResult:(BOOL)isSearchResult {
    
    if (isSearchResult) {
        [self.descendantSearchResultSet addObject:cellModel];
    } else {
        [self.descendantSearchResultSet removeObject:cellModel];
    }
    for (id parent in [self.parents allObjects]) {
        [parent descendant:self isSearchResult:isSearchResult];
    }
}

- (BOOL)shouldExpandAndIncludeCellModel:(STACellModel *)cellModel {
    if (self.tableModel.isSearching) {
        if (!cellModel.isSearchResult && !cellModel.descendantsInSearchResults) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return NO;
}

- (BOOL)shouldCollapseAndRemoveCellModel:(STACellModel *)cellModel {
    if (self.tableModel.isSearching) {
        if (!cellModel.isSearchResult && !cellModel.descendantsInSearchResults) {
            return YES;
        }
    } else {
        return YES;
    }
    return NO;
}

#pragma mark - Helper Methods

- (NSArray *)indexPathsToAddFromOffset:(NSUInteger)offset rowsCounter:(NSUInteger)rowsCounter {
    NSMutableArray *addedIndexPaths = [NSMutableArray array];
    for (STACellModel *cellModel in self.children) {
        if ([self shouldExpandAndIncludeCellModel:cellModel]) {
            [addedIndexPaths addObject:@{@"container" : cellModel,
                                         @"index" : @(rowsCounter + offset)}];
        } else {
            if (cellModel.isExpanded) {
                offset += cellModel.children.count;
            } else {
                offset += cellModel.descendantsInSearchResults;
            }
        }
        offset++;
    }
    return addedIndexPaths;
}

- (NSArray *)indexPathsToBeRemovedFromSection:(NSInteger)section {
    return [self enumerateObjectsToBeRemoved:^NSIndexPath * (STACellModel *cellModel, NSUInteger row) {
        NSIndexPath *removableIndexPath = nil;
        if ([self shouldCollapseAndRemoveCellModel:cellModel]) {
            removableIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
        }
        return removableIndexPath;
    }];
}

- (void)updateSelfBasedOnSearchStatusOfTableModel {
    if (!self.tableModel.isSearching) { // if not searching, we want all cells to have black text
        self.isSearchResult = YES;
    }
}

- (BOOL)hasDescendant:(STACellModel *)cellModel {
    
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
 
 @retuns Array of index paths that should be removed.
 */
- (NSArray *)enumerateObjectsToBeRemoved:(ObjectEnumeratorBlock)block {
    
    NSMutableArray *indexPathsToRemoveArray = [NSMutableArray arrayWithCapacity:self.displayedDescendantsCount];
    
    NSUInteger r = self.indexPath.row;
    NSInteger i = 1;
    STACellModel *cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.indexPath.section]];
    if (self.section != -1) {
        r = 0;
        i = 0; // if cell model represents a header, there is no need to skip the first row
        cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.section]];
    }
    while (cellModel && [self hasDescendant:cellModel]) {
        NSIndexPath *removableIndexPath = block(cellModel, r + i);
        if (removableIndexPath) {
            [indexPathsToRemoveArray addObject:removableIndexPath];
        }
        i++;
        if (self.section != -1) {
            cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.section]];
        } else {
            cellModel = [self.tableModel cellModelAtIndexPath:[NSIndexPath indexPathForRow:r + i inSection:self.indexPath.section]];
        }
    }
    return indexPathsToRemoveArray;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"STACellModel:\ntitle: %@\nchildren: %@", self.title, self.children];
}

@end
