//
//  LeafNodeTableViewCell.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/11/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "LeafNodeTableViewCell.h"

@implementation LeafNodeTableViewCell

+ (LeafNodeTableViewCell *)createFromModel:(STACellModel *)cellModel
                               inTableView:(UITableView *)tableView
                                  userInfo:(NSDictionary *)userInfo
{
    LeafNodeTableViewCell *cell = (LeafNodeTableViewCell *)[super createFromModel:cellModel
                                                                   reusableCellID:@"LeafNodeTableViewCellID"
                                                                        className:@"LeafNodeTableViewCell"
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
