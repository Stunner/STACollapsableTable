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
@property (nonatomic, strong) NIMutableTableViewModel *tableModel;
@property (nonatomic, strong) STATableViewDelegate *tableViewDelegateArbiter;

@property (nonatomic, strong) NSMutableSet *expandedSectionsSet;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readwrite) NSArray *contentsArray;
@property (nonatomic, strong, readwrite) NSArray *topLevelObjects;

// Search
@property (nonatomic, strong) NSString *prevSearchString;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *processingOperationsDictionary;
@property (nonatomic, assign) NSUInteger searchOperationID;
@property (atomic, assign) NSUInteger lastHighestSeenOperationID;
@property (nonatomic, assign) BOOL stopSearching;
@property (nonatomic, strong) NSArray *userProvidedContentArray;

@end

@implementation STACollapsableTableModel

// designated initializer
- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                     useTableSections:(BOOL)useTableSections
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    if (self = [super init]) {
        _tableViewDelegateArbiter = [[STATableViewDelegate alloc] initWithInternalDelegate:self externalDelegate:delegate];
        _initiallyCollapsed = initiallyCollapsed;
        _useTableSections = useTableSections;
        _delegate = delegate;
        _tableView = tableView;
        [self parseContents:contentsArray];
        _expandedSectionsSet = [NSMutableSet set];
        _operationQueue = [[NSOperationQueue alloc] init];
        _processingOperationsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                   initiallyCollapsed:(BOOL)initiallyCollapsed
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    return [self initWithContentsArray:contentsArray
                             tableView:tableView
                    initiallyCollapsed:NO
                      useTableSections:NO
                              delegate:delegate];
}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                            tableView:(UITableView *)tableView
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    return [self initWithContentsArray:contentsArray
                             tableView:tableView
                    initiallyCollapsed:NO
                              delegate:delegate];
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

- (void)resetTableWithModelData:(NSArray *)contentsArray {
    
    [self.tableModel removeAllSections];
    self.userProvidedContentArray = contentsArray;
    [self addObjectsFromArrayToTableModel:self.userProvidedContentArray];
    [self.tableView reloadData];
}

- (void)resetTableModelData {
    
    [self.tableModel removeAllSections];
    [self addObjectsFromArrayToTableModel:self.contentsArray];
    [self.tableView reloadData];
}

- (STACellModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForCellModel:(STACellModel *)cellModel {
    return [self.tableModel indexPathForObject:cellModel];
}

- (void)collapseExpandedCellState {
    
    for (STACellModel *cellModel in [self.expandedSectionsSet allObjects]) {
        cellModel.isExpanded = NO;
        [self.expandedSectionsSet removeObject:cellModel];
    }
}

- (void)expand:(STACellModel *)container fromRowFromIndexPath:(NSIndexPath *)indexPath {
    [self expand:container fromIndexPath:indexPath inTableView:self.tableView animated:YES];
}

- (void)expand:(STACellModel *)container fromSection:(NSInteger)section {
    [self expand:container fromSection:section inTableView:self.tableView animated:YES];
}

- (void)collapse:(STACellModel *)container fromSection:(NSInteger)section {
    [self collapse:container fromSection:section inTableView:self.tableView animated:YES];
}

/**
 @returns Instance of STACellModel if it is a root model (depth of 0).
 */
- (STACellModel *)addCellModelToTableModel:(STACellModel *)cellModel {
    if (self.useTableSections) {
        if (cellModel.depth == 0) { // root
            [self.tableModel addSectionWithTitle:cellModel.title];
            return cellModel;
        } else {
            [self.tableModel addObject:cellModel];
        }
    } else {
        [self.tableModel addObject:cellModel];
    }
    return nil;
}

- (void)addObjectsFromArrayToTableModel:(NSArray *)array {
    NSMutableArray *topLevelObjects = [NSMutableArray array];
    for (STACellModel *cellModel in array) {
        STACellModel *topLevelCellModel = [self addCellModelToTableModel:cellModel];
        if (topLevelCellModel) [topLevelObjects addObject:topLevelCellModel];
    }
    self.topLevelObjects = topLevelObjects;
}

- (void)performSearchWithQuery:(NSString *)searchQuery {
    
    STASearchOperation *searchOperation = nil;
    if ([self.delegate respondsToSelector:@selector(searchOperationOnData:withSearchQuery:)]) {
        searchOperation = [self.delegate searchOperationOnData:self.contentsArray withSearchQuery:searchQuery];
    }
    if (!searchOperation) {
        searchOperation = [[STASearchOperation alloc] initWithDataArray:self.contentsArray
                                                       withSearchString:searchQuery];
    }
    searchOperation.operationID = ++self.searchOperationID;
    
    // cancel previously run operations
    STASearchOperation *previousSearchOperation = [self.processingOperationsDictionary objectForKey:self.prevSearchString];
    if (previousSearchOperation) {
        [previousSearchOperation cancel];
        [self.processingOperationsDictionary removeObjectForKey:self.prevSearchString];
    }
    [self.processingOperationsDictionary setObject:searchOperation forKey:searchQuery];
    
    @weakify(self);
    [RACObserve(searchOperation, isFinished) subscribeNext:^(NSNumber *isFinished) {
        @strongify(self);
        if (self.isSearching && [isFinished boolValue]) {
            if (searchOperation.operationID > self.lastHighestSeenOperationID) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.lastHighestSeenOperationID = searchOperation.operationID;
                    [self.tableModel removeAllSections];
                    
                    if ([self.delegate respondsToSelector:@selector(searchOperationCompletedWithContents:)]) {
                        NSArray *overriddenContents = [self.delegate searchOperationCompletedWithContents:searchOperation.allSearchResults];
                        [self addObjectsFromArrayToTableModel:overriddenContents];
                    } else {
                        [self addObjectsFromArrayToTableModel:searchOperation.allSearchResults];
                    }
                    [self.tableView reloadData];
                });
            }
        }
    }];
    [self.operationQueue addOperation:searchOperation];
    
    self.prevSearchString = searchQuery;
}

#pragma mark - Private Methods

- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel
{
    STACellModel *cellModel = nil;
    if ([self.delegate respondsToSelector:@selector(cellModelForSpecifier:parent:tableModel:)]) {
        cellModel = [self.delegate cellModelForSpecifier:specifier parent:parent tableModel:tableModel];
    }
    if (!cellModel) {
        cellModel = [[STACellModel alloc] initWithModelSpecifier:specifier parent:parent tableModel:tableModel];
    }
    return cellModel;
}

- (void)parseContents:(NSArray <STATableModelSpecifier *>*)contentsArray {
    NSMutableArray *mutableDataArray = [NSMutableArray arrayWithCapacity:contentsArray.count];
    for (STATableModelSpecifier *specifier in contentsArray) { // loop through root level objects
        STACellModel *cellModel = [self cellModelForSpecifier:specifier parent:nil tableModel:self];
        [mutableDataArray addObject:cellModel];
    }
    self.contentsArray = mutableDataArray;
    
    NSMutableArray *topLevelObjects = [NSMutableArray array];
    self.tableModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:nil
                                                                     delegate:self];
    @weakify(self);
    [self enumerateObjects:self.contentsArray block:^(STACellModel *cellModel) {
        @strongify(self);
        cellModel.isExpanded = !self.initiallyCollapsed;
        STACellModel *topLevelCellModel = [self addCellModelToTableModel:cellModel];
        if (topLevelCellModel) [topLevelObjects addObject:topLevelCellModel];
    }];
    self.topLevelObjects = topLevelObjects;
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
    
    if (cellModel.isExpanded) return;
    
    NSArray<NSDictionary *> *indexPathsToAdd = [cellModel indexPathsToAddForExpansionFromIndexPath:indexPath
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
    
    cellModel.isExpanded = YES;
    [self.expandedSectionsSet addObject:cellModel];
}

- (void)expand:(STACellModel *)cellModel fromSection:(NSInteger)section inTableView:(UITableView *)tableView animated:(BOOL)animated {
    
    if (cellModel.isExpanded) return;
    
    NSArray<NSDictionary *> *indexPathsToAdd = [cellModel indexPathsToAddForExpansionFromSection:section
                                                                                     isSearching:self.isSearching];
    
    NSMutableArray *addedIndexPaths = [NSMutableArray arrayWithCapacity:indexPathsToAdd.count];
    for (NSDictionary *dict in indexPathsToAdd) {
        NSUInteger index = [dict[@"index"] integerValue];
        STACellModel *addedCellModel = dict[@"container"];
        [self.tableModel insertObject:addedCellModel atRow:index inSection:section];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:section];
        [addedIndexPaths addObject:newIndexPath];
    }
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:addedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    cellModel.isExpanded = YES;
    [self.expandedSectionsSet addObject:cellModel];
}

- (void)collapse:(STACellModel *)cellModel fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView animated:(BOOL)animated {
    
    NSMutableArray *removableIndexPaths = [NSMutableArray arrayWithCapacity:10];
    [removableIndexPaths addObjectsFromArray:[cellModel indexPathsToRemoveForCollapseFromIndexPath:indexPath
                                                                                       isSearching:self.isSearching]];
    for (NSInteger i = removableIndexPaths.count - 1; i >= 0; i--) {
        NSIndexPath *removedIndexPath = removableIndexPaths[i];
        [self.tableModel removeObjectAtIndexPath:removedIndexPath];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:removableIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    cellModel.isExpanded = NO;
    [self.expandedSectionsSet removeObject:cellModel];
}

- (void)collapse:(STACellModel *)cellModel fromSection:(NSInteger)section inTableView:(UITableView *)tableView animated:(BOOL)animated {
    
    NSMutableArray *removableIndexPaths = [NSMutableArray arrayWithCapacity:10];
    [removableIndexPaths addObjectsFromArray:[cellModel indexPathsToRemoveForCollapseFromSection:section
                                                                                       isSearching:self.isSearching]];
    for (NSInteger i = removableIndexPaths.count - 1; i >= 0; i--) {
        NSIndexPath *removedIndexPath = removableIndexPaths[i];
        [self.tableModel removeObjectAtIndexPath:removedIndexPath];
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:removableIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    cellModel.isExpanded = NO;
    [self.expandedSectionsSet removeObject:cellModel];
}

#pragma mark - NITableViewModelDelegate Methods

- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(STACellModel *)object
{
    if ([self.delegate respondsToSelector:@selector(tableViewModel:cellForTableView:atIndexPath:withModel:)]) {
        return [self.delegate tableViewModel:self cellForTableView:tableView atIndexPath:indexPath withModel:object];
    }
    return nil;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STACellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    if (!cellModel.children.count) {
        return; // collapsing/expansion can't be done on a cell without children
    }
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
    self.userProvidedContentArray = nil;
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = searchController.searchBar.text;
    if ([searchString isEqualToString:@""]) {
        self.stopSearching = YES;
        
        if (!self.userProvidedContentArray) {
            // reset table model data
            [self resetTableModelData];
        }
        if (!self.isSearching) {
            return;
        }
    }
    
    [self performSearchWithQuery:searchString];
}

@end
