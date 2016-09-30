//
//  SubCollapsableTableViewCell.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/9/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STACollapsableTableViewCell.h"

@interface SubCollapsableTableViewCell : STACollapsableTableViewCell

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo;

@end
