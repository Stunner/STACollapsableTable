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

- (void)initConfigurationWithModel:(STACellModel *)cellModel userInfo:(NSDictionary *)userInfo {
    
    self.textLabel.text = cellModel.title;
    
    // IMPORTANT: Notice how call to super is called after setting textLabel's text property, this is
    // important in order to ensure text darkens/fades appropriately to display relevance within search,
    // as super's implementation checks for existance of textLabel's text property before performing fading.
    [super initConfigurationWithModel:cellModel userInfo:userInfo];
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
