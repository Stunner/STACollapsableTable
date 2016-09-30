//
//  STACollapsableTableViewCell.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACollapsableTableViewCell.h"
#import "STACellModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface STACollapsableTableViewCell ()

@property (nonatomic, strong) UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation STACollapsableTableViewCell

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                      reusableCellID:(NSString *)reusableCellID
                             nibName:(NSString *)nibName
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo
{
    STACollapsableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
        forCellReuseIdentifier:reusableCellID];
        cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
    }
    
    cell.titleLabel.text = cellModel.title;
    [cell initConfigurationWithModel:cellModel userInfo:userInfo];
    
    return cell;
}

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                      reusableCellID:(NSString *)reusableCellID
                           className:(NSString *)className
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo
{
    STACollapsableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
    if (nil == cell) {
        cell = [(STACollapsableTableViewCell *)[NSClassFromString(className) alloc] initWithStyle:UITableViewCellStyleDefault
                                                                                   reuseIdentifier:reusableCellID];
    }
    
    cell.textLabel.text = cellModel.title;
    [cell initConfigurationWithModel:cellModel userInfo:userInfo];
    
    return cell;
}

- (void)initConfigurationWithModel:(STACellModel *)cellModel userInfo:(NSDictionary *)userInfo {
    self.cellModel = cellModel;
    [self updateRotatedImageViewStatus];
    
    [self isSearchResultStateChanged:cellModel.isSearchResult];
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
    [[RACObserve(self.cellModel, isExpanded)
      combinePreviousWithStart:@(self.cellModel.isExpanded)
      reduce:^id(NSNumber *previousStatus, NSNumber *currentStatus)
      {
          return @(([previousStatus boolValue] != [currentStatus boolValue]));
      }] subscribeNext:^(NSNumber *statusChanged) {
          @strongify(self);
          if ([statusChanged boolValue]) {
              [self cellTapped];
          }
      }];
}

- (void)isSearchResultStateChanged:(BOOL)isSearchResult {
    if (self.titleLabel) {
        self.titleLabel.alpha = isSearchResult ? 1.0 : 0.5;
    } else {
        self.textLabel.alpha = isSearchResult ? 1.0 : 0.5;
    }
}

- (void)updateRotatedImageViewStatus {
    
    if (self.cellModel.isExpanded) {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(0);
    }
}

#pragma mark - Public

- (void)cellTapped {
    
    [UIView animateWithDuration:0.33 animations:^{
        [self updateRotatedImageViewStatus];
    } completion:^(BOOL finished) {
        if (finished) {
            [self updateRotatedImageViewStatus];
        }
    }];
}

@end
