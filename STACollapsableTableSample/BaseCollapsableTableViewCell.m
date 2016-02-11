//
//  BaseCollapsableTableViewCell.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "BaseCollapsableTableViewCell.h"
#import "STACellModel.h"

@interface BaseCollapsableTableViewCell ()

@property (nonatomic, strong) STACellModel *cellModel;

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
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
