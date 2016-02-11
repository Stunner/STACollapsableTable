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

@interface SampleTableViewController () <STACollapsableTableModelDelegate>

@property (nonatomic, strong) STACollapsableTableModel *tableModel;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation SampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *children1 = @[[STATableModelSpecifier createWithTitle:@"sr 3" children:nil userInfo:nil],
                           [STATableModelSpecifier createWithTitle:@"sr 4" children:nil userInfo:nil]];
    NSArray *children2 = @[[STATableModelSpecifier createWithTitle:@"sr 1" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"sr 2" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"SubCategory" children:children1 userInfo:nil]];
    NSArray *children3 = @[[STATableModelSpecifier createWithTitle:@"sr 5" children:nil userInfo:nil],
                           [STATableModelSpecifier createWithTitle:@"sr 6" children:nil userInfo:nil],
                           [STATableModelSpecifier createWithTitle:@"sr 7" children:nil userInfo:nil]];
    NSArray *sectionedArray = @[[STATableModelSpecifier createWithTitle:@"Category" children:children2 userInfo:nil],
                                [STATableModelSpecifier createWithTitle:@"Empty Category" children:@[] userInfo:nil],
                                [STATableModelSpecifier createWithTitle:@"Category 2" children:children3 userInfo:nil]];
    
    self.tableModel = [[STACollapsableTableModel alloc] initWithContentsArray:sectionedArray
                                                                    tableView:self.tableView
                                                           initiallyCollapsed:YES
                                                                     delegate:self];
    self.tableView.dataSource = [self.tableModel tableViewDataSource];
    self.tableView.delegate = [self.tableModel tableViewDelegate];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = [self.tableModel tableViewDelegate];
    self.searchController.dimsBackgroundDuringPresentation = NO;
//    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
//                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
    self.searchController.searchBar.delegate = [self.tableModel tableViewDelegate];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                          withModel:(STACellModel *)model
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UITableViewCell *cell;
    if (model.children.count) {
        if (model.depth == 0) {
            cell = [CollapsableTableViewCell createFromModel:model inTableView:tableView userInfo:@{@"isSearching" : @(self.isSearching)}];
        } else {
            cell = [SubCollapsableTableViewCell createFromModel:model inTableView:tableView userInfo:@{@"isSearching" : @(self.isSearching)}];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                          reuseIdentifier: @"row"];
        }
        cell.textLabel.text = model.title;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[CollapsableTableViewCell class]]) {
        [(CollapsableTableViewCell *)cell cellTapped];
    } else if ([cell isKindOfClass:[SubCollapsableTableViewCell class]]) {
        [(SubCollapsableTableViewCell *)cell cellTapped];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel cellModelAtIndexPath:indexPath].depth * 2;
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
//    [self.tableView reloadData];
}

#pragma mark - UISearchbarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearching = NO;
}

@end
