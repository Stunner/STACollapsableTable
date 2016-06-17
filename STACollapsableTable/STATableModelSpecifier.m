//
//  STATableModelSpecifier.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/6/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STATableModelSpecifier.h"

@implementation STATableModelSpecifier

+ (instancetype)createWithTitle:(NSString *)title
                       children:(NSArray<STATableModelSpecifier *> *)children
                       userInfo:(id)userInfo
{
    return [[STATableModelSpecifier alloc] initWithTitle:title children:children userInfo:userInfo];
}

- (instancetype)initWithTitle:(NSString *)title
                     children:(NSArray<STATableModelSpecifier *> *)children
                     userInfo:(id)userInfo
{
    if (self = [super init]) {
        _title = title;
        _children = children;
        _userInfo = userInfo;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title: %@\n"
            @"children: %@\n"
            @"userInfo: %@\n", self.title, self.children, self.userInfo];
}

@end
