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
#import "STATableModelSpecifier.h"
#import "STACellModel.h"

typedef void (^ObjectEnumeratorBlock)(id object);

@interface STACollapsableTableModel () <NITableViewModelDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NIMutableTableViewModel *tableModel;

@end

@implementation STACollapsableTableModel

//- (instancetype)initWithDelegate:(id<STACollapsableTableModelDelegate>)delegate {
//    if (self = [super init]) {
//        
//        self.delegate = delegate;
//    }
//    return self;
//}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                             delegate:(id<STACollapsableTableModelDelegate>)delegate
{
    if (self = [super init]) {
        [self parseContents:contentsArray];
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Getters

- (id)dataSource {
    return self.tableModel;
}

#pragma mark - Private Methods

- (void)parseContents:(NSArray *)contentsArray {
    NSMutableArray *mutableDataArray = [NSMutableArray arrayWithCapacity:contentsArray.count];
    for (STATableModelSpecifier *specifier in contentsArray) {
        STACellModel *cellModel = [[STACellModel alloc] initWithModelSpecifier:specifier parent:nil];
        [mutableDataArray addObject:cellModel];
    }
    self.dataArray = mutableDataArray;
    
    NSMutableArray *nimbusContents = [NSMutableArray array];
    [self enumerateObjects:self.dataArray block:^(id object) {
        [nimbusContents addObject:object];
    }];
    self.tableModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:nimbusContents
                                                                     delegate:self];
}

- (void)enumerateObjects:(NSArray *)contentsArray block:(ObjectEnumeratorBlock)block {
    if (contentsArray == 0) {
        return;
    }
    for (id object in contentsArray) {
        if ([object isKindOfClass:[STACellModel class]]) {
            block(object);
            [self enumerateObjects:((STACellModel *)object).children block:block];
        } else {
            block(object);
        }
    }
}

#pragma mark - NITableViewModelDelegate

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object
{
    if ([self.delegate respondsToSelector:@selector(tableViewModel:cellForTableView:atIndexPath:withModel:)]) {
        return [self.delegate tableViewModel:self cellForTableView:tableView atIndexPath:indexPath withModel:object];
    }
    return nil;
}

@end
