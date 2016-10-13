//
//  STAHeaderView.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 9/30/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STAHeaderView.h"

@interface STAHeaderView ()

@property (nonatomic, strong) IBOutlet UIImageView *collapsedStatusImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@end

@implementation STAHeaderView

@dynamic collapsedStatusImageView;
@dynamic titleLabel;

+ (instancetype)createHeaderInSection:(NSInteger)section
                            fromModel:(STACellModel *)cellModel
                           tableModel:(STACollapsableTableModel *)tableModel
                              nibName:(NSString *)nibName
                             userInfo:(NSDictionary *)userInfo
{
    STAHeaderView *view = (STAHeaderView *)[super createHeaderInSection:section
                                                              fromModel:cellModel
                                                             tableModel:tableModel
                                                                nibName:nibName
                                                               userInfo:userInfo];
    return view;
}

@end
