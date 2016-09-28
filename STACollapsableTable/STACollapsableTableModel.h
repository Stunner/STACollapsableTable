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
 
 @returns STACellModel instance that is to correspond to the passed in specifier and parent.
 */
- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel;

/**
 Use this method to provide a custom search operation object which should be run when executing the search (which happens immediately after this method returns).
 
 @returns STASearchOperation instance which should be used to perform search query with. Returning nil causes the default search operation to be run.
 */
- (STASearchOperation *)searchOperationOnData:(NSArray<STACellModel *> *)data withSearchQuery:(NSString *)searchQuery;

/**
 @param filteredContents NSArray of STACellModels's that match search criteria
 
 @returns Contents to load table view with after performing search query.
 */
- (NSArray<STACellModel *> *)searchOperationCompletedWithContents:(NSArray<STACellModel *> *)filteredContents;

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

@property (nonatomic, weak) id<STACollapsableTableModelDelegate, UITableViewDelegate> delegate;
/**
 The object that needs to be set as the table view's data source.
 */
@property (nonatomic, readonly) id tableViewDataSource;
/**
 The object that needs to be set as the table view's delegate.
 */
@property (nonatomic, readonly) id tableViewDelegate;
/**
 Reflects if the table model is set to display all root models (with depth of 0) as section headers.
 */
@property (nonatomic, assign, readonly) BOOL useTableSections;
/**
 Array of all contents in the table view model.
 
 This does not update during a search.
 */
@property (nonatomic, strong, readonly) NSArray<STACellModel *> *contentsArray;
/**
 Contains filtered contentsArray which was the result in most recent search.
 */
@property (nonatomic, strong, readonly) NSArray<STACellModel *> *searchContents;
/**
 Array of all cell models with root depth (of 0).
 
 This is leveraged in order to reference the cell model of a section header. Updates during a search.
 */
@property (nonatomic, strong, readonly) NSArray<STACellModel *> *topLevelObjects;
/**
 Denotes searching state of table view.
 */
@property (nonatomic, assign, readonly) BOOL isSearching;

// designated initializer
- (instancetype)initWithContentsArray:(NSArray<STATableModelSpecifier *> *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                     useTableSections:(BOOL)useTableSections
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate;

- (instancetype)initWithContentsArray:(NSArray<STATableModelSpecifier *> *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate;

- (instancetype)initWithContentsArray:(NSArray<STATableModelSpecifier *> *)contentsArray
                            tableView:(UITableView *)tableView
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate;

- (void)resetTableWithModelData:(NSArray<STACellModel *> *)contentsArray;
- (void)resetTableModelData;
- (STACellModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForCellModel:(STACellModel *)cellModel;
- (void)collapseExpandedCells;
- (void)expand:(STACellModel *)model fromRowFromIndexPath:(NSIndexPath *)indexPath;
- (void)expand:(STACellModel *)model fromSection:(NSInteger)section;
- (void)collapse:(STACellModel *)model fromSection:(NSInteger)section;
- (void)performSearchWithQuery:(NSString *)searchQuery;
- (NSArray<STACellModel *> *)parseModelSpecifiers:(NSArray <STATableModelSpecifier *>*)modelSpecifiers;

@end
