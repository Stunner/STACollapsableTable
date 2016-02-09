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

@interface SampleTableViewController () <STACollapsableTableModelDelegate>

@property (nonatomic, strong) STACollapsableTableModel *tableModel;

@end

@implementation SampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *children1 = @[[STATableModelSpecifier createWithTitle:@"sr 3" children:nil userInfo:nil],
                           [STATableModelSpecifier createWithTitle:@"sr 4" children:nil userInfo:nil]];
    NSArray *children2 = @[[STATableModelSpecifier createWithTitle:@"sr 1" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"sr 2" children:nil userInfo:nil],
                          [STATableModelSpecifier createWithTitle:@"Category" children:children1 userInfo:nil]];
    NSArray *sectionedArray = @[[STATableModelSpecifier createWithTitle:@"Category" children:children2 userInfo:nil],
                                [STATableModelSpecifier createWithTitle:@"Empty Category" children:@[] userInfo:nil]];
    
    self.tableModel = [[STACollapsableTableModel alloc] initWithContentsArray:sectionedArray
                                                           initiallyCollapsed:YES
                                                                     delegate:self];
    self.tableView.dataSource = [self.tableModel tableViewDataSource];
    self.tableView.delegate = [self.tableModel tableViewDelegate];
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
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: @"row"];
    }
    cell.textLabel.text = model.title;
    return cell;
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel cellModelAtIndexPath:indexPath].depth * 2;
}

@end
