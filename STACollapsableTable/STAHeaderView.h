//
//  STAHeaderView.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 9/30/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STABaseHeaderView.h"

@interface STAHeaderView : STABaseHeaderView

+ (instancetype)createHeaderInSection:(NSInteger)section
                            fromModel:(STACellModel *)cellModel
                           tableModel:(STACollapsableTableModel *)tableModel
                              nibName:(NSString *)nibName
                             userInfo:(NSDictionary *)userInfo;

@end
