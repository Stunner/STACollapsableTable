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
                                                                     delegate:self];
    self.tableView.dataSource = [self.tableModel dataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(STACellModel *)object
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: @"row"];
    }
    NSMutableString *indentationString = [NSMutableString stringWithString:@""];
    for (int i = 0; i < object.depth; i++) {
        [indentationString appendString:@"    "];
    }
    [indentationString appendString:object.title];
    cell.textLabel.text = indentationString;
    return cell;
}

@end
