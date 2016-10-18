//
//  HeaderView.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 5/17/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STABaseHeaderView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface STABaseHeaderView ()

@property (nonatomic, strong) UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) STACollapsableTableModel *tableModel;
@property (nonatomic, assign, readwrite) NSInteger section;

@end

@implementation STABaseHeaderView

+ (instancetype)createHeaderInSection:(NSInteger)section
                            fromModel:(STACellModel *)cellModel
                           tableModel:(STACollapsableTableModel *)tableModel
                              nibName:(NSString *)nibName
                             userInfo:(NSDictionary *)userInfo
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    STABaseHeaderView *headerView = [topLevelObjects objectAtIndex:0];
    headerView.section = section;
    headerView.cellModel = cellModel;
    headerView.titleLabel.text = cellModel.title;
    headerView.tableModel = tableModel;
    
    if (!tableModel.isSearching) {
        cellModel.isSearchResult = YES;
    }
    return headerView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(tapGestureHandler:)];
        singleTapRecognizer.numberOfTouchesRequired = 1;
        singleTapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapRecognizer];
    }
    return self;
}

#pragma mark - Setters

- (void)setCellModel:(STACellModel *)cellModel {
    _cellModel = cellModel;
    
    @weakify(self);
    [[RACObserve(self.cellModel, isSearchResult)
      combinePreviousWithStart:@(self.cellModel.isSearchResult)
      reduce:^id(NSNumber *previousValue, NSNumber *currentValue)
      {
          return @(([previousValue boolValue] != [currentValue boolValue]));
      }] subscribeNext:^(NSNumber *statusChanged) {
          @strongify(self);
          if ([statusChanged boolValue]) {
              [self isSearchResultStateChanged:cellModel.isSearchResult];
          }
      }];
    [self updateImageView];
    [self isSearchResultStateChanged:self.cellModel.isSearchResult];
}

#pragma mark - Public Methods

- (void)headerTapped {
    
    [UIView animateWithDuration:0.33 animations:^{
        [self updateImageView];
    } completion:^(BOOL finished) {
        if (finished) {
            [self updateImageView];
        }
    }];
}

- (void)updateImageView {
    
    if (self.cellModel.isExpanded) {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)isSearchResultStateChanged:(BOOL)isSearchResult {
    if (self.titleLabel) {
        self.titleLabel.alpha = isSearchResult ? 1.0 : 0.5;
    }
}

#pragma mark - Private Methods

- (void)tapGestureHandler:(UITapGestureRecognizer *)gesture {
    
    if (!self.cellModel.children.count) {
        return; // collapsing/expansion can't be done on a cell without children
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:self.section];
    if (self.cellModel.isExpanded) { // collapse
        if (self.cellModel.tableModel.isSearching) {
            if (self.cellModel.descendantsInSearchResults < self.cellModel.children.count) {
                [self.tableModel collapse:self.cellModel fromRowFromIndexPath:indexPath];
            }
        } else {
            [self.tableModel collapse:self.cellModel fromRowFromIndexPath:indexPath];
        }
    } else { // expand
        [self.tableModel expand:self.cellModel fromRowFromIndexPath:indexPath];
    }
    
    [self headerTapped];
}

@end
