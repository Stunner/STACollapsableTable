//
//  STACollapsableTableModel.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/5/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STACollapsableTableModel.h"
#import <Nimbus/NIMutableTableViewModel.h>
#import <Nimbus/NICellCatalog.h>
#import "STATableModelSpecifier.h"

typedef void (^ObjectEnumeratorBlock)(id object);

@interface STACollapsableTableModel () <NITableViewModelDelegate>

@property (nonatomic, strong) NIMutableTableViewModel *tableModel;

@end

@implementation STACollapsableTableModel

//- (instancetype)initWithDelegate:(id<STACollapsableTableModelDelegate>)delegate {
//    if (self = [super init]) {
//        
//        self.delegate = delegate;
//    }
//    return self;
//}

- (instancetype)initWithContentsArray:(NSArray *)contentsArray
                             delegate:(id<STACollapsableTableModelDelegate>)delegate
{
    if (self = [super init]) {
        [self parseContents:contentsArray];
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Getters

- (id)dataSource {
    return self.tableModel;
}

#pragma mark - Private Methods

- (void)parseContents:(NSArray *)contentsArray {
    NSMutableArray *nimbusContents = [NSMutableArray array];
    [self enumerateObjects:contentsArray block:^(id object) {
        [nimbusContents addObject:object];
    }];
    NSLog(@"nimbusContents: %@", nimbusContents);
    self.tableModel = [[NIMutableTableViewModel alloc] initWithSectionedArray:nimbusContents
                                                                     delegate:self];
}

- (void)enumerateObjects:(NSArray *)contentsArray block:(ObjectEnumeratorBlock)block {
    if (contentsArray == 0) {
        return;
    }
    for (id object in contentsArray) {
        if ([object isKindOfClass:[STATableModelSpecifier class]]) {
            block(object);
            [self enumerateObjects:((STATableModelSpecifier *)object).children block:block];
        } else {
            block(object);
        }
    }
}

#pragma mark - NITableViewModelDelegate

- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object
{
    if ([self.delegate respondsToSelector:@selector(tableViewModel:cellForTableView:atIndexPath:withObject:)]) {
        return [self.delegate tableViewModel:self cellForTableView:tableView atIndexPath:indexPath withObject:object];
    }
    return nil;
}

@end
