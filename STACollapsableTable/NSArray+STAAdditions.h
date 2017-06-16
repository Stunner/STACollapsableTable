//
//  NSArray+STAAdditions.h
//  STACollapsableTable
//
//  Created by Aman Dhar on 6/12/17.
//  Copyright © 2017 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (STAAdditions)

- (NSArray *)arrayContainsText:(NSString *)searchString options:(NSStringCompareOptions)mask;

@end
