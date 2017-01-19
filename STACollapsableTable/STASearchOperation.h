//
//  STASearchOperation.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/10/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STACellModel;

/**
 @class STASearchOperation object that handles performing a search query while maintaining 
 the heirarchy of the collapsable table view. May be subclassed.
 */
@interface STASearchOperation : NSOperation

/**
 The starting set of data to be searched.
 */
@property (atomic, strong) NSArray<STACellModel *> *allSearchResults;
/**
 Unique search operation ID used for bookeeping purposes.
 */
@property (atomic, assign) NSUInteger operationID;
/**
 The user-entered search string to perform a query on.
 */
@property (atomic, strong, readonly) NSString *searchString;
/**
 The contents to be searched. This is set to what is passed in the 
 `initWithDataArray:withSearchString:` method.
 */
@property (nonatomic, strong, readonly) NSArray<STACellModel *> *dataArray;

- (instancetype)initWithDataArray:(NSArray<STACellModel *> *)dataArray withSearchString:(NSString *)searchString;

@end
