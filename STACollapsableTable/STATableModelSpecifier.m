//
//  STATableModelSpecifier.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/6/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STATableModelSpecifier.h"

@implementation STATableModelSpecifier

+ (instancetype)createWithTitle:(NSString *)title children:(NSArray *)children userInfo:(id)userInfo {
    return [[STATableModelSpecifier alloc] initWithTitle:title children:children userInfo:userInfo];
}

- (instancetype)initWithTitle:(NSString *)title children:(NSArray *)children userInfo:(id)userInfo {
    if (self = [super init]) {
        self.title = title;
        self.children = children;
        self.userInfo = userInfo;
    }
    return self;
}

@end
