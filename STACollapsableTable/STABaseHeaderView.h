//
//  HeaderView.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 5/17/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STACellModel.h"
#import "STACollapsableTableModel.h"

@interface STABaseHeaderView : UIView

@property (nonatomic, strong) STACellModel *cellModel;
@property (nonatomic, assign, readonly) NSInteger section;

+ (instancetype)createHeaderInSection:(NSInteger)section
                            fromModel:(STACellModel *)cellModel
                           tableModel:(STACollapsableTableModel *)tableModel
                              nibName:(NSString *)nibName
                             userInfo:(NSDictionary *)userInfo;

- (void)headerTapped;
- (void)animateUpdateOfImageViewWithDuration:(NSTimeInterval)duration;
- (void)updateImageView;
- (void)isSearchResultStateChanged:(BOOL)isSearchResult;

@end
