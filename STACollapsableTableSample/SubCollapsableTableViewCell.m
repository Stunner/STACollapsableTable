//
//  SubCollapsableTableViewCell.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/9/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "SubCollapsableTableViewCell.h"

@interface SubCollapsableTableViewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

@implementation SubCollapsableTableViewCell

+ (SubCollapsableTableViewCell *)createFromModel:(STACellModel *)cellModel
                                     inTableView:(UITableView *)tableView
                                        userInfo:(NSDictionary *)userInfo
{
    SubCollapsableTableViewCell *cell = (SubCollapsableTableViewCell *)[super createFromModel:cellModel
                                                                               reusableCellID:@"SubCollapsableTableViewCellID"
                                                                                      nibName:@"SubCollapsableTableViewCell"
                                                                                  inTableView:tableView
                                                                                     userInfo:userInfo];
    cell.titleLabel.text = cellModel.title;
    [cell updateRotatedImageViewStatus];
    
    if (![userInfo[@"isSearching"] boolValue]) {
        [cell isSearchResultStateChanged:cellModel.isSearchResult];
    }
    
    return cell;
}

- (void)isSearchResultStateChanged:(BOOL)isSearchResult {
    self.titleLabel.alpha = isSearchResult ? 1.0 : 0.5;
}

- (void)updateRotatedImageViewStatus {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.cellModel.isExpanded) {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        self.collapsedStatusImageView.transform = CGAffineTransformMakeRotation(0);
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
