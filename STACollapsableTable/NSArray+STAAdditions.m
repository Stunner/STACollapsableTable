//
//  NSArray+STAAdditions.m
//  STACollapsableTable
//
//  Created by Aman Dhar on 6/12/17.
//  Copyright © 2017 Aaron Jubbal. All rights reserved.
//

#import "NSArray+STAAdditions.h"

@implementation NSArray (STAAdditions)
    
- (NSArray *)arrayContainsText:(NSString *)searchString options:(NSStringCompareOptions)mask {
    NSMutableArray *relevantTags = [NSMutableArray array];
    for (NSString *tag in self) {
        NSRange range = [tag rangeOfString:searchString options:mask];
        if (range.location != NSNotFound) {
            [relevantTags addObject:tag];
        }
    }
    return relevantTags;
}


@end
