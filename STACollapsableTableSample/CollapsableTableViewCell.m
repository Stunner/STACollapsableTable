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

@end

@implementation CollapsableTableViewCell

+ (CollapsableTableViewCell *)createFromModel:(STACellModel *)cellModel
                                  inTableView:(UITableView *)tableView
                                     userInfo:(NSDictionary *)userInfo
{
    CollapsableTableViewCell *cell = (CollapsableTableViewCell *)[super createFromModel:cellModel
                                                                         reusableCellID:@"CollapsableTableViewCellID"
                                                                                nibName:@"CollapsableTableViewCell"
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
