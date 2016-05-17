//
//  HeaderView.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 5/17/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STACellModel.h"

@interface HeaderView : UIView

@property (nonatomic, strong) STACellModel *cellModel;

+ (HeaderView *)createFromModel:(STACellModel *)cellModel
                       userInfo:(NSDictionary *)userInfo;

@end
