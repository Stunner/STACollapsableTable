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

@interface SampleTableViewController () <STACollapsableTableModelDelegate>

@property (nonatomic, strong) STACollapsableTableModel *tableModel;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation SampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"STACollapsableTable";
    
    NSArray *ones = @[[STATableModelSpecifier createWithTitle:@"one" children:nil userInfo:@[@"1"]],
                      [STATableModelSpecifier createWithTitle:@"two" children:nil userInfo:@[@"2"]],
                      [STATableModelSpecifier createWithTitle:@"three" children:nil userInfo:@[@"3"]],
                      [STATableModelSpecifier createWithTitle:@"four" children:nil userInfo:@[@"4"]],
                      [STATableModelSpecifier createWithTitle:@"five" children:nil userInfo:@[@"5"]],
                      [STATableModelSpecifier createWithTitle:@"six" children:nil userInfo:@[@"6"]],
                      [STATableModelSpecifier createWithTitle:@"seven" children:nil userInfo:@[@"7"]],
                      [STATableModelSpecifier createWithTitle:@"eight" children:nil userInfo:@[@"8"]],
                      [STATableModelSpecifier createWithTitle:@"nine" children:nil userInfo:@[@"9"]]];
    
    NSArray *fifties = @[[STATableModelSpecifier createWithTitle:@"fifty-one" children:nil userInfo:@[@"5", @"1"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-two" children:nil userInfo:@[@"5", @"2"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-three" children:nil userInfo:@[@"5", @"3"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-four" children:nil userInfo:@[@"5", @"4"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-five" children:nil userInfo:@[@"5", @"5"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-six" children:nil userInfo:@[@"5", @"6"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-seven" children:nil userInfo:@[@"5", @"7"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-eight" children:nil userInfo:@[@"5", @"8"]],
                         [STATableModelSpecifier createWithTitle:@"fifty-nine" children:nil userInfo:@[@"5", @"9"]]];
    NSArray *tens = @[[STATableModelSpecifier createWithTitle:@"ten" children:nil userInfo:@[@"1", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"twenty" children:nil userInfo:@[@"2", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"thirty" children:nil userInfo:@[@"3", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"fourty" children:nil userInfo:@[@"4", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"fifty" children:fifties userInfo:@[@"5", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"sixty" children:nil userInfo:@[@"6", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"seventy" children:nil userInfo:@[@"7", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"eighty" children:nil userInfo:@[@"8", @"0"]],
                      [STATableModelSpecifier createWithTitle:@"ninety" children:nil userInfo:@[@"9", @"0"]]];
    
    NSArray *hundreds = @[[STATableModelSpecifier createWithTitle:@"one-hundred" children:nil userInfo:@[@"1", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"two-hundred" children:nil userInfo:@[@"2", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"three-hundred" children:nil userInfo:@[@"3", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"four-hundred" children:nil userInfo:@[@"4", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"five-hundred" children:nil userInfo:@[@"5", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"six-hundred" children:nil userInfo:@[@"6", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"seven-hundred" children:nil userInfo:@[@"7", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"eight-hundred" children:nil userInfo:@[@"8", @"0"]],
                          [STATableModelSpecifier createWithTitle:@"nine-hundred" children:nil userInfo:@[@"9", @"0"]]];
    NSArray *sectionedArray = @[[STATableModelSpecifier createWithTitle:@"Ones" children:ones userInfo:@[@"1"]],
                                [STATableModelSpecifier createWithTitle:@"Tens" children:tens userInfo:@[@"1", @"0", @"10"]],
                                [STATableModelSpecifier createWithTitle:@"Hundreds" children:hundreds userInfo:@[@"1", @"0", @"100"]],
                                [STATableModelSpecifier createWithTitle:@"Empty Category" children:@[] userInfo:nil]];
    STACollapsableTableModelOptions *options = [STACollapsableTableModelOptions new];
    options.initiallyCollapsed = NO;
    options.useTableSections = YES;
    self.tableModel = [[STACollapsableTableModel alloc] initWithContentsArray:sectionedArray
                                                                    tableView:self.tableView
                                                                      options:options
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
    CustomCellModel *cellModel = [[CustomCellModel alloc] initWithModelSpecifier:specifier
                                                                          parent:parent
                                                                      tableModel:tableModel];
    cellModel.tags = [NSSet setWithArray:specifier.userInfo];
    return cellModel;
}

- (BOOL)expandCellModel:(STACellModel *)cellModel
              specifier:(STATableModelSpecifier *)specifier
             tableModel:(STACollapsableTableModel *)tableModel
{
    return cellModel.isExpanded;
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [(STACollapsableTableViewCell *)cell cellTapped];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel cellModelAtIndexPath:indexPath].depth * 3;
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
