//
//  STATableViewDelegate.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/7/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STATableViewDelegate : NSObject

- (instancetype)initWithInternalDelegate:(id)internalDelegate
                        externalDelegate:(id<UITableViewDelegate>)externalDelegate;

@end
