//
//  STACollapsableTableModel.h
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/5/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STACellModel;
@class STACollapsableTableModel;

@protocol STACollapsableTableModelDelegate <NSObject>

@optional

- (NSUInteger)displayedDescendantsCount;
- (NSUInteger)descendantsInSearchResults;
- (BOOL)isSearchResult;

@required

- (UITableViewCell *)tableViewModel:(STACollapsableTableModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(STACellModel *)object;

@end

@interface STACollapsableTableModel : NSObject

@property (nonatomic, weak) id<STACollapsableTableModelDelegate> delegate;
@property (nonatomic, readonly) id dataSource;

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                             delegate:(id<STACollapsableTableModelDelegate>)delegate;

@end
