//
//  STACellModel.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/7/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACellModel.h"

@implementation STACellModel

- (instancetype)initWithModelSpecifier:(STATableModelSpecifier *)modelSpecifier parent:(STACellModel *)parent {
    if (self = [super init]) {
        _title = modelSpecifier.title;
        _specifier = modelSpecifier;
        
        if (parent) {
            _parent = parent;
            _depth = parent.depth + 1;
        } else {
            _depth = 0; // no parent means this element is a root (depth of 0)
        }
        
        NSMutableArray *childrenArray = [NSMutableArray arrayWithCapacity:modelSpecifier.children.count];
        for (STATableModelSpecifier *specifier in modelSpecifier.children) {
            STACellModel *cellModel = [[STACellModel alloc] initWithModelSpecifier:specifier parent:self];
            [childrenArray addObject:cellModel];
        }
        _children = childrenArray;
    }
    return self;
}

@end
