//
//  STACollapsableTableViewCell.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STACellModel.h"

/**
 Meant to be subclassed and not instantiated directly.
 
 IMPORTANT: Subclass that care to provide a collapsable image view and contain a custom
 label to hold the title must instantiate and leverage instance variables 
 `collapsedStatusImageView` and `titleLabel`. Otherwise unexpected behavior will occur.
 */
@interface STACollapsableTableViewCell : UITableViewCell

@property (nonatomic, strong) STACellModel *cellModel;

+ (instancetype)createFromModel:(STACellModel *)cellModel
                 reusableCellID:(NSString *)reusableCellID
                        nibName:(NSString *)nibName
                    inTableView:(UITableView *)tableView
                       userInfo:(NSDictionary *)userInfo;

+ (instancetype)createFromModel:(STACellModel *)cellModel
                 reusableCellID:(NSString *)reusableCellID
                      className:(NSString *)className
                    inTableView:(UITableView *)tableView
                       userInfo:(NSDictionary *)userInfo;

- (void)cellTapped;

@end
