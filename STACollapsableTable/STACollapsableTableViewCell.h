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
 
 IMPORTANT: Subclasses that care to provide a collapsable image view and contain a custom
 label to hold the title should instantiate and leverage instance variables
 `collapsedStatusImageView` and `titleLabel`.
 */
@interface STACollapsableTableViewCell : UITableViewCell

@property (nonatomic, strong) STACellModel *cellModel;

+ (instancetype)createFromModel:(STACellModel *)cellModel
                 reusableCellID:(NSString *)reusableCellID
                        nibName:(NSString *)nibName
                    inTableView:(UITableView *)tableView
                       userInfo:(NSDictionary *)userInfo;

/**
 Note: CellModel's title isn't applied to textLabel within this method. You must do this
 yourself (from within this method or from `initConfigurationWithModel:userInfo:` after method 
 call to super) if you call this method.
 */
+ (instancetype)createFromModel:(STACellModel *)cellModel
                 reusableCellID:(NSString *)reusableCellID
                      className:(NSString *)className
                    inTableView:(UITableView *)tableView
                       userInfo:(NSDictionary *)userInfo;

- (void)initConfigurationWithModel:(STACellModel *)cellModel userInfo:(NSDictionary *)userInfo;
- (void)isSearchResultStateChanged:(BOOL)isSearchResult;
- (void)updateImageView;
- (void)cellTapped;

@end
