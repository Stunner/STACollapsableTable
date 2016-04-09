//
//  NSArray+STACollapsableTable.m
//  DavisMap
//
//  Created by Aaron Jubbal on 3/21/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "NSArray+STACollapsableTable.h"
#import "STATableModelSpecifier.h"

@implementation NSArray (STACollapsableTable)

- (void)enumerateSTAModelSpecifierObjects:(ObjectEnumeratorBlock)block {
    if (self.count == 0) {
        return;
    }
    for (id object in self) {
        if ([object isKindOfClass:[STATableModelSpecifier class]]) {
            block(object);
            if (((STATableModelSpecifier *)object).children.count > 0) {
                [((STATableModelSpecifier *)object).children enumerateSTAModelSpecifierObjects:block];
            }
        } else {
            block(object);
        }
    }
}

@end
