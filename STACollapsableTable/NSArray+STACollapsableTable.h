//
//  NSArray+STACollapsableTable.h
//  DavisMap
//
//  Created by Aaron Jubbal on 3/21/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ObjectEnumeratorBlock)(id object);

@interface NSArray (STACollapsableTable)

- (void)enumerateSTAModelSpecifierObjects:(ObjectEnumeratorBlock)block;

@end
