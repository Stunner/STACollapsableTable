//
//  STACollapsableTableModelOptions.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 9/29/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STACollapsableTableModelOptions : NSObject

/**
 Specifies if sections are initially collapsed or expanded upon first load.
 */
@property (nonatomic, assign) BOOL initiallyCollapsed;
/**
 Reflects if the table model is set to display all root models (with depth of 0) as section headers.
 */
@property (nonatomic, assign) BOOL useTableSections;

@end
