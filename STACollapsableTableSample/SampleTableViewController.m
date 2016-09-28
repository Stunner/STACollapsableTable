//
//  SampleTableViewController.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/4/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "SampleTableViewController.h"
#import <Nimbus/NIMutableTableViewModel.h>
#import <Nimbus/NICellCatalog.h>
#import "STACollapsableTableModel.h"
#import "STATableModelSpecifier.h"
#import "STACellModel.h"
#import "CollapsableTableViewCell.h"
#import "SubCollapsableTableViewCell.h"
#import "LeafNodeTableViewCell.h"
#import "CustomCellModel.h"
#import "HeaderView.h"

@interface SampleTableViewController () <STACollapsableTableModelDelegate>

@property (nonatomic, strong) STACollapsableTableModel *tableModel;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation SampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"STACollapsableTable";
    
    NSArray *children1 = @[[STATableModelSpecifier createWithTitle:@"sr 3" children:nil userInfo:nil],
                           [STATableModelSpecifier createWithTitle:@"sr 4" children:nil userInfo:nil]];
    NSArray *ones = @[[STATableModelSpecifier createWithTitle:@"one" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"two" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"three" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"four" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"five" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"six" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"seven" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"eight" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"nine" children:nil userInfo:nil]];
    NSArray *fifties = @[[STATableModelSpecifier createWithTitle:@"fifty-one" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-two" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-three" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-four" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-five" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-six" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-seven" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-eight" children:nil userInfo:nil],
                         [STATableModelSpecifier createWithTitle:@"fifty-nine" children:nil userInfo:nil]];
    NSArray *tens = @[[STATableModelSpecifier createWithTitle:@"ten" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"twenty" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"thirty" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"fourty" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"fifty" children:fifties userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"sixty" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"seventy" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"eighty" children:nil userInfo:nil],
                      [STATableModelSpecifier createWithTitle:@"ninety" children:nil userInfo:nil]];
    NSArray *hundreds = @[[STATableModelSpecifier createWithTitle:@"one-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"two-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"three-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"four-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"five-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"six-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"seven-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"eight-hundred" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"nine-hundred" children:nil userInfo:nil]];
    NSArray *sectionedArray = @[[STATableModelSpecifier createWithTitle:@"Ones" children:ones userInfo:nil],
                                [STATableModelSpecifier createWithTitle:@"Tens" children:tens userInfo:nil],
                                [STATableModelSpecifier createWithTitle:@"Hundreds" children:hundreds userInfo:nil],
                                [STATableModelSpecifier createWithTitle:@"Empty Category" children:@[] userInfo:nil]];
    
    self.tableModel = [[STACollapsableTableModel alloc] initWithContentsArray:sectionedArray
                                                                    tableView:self.tableView
                                                           initiallyCollapsed:YES
                                                             useTableSections:YES
                                                                     delegate:self];
    self.tableView.dataSource = self.tableModel.tableViewDataSource;
    self.tableView.delegate = self.tableModel.tableViewDelegate;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = [self.tableModel tableViewDelegate];
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = [self.tableModel tableViewDelegate];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

#pragma mark - Table view data source

- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel
{
    return [[CustomCellModel alloc] initWithModelSpecifier:specifier
                                                    parent:parent
                                                tableModel:tableModel];
}

- (UITableViewCell *)tableViewModel:(STACollapsableTableModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                          withModel:(STACellModel *)model
{
    
    UITableViewCell *cell;
    if (model.children.count) {
        if (model.depth == 0) {
            cell = [CollapsableTableViewCell createFromModel:model inTableView:tableView userInfo:nil];
        } else {
            cell = [SubCollapsableTableViewCell createFromModel:model inTableView:tableView userInfo:nil];
        }
    } else {
        cell = [LeafNodeTableViewCell createFromModel:model inTableView:tableView userInfo:nil];
    }
    return cell;
}

#pragma mark - Table View Delegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    STACellModel *model = [self.tableModel.topLevelObjects objectAtIndex:section];
    HeaderView *headerView = [HeaderView createHeaderInSection:section
                                                     fromModel:model
                                                    tableModel:self.tableModel
                                                      userInfo:nil];
    return headerView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [(BaseCollapsableTableViewCell *)cell cellTapped];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel cellModelAtIndexPath:indexPath].depth * 2;
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
}

#pragma mark - UISearchbarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearching = NO;
}

@end
