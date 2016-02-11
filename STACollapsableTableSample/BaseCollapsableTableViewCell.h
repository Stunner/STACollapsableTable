//
//  BaseCollapsableTableViewCell.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STACellModel.h"

@interface BaseCollapsableTableViewCell : UITableViewCell

@property (nonatomic, strong) STACellModel *cellModel;

+ (UITableViewCell *)createFromModel:(STACellModel *)cellModel
                      reusableCellID:(NSString *)reusableCellID
                             nibName:(NSString *)nibName
                         inTableView:(UITableView *)tableView
                            userInfo:(NSDictionary *)userInfo;

- (void)cellTapped;

@end
