//
//  CustomCellModel.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/18/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACellModel.h"

@interface CustomCellModel : STACellModel

@property (nonatomic, assign) BOOL isToggledOn;
@property (nonatomic, assign) NSUInteger descendantsToggledOn;

@end
