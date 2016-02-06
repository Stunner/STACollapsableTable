//
//  STACollapsableTableModel.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/5/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACollapsableTableModel.h"
#import <Nimbus/NIMutableTableViewModel.h>
#import <Nimbus/NICellCatalog.h>

@interface STACollapsableTableModel () <NITableViewModelDelegate>

@property (nonatomic, strong) NIMutableTableViewModel *tableModel;

@end

@implementation STACollapsableTableModel

- (instancetype)initWithDelegate:(id<STACollapsableTableModelDelegate>)delegate {
    if (self = [super init]) {
        
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                             delegate:(id<STACollapsableTableModelDelegate>)delegate
{
    if (self = [super init]) {
        self.tableModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:contentsArray
                                                                         delegate:self];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Getters

- (id)dataSource {
    return self.tableModel;
}

- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object
{
    if ([self.delegate respondsToSelector:@selector(tableViewModel:cellForTableView:atIndexPath:withObject:)]) {
        return [self.delegate tableViewModel:self cellForTableView:tableView atIndexPath:indexPath withObject:object];
    }
    return nil;
}

@end
