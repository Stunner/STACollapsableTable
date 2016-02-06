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
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) NSDictionary *userInfo;

+ (instancetype)createWithTitle:(NSString *)title children:(NSArray *)children userInfo:(NSDictionary *)userInfo;
- (instancetype)initWithTitle:(NSString *)title children:(NSArray *)children userInfo:(NSDictionary *)userInfo;

@end
