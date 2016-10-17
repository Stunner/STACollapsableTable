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

/**
 Model object that represents a cell. May be subclassed.
 */
@interface STACellModel : NSObject

/**
 Title text that the cell displays.
 */
@property (nonatomic, strong) NSString *title;
/**
 Immediate descendants.
 */
@property (nonatomic, strong) NSArray<STACellModel *> *children;
/**
 Specifier object that was used to instantiate this object.
 */
@property (nonatomic, strong) STATableModelSpecifier *specifier;
/**
 Reflects cell expansion state.
 */
@property (nonatomic, assign) BOOL isExpanded;
/**
 Denotes if this cell is a search result of a search query.
 */
@property (nonatomic, assign) BOOL isSearchResult;
/**
 Number of descendants that satisfy the search criterea and should be shown in search results.
 */
@property (nonatomic, assign, readonly) NSUInteger descendantsInSearchResults;
/**
 Set of this cell model's parents. Can add parents via `-addParent:` method. Removing parents unsupported.
 */
@property (nonatomic, strong, readonly) NSMutableSet<STACellModel *> *parents;
/**
 Distance from root node.
 */
@property (nonatomic, assign, readonly) NSUInteger depth;

@property (nonatomic, weak, readonly) STACollapsableTableModel *tableModel;


- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier
                                parent:(STACellModel *)parent
                            tableModel:(STACollapsableTableModel *)tableModel;

/**
 Adds passed in cell model as parent, allowing for multple children to share the same parent/have multiple parents.
 */
- (void)addParent:(STACellModel *)cellModel;

- (NSArray *)indexPathsToAddForExpansionFromIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)indexPathsToRemoveForCollapseFromIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)filterContentsWithSearchString:(NSString *)searchString;

- (BOOL)shouldExpandAndIncludeCellModel:(STACellModel *)cellModel;
- (BOOL)shouldCollapseAndRemoveCellModel:(STACellModel *)cellModel;

@end
