//
//  STATableModelSpecifier.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/6/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Object that easily specifies the nested structure of cells. Used to create STACellModel objects.
 */
@interface STATableModelSpecifier : NSObject

/**
 Populates STACellModel's title property.
 */
@property (nonatomic, strong) NSString *title;
/**
 Populates STACellModel's children property.
 */
@property (nonatomic, strong) NSArray<STATableModelSpecifier *> *children;
/**
 Custom data you may want to attach or have available with every cell model.
 */
@property (nonatomic, strong) id userInfo;

+ (instancetype)createWithTitle:(NSString *)title
                       children:(NSArray<STATableModelSpecifier *> *)children
                       userInfo:(id)userInfo;
- (instancetype)initWithTitle:(NSString *)title
                     children:(NSArray<STATableModelSpecifier *> *)children
                     userInfo:(id)userInfo;

@end
