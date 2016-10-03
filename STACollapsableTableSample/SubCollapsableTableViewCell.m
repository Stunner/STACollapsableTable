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

@dynamic collapsedStatusImageView;
@dynamic titleLabel;

+ (SubCollapsableTableViewCell *)createFromModel:(STACellModel *)cellModel
                                     inTableView:(UITableView *)tableView
                                        userInfo:(NSDictionary *)userInfo
{
    SubCollapsableTableViewCell *cell = (SubCollapsableTableViewCell *)[super createFromModel:cellModel
                                                                               reusableCellID:@"SubCollapsableTableViewCellID"
                                                                                      nibName:@"SubCollapsableTableViewCell"
                                                                                  inTableView:tableView
                                                                                     userInfo:userInfo];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
