//
//  BaseCollapsableTableViewCell.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "BaseCollapsableTableViewCell.h"
#import "STACellModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BaseCollapsableTableViewCell ()

@property (nonatomic, strong) UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation BaseCollapsableTableViewCell

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                      reusableCellID:(NSString *)reusableCellID
                             nibName:(NSString *)nibName
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo
{
    BaseCollapsableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil]
        forCellReuseIdentifier:reusableCellID];
        cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
    }
    
    cell.cellModel = cellModel;
    cell.titleLabel.text = cellModel.title;
    [cell updateRotatedImageViewStatus];
    
    [cell isSearchResultStateChanged:cellModel.isSearchResult];
    if (![userInfo[@"isSearching"] boolValue]) {
        cellModel.isSearchResult = YES;
    }
    
    return cell;
}

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                      reusableCellID:(NSString *)reusableCellID
                           className:(NSString *)className
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo
{
    BaseCollapsableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellID];
    if (nil == cell) {
        cell = [(BaseCollapsableTableViewCell *)[NSClassFromString(className) alloc] initWithStyle:UITableViewCellStyleDefault
                                                                                   reuseIdentifier:reusableCellID];
    }
    
    cell.cellModel = cellModel;
    cell.textLabel.text = cellModel.title;
    
    [cell isSearchResultStateChanged:cellModel.isSearchResult];
    if (![userInfo[@"isSearching"] boolValue]) {
        cellModel.isSearchResult = YES;
    }
    
    return cell;
}

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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)isSearchResultStateChanged:(BOOL)isSearchResult {
    if (self.titleLabel) {
        self.titleLabel.alpha = isSearchResult ? 1.0 : 0.5;
    } else {
        self.textLabel.alpha = isSearchResult ? 1.0 : 0.5;
    }
}

- (void)updateRotatedImageViewStatus {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.cellModel.isExpanded) {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(0);
    }
}

#pragma mark - Public

- (void)cellTapped {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [UIView animateWithDuration:0.33 animations:^{
        [self updateRotatedImageViewStatus];
    } completion:^(BOOL finished) {
        if (finished) {
            [self updateRotatedImageViewStatus];
        }
    }];
}

@end
