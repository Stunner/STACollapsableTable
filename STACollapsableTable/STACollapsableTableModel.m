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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "STASearchOperation.h"

typedef void (^ObjectEnumeratorBlock)(id object);

@interface STACollapsableTableModel () <NITableViewModelDelegate>

@property (nonatomic, assign) BOOL initiallyCollapsed;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NIMutableTableViewModel *tableModel;
@property (nonatomic, strong) STATableViewDelegate *tableViewDelegateArbiter;

@property (nonatomic, strong) NSMutableSet *expandedSectionsSet;
@property (nonatomic, strong) UITableView *tableView;

// Search
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSString *prevSearchString;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *processingOperationsDictionary;
@property (nonatomic, assign) NSUInteger searchOperationID;
@property (atomic, assign) NSUInteger lastHighestSeenOperationID;
@property (nonatomic, assign) BOOL stopSearching;

@end

@implementation STACollapsableTableModel

// designated initializer
- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    if (self = [super init]) {
        _tableViewDelegateArbiter = [[STATableViewDelegate alloc] initWithInternalDelegate:self externalDelegate:delegate];
        _initiallyCollapsed = initiallyCollapsed;
        _delegate = delegate;
        [self parseContents:contentsArray];
        _expandedSectionsSet = [NSMutableSet set];
        _operationQueue = [[NSOperationQueue alloc] init];
        _tableView = tableView;
    }
    return self;
}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    return [self initWithContentsArray:contentsArray tableView:tableView initiallyCollapsed:NO delegate:delegate];
}

#pragma mark - Getters

- (id)tableViewDataSource {
    return self.tableModel;
}

- (id)tableViewDelegate {
    return self.tableViewDelegateArbiter;
}

#pragma mark - Setters

- (void)setIsSearching:(BOOL)isSearching {
    if (isSearching != _isSearching) {
        [self collapseExpandedCellState];
    }
    _isSearching = isSearching;
}

- (void)setStopSearching:(BOOL)stopSearching {
    
    if (stopSearching && _stopSearching != stopSearching) {
        if (self.operationQueue.operationCount > 0) {
            self.lastHighestSeenOperationID = self.searchOperationID + 1; // make any change "out of reach"
            [self.operationQueue cancelAllOperations];
        }
    }
    _stopSearching = stopSearching;
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

- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel
{
    if ([self.delegate respondsToSelector:@selector(cellModelForSpecifier:parent:tableModel:)]) {
        return [self.delegate cellModelForSpecifier:specifier parent:parent tableModel:tableModel];
    }
    return [[STACellModel alloc] initWithModelSpecifier:specifier parent:parent tableModel:tableModel];
}

- (void)parseContents:(NSArray *)contentsArray {
    NSMutableArray *mutableDataArray = [NSMutableArray arrayWithCapacity:contentsArray.count];
    for (STATableModelSpecifier *specifier in contentsArray) { // loop through root level objects
        STACellModel *cellModel = [self cellModelForSpecifier:specifier parent:nil tableModel:self];
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
                                                                                       isSearching:self.isSearching];
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
                                                                                       isSearching:self.isSearching]];
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

#pragma mark - UISearchbarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearching = NO;
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSString *searchString = searchController.searchBar.text;
    if ([searchString isEqualToString:@""]) {
        self.stopSearching = YES;
        
        // reset table model data
        [self.tableModel removeSectionAtIndex:0];
//        [self.tableModel addObject:[NITitleCellObject objectWithTitle:@"search bar placeholder"]];
        [self.tableModel addObjectsFromArray:self.dataArray];
        [self.tableView reloadData];
    }
    
    STASearchOperation *searchOperation = [[STASearchOperation alloc] initWithDataArray:self.dataArray
                                                                       withSearchString:searchString];
    searchOperation.operationID = ++self.searchOperationID;
    
    // cancel previously run operations
    STASearchOperation *previousSearchOperation = [self.processingOperationsDictionary objectForKey:self.prevSearchString];
    if (previousSearchOperation) {
        [previousSearchOperation cancel];
        [self.processingOperationsDictionary removeObjectForKey:self.prevSearchString];
    }
    [self.processingOperationsDictionary setObject:searchOperation forKey:searchString];
    
    @weakify(self);
    [RACObserve(searchOperation, isFinished) subscribeNext:^(NSNumber *isFinished) {
        @strongify(self);
        if ([isFinished boolValue]) {
            if (searchOperation.operationID > self.lastHighestSeenOperationID) {
                self.lastHighestSeenOperationID = searchOperation.operationID;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableModel removeSectionAtIndex:0];
//                    if (self.isSearching) {
//                        [self.tableModel addObject:[NITitleCellObject objectWithTitle:@"search bar placeholder"]];
//                    }
                    [self.tableModel addObjectsFromArray:searchOperation.allSearchResults];
                    [self.tableView reloadData];
                });
            }
        }
    }];
    [self.operationQueue addOperation:searchOperation];
    
    // analytics
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(logSearchStringToGA:) object:self.prevSearchString];
//    [self performSelector:@selector(logSearchStringToGA:) withObject:searchString afterDelay:GA_LOGGING_MAP_SEARCH_DELAY];
    
    self.prevSearchString = searchString;
}

@end
