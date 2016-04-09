//
//  STATableModelSpecifier.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/6/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STATableModelSpecifier : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray <STATableModelSpecifier *> *children;
@property (nonatomic, strong) id userInfo;

+ (instancetype)createWithTitle:(NSString *)title children:(NSArray *)children userInfo:(id)userInfo;
- (instancetype)initWithTitle:(NSString *)title children:(NSArray *)children userInfo:(id)userInfo;

@end
