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
#import "STATableViewDelegate.h"

typedef void (^ObjectEnumeratorBlock)(id object);

@interface STACollapsableTableModel () <NITableViewModelDelegate>

@property (nonatomic, assign) BOOL initiallyCollapsed;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NIMutableTableViewModel *tableModel;
@property (nonatomic, strong) STATableViewDelegate *tableViewDelegateArbiter;

@property (nonatomic, strong) NSMutableSet *expandedSectionsSet;

@end

@implementation STACollapsableTableModel

// designated initializer
- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    if (self = [super init]) {
        _tableViewDelegateArbiter = [[STATableViewDelegate alloc] initWithInternalDelegate:self externalDelegate:delegate];
        _initiallyCollapsed = initiallyCollapsed;
        [self parseContents:contentsArray];
        _delegate = delegate;
        _expandedSectionsSet = [NSMutableSet set];
    }
    return self;
}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    return [self initWithContentsArray:contentsArray initiallyCollapsed:NO delegate:delegate];
}

#pragma mark - Getters

- (id)tableViewDataSource {
    return self.tableModel;
}

- (id)tableViewDelegate {
    return self.tableViewDelegateArbiter;
}

#pragma mark - Public Methods

- (STACellModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel objectAtIndexPath:indexPath];
}

- (void)collapseExpandedCellState {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    for (STACellModel *cellModel in [self.expandedSectionsSet allObjects] ) {
        cellModel.isExpanded = NO;
        [self.expandedSectionsSet removeObject:cellModel];
    }
}

#pragma mark - Private Methods

- (void)parseContents:(NSArray *)contentsArray {
    NSMutableArray *mutableDataArray = [NSMutableArray arrayWithCapacity:contentsArray.count];
    for (STATableModelSpecifier *specifier in contentsArray) { // loop through root level objects
        STACellModel *cellModel = [[STACellModel alloc] initWithModelSpecifier:specifier parent:nil];
        [mutableDataArray addObject:cellModel];
    }
    self.dataArray = mutableDataArray;
    
    NSMutableArray *nimbusContents = [NSMutableArray array];
    [self enumerateObjects:self.dataArray block:^(STACellModel *cellModel) {
        cellModel.isExpanded = !self.initiallyCollapsed;
        [nimbusContents addObject:cellModel];
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
            if (!self.initiallyCollapsed) {
                [self enumerateObjects:((STACellModel *)object).children block:block];
            }
        } else {
            block(object);
        }
    }
}

- (void)expand:(STACellModel *)cellModel fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView animated:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (cellModel.isExpanded) return;
    
    NSArray<NSDictionary *> *indexPathsToAdd = [cellModel indexPathsToAddForExpansionFromIndexPath:indexPath
                                                                                      inTableModel:self
                                                                                       isSearching:NO/*self.isSearching*/];
    NSMutableArray *addedIndexPaths = [NSMutableArray arrayWithCapacity:indexPathsToAdd.count];
    for (NSDictionary *dict in indexPathsToAdd) {
        NSUInteger index = [dict[@"index"] integerValue];
        STACellModel *addedCellModel = dict[@"container"];
        [self.tableModel insertObject:addedCellModel atRow:index inSection:indexPath.section];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
        [addedIndexPaths addObject:newIndexPath];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:addedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
//    [tableView reloadRowsAtIndexPaths:addedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    
//    UITableViewScrollPosition scrollPosition = UITableViewScrollPositionTop;
//    if (cellModel.children.count < 4) {
//        scrollPosition = UITableViewScrollPositionMiddle;
//    }
//    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    
    cellModel.isExpanded = YES;
    [self.expandedSectionsSet addObject:cellModel];
}

- (void)collapse:(STACellModel *)cellModel fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView animated:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSMutableArray *removableIndexPaths = [NSMutableArray arrayWithCapacity:10];
    [removableIndexPaths addObjectsFromArray:[cellModel indexPathsToRemoveForCollapseFromIndexPath:indexPath
                                                                                      inTableModel:self
                                                                                       isSearching:NO/*self.isSearching*/]];
    for (NSInteger i = removableIndexPaths.count - 1; i >= 0; i--) {
        NSIndexPath *removedIndexPath = removableIndexPaths[i];
        [self.tableModel removeObjectAtIndexPath:removedIndexPath];
    }
    [tableView deleteRowsAtIndexPaths:removableIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    cellModel.isExpanded = NO;
    [self.expandedSectionsSet removeObject:cellModel];
}

#pragma mark - NITableViewModelDelegate Methods

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

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    STACellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    if (cellModel.isExpanded) { // collapse
        [self collapse:cellModel fromIndexPath:indexPath inTableView:tableView animated:YES];
    } else { // expand
        [self expand:cellModel fromIndexPath:indexPath inTableView:tableView animated:YES];
    }
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
}

@end
