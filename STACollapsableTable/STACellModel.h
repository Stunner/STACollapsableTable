//
//  STACellModel.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/7/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STATableModelSpecifier.h"

@class STACollapsableTableModel;

@interface STACellModel : NSObject

//Public to subclasses
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) STATableModelSpecifier *specifier;

@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, assign) BOOL isSearchResult;
@property (nonatomic, assign, readonly) NSUInteger descendantsInSearchResults;

@property (nonatomic, strong, readonly) NSMutableSet <STACellModel *> *parents;
/**
 Distance from root node.
 */
@property (nonatomic, assign, readonly) NSUInteger depth;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, weak) NSIndexPath *indexPath;
@property (nonatomic, weak) STACollapsableTableModel *tableModel;

//Private/Internal to subclasses
@property (atomic, strong) NSCountedSet *descendantSearchResultSet;
@property (nonatomic, assign, readonly) NSUInteger displayedDescendantsCount;

- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier parent:(STACellModel *)parent;
- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier
                                parent:(STACellModel *)parent
                            tableModel:(STACollapsableTableModel *)tableModel;

- (void)addParent:(STACellModel *)cellModel;

- (NSArray *)indexPathsToAddForExpansionFromIndexPath:(NSIndexPath *)indexPath
                                         inTableModel:(STACollapsableTableModel *)tableModel
                                          isSearching:(BOOL)isSearching;

- (NSArray *)indexPathsToAddForExpansionFromSection:(NSInteger)section
                                       inTableModel:(STACollapsableTableModel *)tableModel
                                        isSearching:(BOOL)isSearching;

- (NSArray *)indexPathsToRemoveForCollapseFromIndexPath:(NSIndexPath *)indexPath
                                           inTableModel:(STACollapsableTableModel *)tableModel
                                            isSearching:(BOOL)isSearching;

- (NSArray *)indexPathsToRemoveForCollapseFromSection:(NSInteger)section
                                         inTableModel:(STACollapsableTableModel *)tableModel
                                          isSearching:(BOOL)isSearching;

- (NSArray *)filterContentsWithSearchString:(NSString *)searchString;

@end
