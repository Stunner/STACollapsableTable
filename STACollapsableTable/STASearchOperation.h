//
//  STASearchOperation.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STASearchOperation : NSOperation

@property (atomic, strong) NSArray *allSearchResults;
@property (atomic, strong) NSString *searchString;
@property (atomic, assign) NSUInteger operationID;

- (instancetype)initWithDataArray:(NSArray *)dataArray withSearchString:(NSString *)searchString;

@end
