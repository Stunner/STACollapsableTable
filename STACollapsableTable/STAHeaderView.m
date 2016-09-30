//
//  HeaderView.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 5/17/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STAHeaderView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface STAHeaderView ()

@property (nonatomic, strong) IBOutlet UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) STACollapsableTableModel *tableModel;
@property (nonatomic, assign, readwrite) NSInteger section;

@end

@implementation STAHeaderView

+ (STAHeaderView *)createHeaderInSection:(NSInteger)section
                               fromModel:(STACellModel *)cellModel
                              tableModel:(STACollapsableTableModel *)tableModel
                                userInfo:(NSDictionary *)userInfo
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"STAHeaderView" owner:self options:nil];
    STAHeaderView *headerView = [topLevelObjects objectAtIndex:0];
    headerView.section = section;
    headerView.cellModel = cellModel;
    headerView.titleLabel.text = cellModel.title;
    headerView.tableModel = tableModel;
    
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
    [self updateRotatedImageViewStatus];
    [self isSearchResultStateChanged:self.cellModel.isSearchResult];
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)gesture {
    
    if (!self.cellModel.children.count) {
        return; // collapsing/expansion can't be done on a cell without children
    }
    if (self.cellModel.isExpanded) { // collapse
        if (self.cellModel.tableModel.isSearching) {
            if (self.cellModel.descendantsInSearchResults < self.cellModel.children.count) {
                [self.tableModel collapse:self.cellModel fromSection:self.section];
            }
        } else {
            [self.tableModel collapse:self.cellModel fromSection:self.section];
        }
    } else { // expand
        [self.tableModel expand:self.cellModel fromSection:self.section];
    }
    [UIView animateWithDuration:0.33 animations:^{
        [self updateRotatedImageViewStatus];
    } completion:^(BOOL finished) {
        if (finished) {
            [self updateRotatedImageViewStatus];
        }
    }];
}

- (void)isSearchResultStateChanged:(BOOL)isSearchResult {
    if (self.titleLabel) {
        self.titleLabel.alpha = isSearchResult ? 1.0 : 0.5;
    }
}

- (void)updateRotatedImageViewStatus {
    
    if (self.cellModel.isExpanded) {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(0);
    }
}

@end
