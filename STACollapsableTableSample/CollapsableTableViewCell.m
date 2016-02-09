//
//  CollapsableTableViewCell.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/9/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "CollapsableTableViewCell.h"

@interface CollapsableTableViewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) STACellModel *cellModel;

@end

@implementation CollapsableTableViewCell

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo
{
    CollapsableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollapsableTableViewCellID"];
    if (nil == cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CollapsableTableViewCell" bundle:nil]
        forCellReuseIdentifier:@"CollapsableTableViewCellID"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"CollapsableTableViewCellID"];
    }
    
    cell.titleLabel.text = cellModel.title;
    cell.cellModel = cellModel;
    [cell updateRotatedImageViewStatus];
    return cell;
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
