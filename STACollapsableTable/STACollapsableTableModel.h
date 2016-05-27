//
//  STACollapsableTableModel.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/5/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STACellModel;
@class STACollapsableTableModel;
@class STATableModelSpecifier;
@class STASearchOperation;

@protocol STACollapsableTableModelDelegate <NSObject>

@optional

/**
 Use this method to provide a custom model object to correspond to your custom table view cells.
 
 @returns STACellModel instance that is to correspond to the passed in specifier and parent
 */
- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel;

/**
 Use this method to provide a custom search operation object which should be run when executing the search (which happens immediately after this method returns).
 
 @returns STASearchOperation instance which should be used to perform search query with. Returning nil causes the default search operation to be run.
 */
- (STASearchOperation *)searchOperationOnData:(NSArray *)data withSearchQuery:(NSString *)searchQuery;

/**
 @param filteredContents NSArray of STACellModels's that match search criteria
 
 @returns search contents to load table view with after performing search completes
 */
- (NSArray *)searchOperationCompletedWithContents:(NSArray *)filteredContents;

@required

/**
 @returns UITableViewCell corresponding to passed in STACellModel instance.
 */
- (UITableViewCell *)tableViewModel:(STACollapsableTableModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                          withModel:(STACellModel *)model;

@end

@interface STACollapsableTableModel : NSObject

@property (nonatomic, weak) id<STACollapsableTableModelDelegate> delegate;
@property (nonatomic, readonly) id tableViewDataSource;
@property (nonatomic, readonly) id tableViewDelegate;
@property (nonatomic, assign, readonly) BOOL useTableSections;
/**
 Array of all contents in the table view model.
 
 This does not update during a search.
 */
@property (nonatomic, strong, readonly) NSArray *contentsArray;
/**
 Array of all cell models with root depth (of 0).
 
 This is leveraged in order to reference the cell model of a section header.
 This updates during a search.
 */
@property (nonatomic, strong, readonly) NSArray *topLevelObjects;
@property (nonatomic, assign, readonly) BOOL isSearching;

// designated initializer
- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                     useTableSections:(BOOL)useTableSections
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate;

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate;

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate;

- (void)resetTableWithModelData:(NSArray *)contentsArray;
- (void)resetTableModelData;
- (STACellModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForCellModel:(STACellModel *)cellModel;
- (void)collapseExpandedCellState;
- (void)expand:(STACellModel *)container fromRowFromIndexPath:(NSIndexPath *)indexPath;
- (void)expand:(STACellModel *)container fromSection:(NSInteger)section;
- (void)collapse:(STACellModel *)container fromSection:(NSInteger)section;
- (void)performSearchWithQuery:(NSString *)searchQuery;

@end
