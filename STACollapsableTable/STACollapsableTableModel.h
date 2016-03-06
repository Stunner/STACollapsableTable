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

- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel;

- (STASearchOperation *)searchOperationOnData:(NSArray *)data withSearchQuery:(NSString *)searchQuery;

/**
 @param filteredContents NSArray of STACellModels's that match search criteria
 
 @returns search contents to load table view with after performing search completes
 */
- (NSArray *)searchOperationCompletedWithContents:(NSArray *)filteredContents;

@required

- (UITableViewCell *)tableViewModel:(STACollapsableTableModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                          withModel:(STACellModel *)model;

@end

@interface STACollapsableTableModel : NSObject

@property (nonatomic, weak) id<STACollapsableTableModelDelegate> delegate;
@property (nonatomic, readonly) id tableViewDataSource;
@property (nonatomic, readonly) id tableViewDelegate;
@property (nonatomic, strong, readonly) NSArray *contentsArray;
@property (nonatomic, assign) BOOL isSearching;

// designated initializer
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
- (void)performSearchWithQuery:(NSString *)searchQuery;

//TODO: conceal this method - it shouldn't be public
- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel;

@end
