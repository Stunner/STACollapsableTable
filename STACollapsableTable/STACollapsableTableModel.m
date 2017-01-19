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
#import "NIMutableTableViewModel+STAAdditions.h"
#import "STABaseHeaderView.h"

typedef STACellModel *(^ObjectEnumeratorBlock)(STATableModelSpecifier *specifier, STACellModel *parent);

@interface STACollapsableTableModel () <NITableViewModelDelegate>

// User specified
@property (nonatomic, strong, readwrite) STACollapsableTableModelOptions *options;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NIMutableTableViewModel *tableModel;
@property (nonatomic, strong) STATableViewDelegate *tableViewDelegateArbiter;

// Content
@property (nonatomic, strong) NSMutableSet *expandedSectionsSet;
@property (nonatomic, strong) NSMutableSet<STACellModel *> *expandableCellModelsSet;
@property (nonatomic, strong, readwrite) NSArray<STACellModel *> *expandedContentsArray;
@property (nonatomic, strong, readwrite) NSArray<STACellModel *> *collapsedContentsArray;
@property (nonatomic, strong, readwrite) NSArray<STACellModel *> *searchContents;
@property (nonatomic, strong, readwrite) NSArray<STACellModel *> *topLevelObjects;

// Search
@property (nonatomic, strong) NSString *prevSearchString;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *processingOperationsDictionary;
@property (nonatomic, assign) NSUInteger searchOperationID;
@property (atomic, assign) NSUInteger lastHighestSeenOperationID;
@property (nonatomic, assign) BOOL stopSearching;
@property (nonatomic, strong) NSArray<STACellModel *> *userProvidedContentArray;

@end

@implementation STACollapsableTableModel

// designated initializer
- (instancetype)initWithContentsArray:(NSArray<STATableModelSpecifier *> *)contentsArray
                            tableView:(UITableView *)tableView
                              options:(STACollapsableTableModelOptions *)options
                             delegate:(id<STACollapsableTableModelDelegate, UITableViewDelegate>)delegate
{
    if (self = [super init]) {
        _tableViewDelegateArbiter = [[STATableViewDelegate alloc] initWithInternalDelegate:self
                                                                          externalDelegate:delegate];
        _options = options;
        _delegate = delegate;
        _tableView = tableView;
        _tableModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:nil
                                                                     delegate:self];
        [self parseContents:contentsArray];
        _expandedSectionsSet = [NSMutableSet set];
        _operationQueue = [[NSOperationQueue alloc] init];
        _processingOperationsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
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
        _isSearching = isSearching;
        [self updateAppearanceOfCellsToCollapsed];
    }
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

- (void)resetTableWithModelData:(NSArray<STACellModel *> *)contentsArray {
    
    [self.tableModel sta_removeAllSections];
    self.userProvidedContentArray = contentsArray;
    [self addObjectsFromArrayToTableModel:self.userProvidedContentArray];
    [self.tableView reloadData];
}

- (void)resetTableModelData {
    
    [self.tableModel sta_removeAllSections];
    
    NSArray *contentsArray = nil;
    BOOL toExpand = (!self.isSearching && !self.options.initiallyCollapsed);
    if (toExpand) {
        contentsArray = self.expandedContentsArray;
    } else {
        contentsArray = self.collapsedContentsArray;
    }
    [self addObjectsFromArrayToTableModel:contentsArray];
    if (toExpand) {
        [self updateAppearanceOfCellsToExpanded];
    } else {
        [self updateAppearanceOfCellsToCollapsed];
    }
    
    [self.tableView reloadData];
}

- (STACellModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableModel objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForCellModel:(STACellModel *)cellModel {
    return [self.tableModel indexPathForObject:cellModel];
}

- (void)updateAppearanceOfCellsToCollapsed {
    
    for (STACellModel *cellModel in [self.expandedSectionsSet allObjects]) {
        cellModel.isExpanded = NO;
        [self.expandedSectionsSet removeObject:cellModel];
    }
}

- (void)updateAppearanceOfCellsToExpanded {
    
    for (STACellModel *cellModel in [self.expandableCellModelsSet allObjects]) {
        cellModel.isExpanded = YES;
        [self.expandedSectionsSet addObject:cellModel];
    }
}

- (void)expand:(STACellModel *)model fromRowFromIndexPath:(NSIndexPath *)indexPath {
    [self expand:model fromIndexPath:indexPath inTableView:self.tableView animated:YES];
}

- (void)collapse:(STACellModel *)model fromRowFromIndexPath:(NSIndexPath *)indexPath {
    [self collapse:model fromIndexPath:indexPath inTableView:self.tableView animated:YES];
}

- (void)performSearchWithQuery:(NSString *)searchQuery {
    
    STASearchOperation *searchOperation = nil;
    if ([self.delegate respondsToSelector:@selector(searchOperationOnData:withSearchQuery:)]) {
        searchOperation = [self.delegate searchOperationOnData:self.collapsedContentsArray withSearchQuery:searchQuery];
    }
    if (!searchOperation) {
        searchOperation = [[STASearchOperation alloc] initWithDataArray:self.collapsedContentsArray
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
                    [self.tableModel sta_removeAllSections];
                    
                    if ([self.delegate respondsToSelector:@selector(searchOperationCompletedWithContents:)]) {
                        NSArray *overriddenContents = [self.delegate searchOperationCompletedWithContents:searchOperation.allSearchResults];
                        [self addObjectsFromArrayToTableModel:overriddenContents];
                    } else {
                        [self addObjectsFromArrayToTableModel:searchOperation.allSearchResults];
                    }
                    self.searchContents = searchOperation.allSearchResults;
                    [self.tableView reloadData];
                });
            }
        }
    }];
    [self.operationQueue addOperation:searchOperation];
    
    self.prevSearchString = searchQuery;
}

- (NSArray<STACellModel *> *)parseModelSpecifiers:(NSArray <STATableModelSpecifier *>*)modelSpecifiers {
    NSMutableArray<STACellModel *> *mutableDataArray = [NSMutableArray arrayWithCapacity:modelSpecifiers.count];
    if (!self.expandableCellModelsSet) {
        self.expandableCellModelsSet = [NSMutableSet set];
    }
    @weakify(self);
    [self enumerateObjects:modelSpecifiers parent:nil block:^STACellModel *(STATableModelSpecifier *cellSpecifier, STACellModel *parent) {
        @strongify(self);
        STACellModel *cellModel = [self cellModelForSpecifier:cellSpecifier parent:parent tableModel:self];
        [mutableDataArray addObject:cellModel];
        if (cellModel.children.count) {
            [self.expandableCellModelsSet addObject:cellModel];
        }
        return cellModel;
    }];
    return mutableDataArray;
}

#pragma mark - Private Methods

/**
 @returns Instance of STACellModel if it is a root model (depth of 0).
 */
- (STACellModel *)addCellModelToTableModel:(STACellModel *)cellModel {
    if (self.options.useTableSections) {
        if (cellModel.depth == 0) { // root
            [self.tableModel addSectionWithTitle:cellModel.title];
            return cellModel;
        } else {
            [self.tableModel addObject:cellModel];
        }
    } else {
        [self.tableModel addObject:cellModel];
        if (cellModel.depth == 0) return cellModel;
    }
    return nil;
}

- (void)addObjectsFromArrayToTableModel:(NSArray<STACellModel *> *)array {
    NSMutableArray *topLevelObjects = [NSMutableArray array];
    for (STACellModel *cellModel in array) {
        STACellModel *topLevelCellModel = [self addCellModelToTableModel:cellModel];
        if (topLevelCellModel) [topLevelObjects addObject:topLevelCellModel];
    }
    self.topLevelObjects = topLevelObjects;
}

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
    cellModel.isExpanded = !self.options.initiallyCollapsed;
    return cellModel;
}

- (void)cellModelExpanded:(STACellModel *)cellModel {
    [self.expandedSectionsSet addObject:cellModel];
}

- (void)cellModelCollapsed:(STACellModel *)cellModel {
    [self.expandedSectionsSet removeObject:cellModel];
}

- (void)parseContents:(NSArray<STATableModelSpecifier *> *)parsableContents {
    if (self.options.initiallyCollapsed) {
        self.collapsedContentsArray = [self parseModelSpecifiers:parsableContents];
        [self addObjectsFromArrayToTableModel:self.collapsedContentsArray];
    } else {
        self.expandedContentsArray = [self parseModelSpecifiers:parsableContents];
        [self addObjectsFromArrayToTableModel:self.expandedContentsArray];
        // store completely collapsed version of contents for search
        if (!self.options.initiallyCollapsed) {
            self.options.initiallyCollapsed = YES;
            self.collapsedContentsArray = [self parseModelSpecifiers:parsableContents];
            self.options.initiallyCollapsed = NO;
        }
    }
}

- (void)enumerateObjects:(NSArray<STATableModelSpecifier *> *)contentsArray parent:(STACellModel *)parent block:(ObjectEnumeratorBlock)block {
    if (contentsArray == 0) {
        return;
    }
    for (STATableModelSpecifier *object in contentsArray) {
        if ([object isKindOfClass:[STATableModelSpecifier class]]) {
            STACellModel *model = block(object, parent);
            // enumerate among descendants if table view is expanded
//            if (!self.options.initiallyCollapsed) {
//                [self enumerateObjects:object.children parent:parentModel block:block];
//            }
//            if (!model.isExpanded) {
            BOOL expandCellModel = !self.options.initiallyCollapsed;
            if (expandCellModel) {
                if ([self.delegate respondsToSelector:@selector(expandCellModel:specifier:tableModel:)]) {
                    expandCellModel = [self.delegate expandCellModel:model specifier:object tableModel:self];
                }
                if (expandCellModel) {
                    [self enumerateObjects:object.children parent:model block:block];
                }
            }
        } else {
            block(object, nil);
        }
    }
}

- (void)scrollToExpandedIndexPath:(NSIndexPath *)indexPath {
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (void)expand:(STACellModel *)cellModel fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView animated:(BOOL)animated {
    
    if (cellModel.isExpanded) return;
    
    NSArray<NSDictionary *> *indexPathsToAdd = [cellModel indexPathsToAddForExpansionFromIndexPath:indexPath];
    NSMutableArray *addedIndexPaths = [NSMutableArray arrayWithCapacity:indexPathsToAdd.count];
    for (NSDictionary *dict in indexPathsToAdd) {
        NSUInteger index = [dict[@"index"] integerValue];
        STACellModel *addedCellModel = dict[@"container"];
        [self.tableModel insertObject:addedCellModel atRow:index inSection:indexPath.section];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
        [addedIndexPaths addObject:newIndexPath];
    }
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        // animation has finished
        [self scrollToExpandedIndexPath:indexPath];
    }];
    
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:addedIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [CATransaction commit];
    
    cellModel.isExpanded = YES;
    [self.expandedSectionsSet addObject:cellModel];
}

- (void)collapse:(STACellModel *)cellModel fromIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView animated:(BOOL)animated {
    
    NSMutableArray *removableIndexPaths = [NSMutableArray arrayWithCapacity:10];
    [removableIndexPaths addObjectsFromArray:[cellModel indexPathsToRemoveForCollapseFromIndexPath:indexPath]];
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

- (void)updateSearchResultsForText:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.stopSearching = YES;
        
        if (!self.userProvidedContentArray) {
            // reset table model data
            [self resetTableModelData];
        }
        if (!self.isSearching) {
            return;
        }
    }
    [self updateAppearanceOfCellsToCollapsed];
    [self performSearchWithQuery:searchText];
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    STACellModel *model = [self.topLevelObjects objectAtIndex:section];
    STABaseHeaderView *headerView = [STABaseHeaderView createHeaderInSection:section
                                                                   fromModel:model
                                                                  tableModel:self
                                                                     nibName:@"STAHeaderView"
                                                                    userInfo:nil];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STACellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    if (!cellModel.children.count) {
        return; // collapsing/expansion can't be done on a cell without children
    }
    if (cellModel.isExpanded) { // collapse
        if (self.isSearching) {
            if (cellModel.descendantsInSearchResults < cellModel.children.count) {
                [self collapse:cellModel fromIndexPath:indexPath inTableView:tableView animated:YES];
            }
        } else {
            [self collapse:cellModel fromIndexPath:indexPath inTableView:tableView animated:YES];
        }
    } else { // expand
        [self expand:cellModel fromIndexPath:indexPath inTableView:tableView animated:YES];
    }
}

#pragma mark - UISearchbarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
    [self updateSearchResultsForText:searchBar.text];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.isSearching = NO;
    self.userProvidedContentArray = nil;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.stopSearching = YES;
    [self resetTableModelData];
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = searchController.searchBar.text;
    [self updateSearchResultsForText:searchString];
}

@end
