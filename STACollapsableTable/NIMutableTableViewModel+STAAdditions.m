//
//  NIMutableTableViewModel+STAAdditions.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 6/17/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "NIMutableTableViewModel+STAAdditions.h"

@implementation NIMutableTableViewModel (STAAdditions)

- (void)sta_removeAllSections {
    NSMutableArray *sections = [self valueForKey:@"sections"];
    [sections removeAllObjects];
}

@end
