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

@interface SampleTableViewController () <NITableViewModelDelegate>

@property (nonatomic, strong) NIMutableTableViewModel *tableModel;

@end

@implementation SampleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *sectionedArray = @[@"Section 1",
                                [NITitleCellObject objectWithTitle:@"Row 1"],
                                [NITitleCellObject objectWithTitle:@"Row 2"],
                                @"Section 2",
                                [NITitleCellObject objectWithTitle:@"Row 3"]];
    
    self.tableModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:sectionedArray
                                                                     delegate:self];
    self.tableView.dataSource = self.tableModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([object isKindOfClass:[NITitleCellObject class]]) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: @"row"];
        }
        cell.textLabel.text = [(NITitleCellObject *)object title];
        return cell;
    }
    return nil;
}

@end
