//
//  STACollapsableTableModel+Private.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 5/27/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACollapsableTableModel.h"

@class STACellModel;
@class STATableModelSpecifier;

@interface STACollapsableTableModel (Private)

- (STACellModel *)cellModelForSpecifier:(STATableModelSpecifier *)specifier
                                 parent:(STACellModel *)parent
                             tableModel:(STACollapsableTableModel *)tableModel;

@end
