//
//  STATableViewDelegate.m
//  STACollapsableTable
//
//  Created by Aaron Jubbal on 2/7/16.
//  Copyright © 2016 Aaron Jubbal. All rights reserved.
//

#import "STATableViewDelegate.h"

@interface STATableViewDelegate () <UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, weak) id internalDelegate;
@property (nonatomic, weak) id <UITableViewDelegate,UISearchResultsUpdating,UISearchBarDelegate>externalDelegate;

@end

@implementation STATableViewDelegate

- (instancetype)initWithInternalDelegate:(id)internalDelegate
                        externalDelegate:(id<UITableViewDelegate,UISearchResultsUpdating,UISearchBarDelegate>)externalDelegate
{
    if (self = [super init]) {
        _internalDelegate = internalDelegate;
        _externalDelegate = externalDelegate;
    }
    return self;
}

#pragma mark - UITableViewDelegate Methods -

// Display customization
#pragma mark Display Customization

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:willDisplayHeaderView:forSection:)]) {
        [self.externalDelegate tableView:tableView willDisplayHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:willDisplayFooterView:forSection:)]) {
        [self.externalDelegate tableView:tableView willDisplayFooterView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didEndDisplayingHeaderView:forSection:)]) {
        [self.externalDelegate tableView:tableView didEndDisplayingHeaderView:view forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didEndDisplayingFooterView:forSection:)]) {
        [self.externalDelegate tableView:tableView didEndDisplayingFooterView:view forSection:section];
    }
}

// Variable height support
#pragma mark Variable Height Support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.externalDelegate tableView:tableView heightForHeaderInSection:section];
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.externalDelegate tableView:tableView heightForFooterInSection:section];
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)]) {
        return [self.externalDelegate tableView:tableView estimatedHeightForHeaderInSection:section];
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)]) {
        return [self.externalDelegate tableView:tableView estimatedHeightForFooterInSection:section];
    }
    return 0.0;
}

// Section header & footer information.
#pragma mark Section Header & Footer Information

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        return [self.externalDelegate tableView:tableView viewForHeaderInSection:section];
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        return [self.externalDelegate tableView:tableView viewForFooterInSection:section];
    }
    return nil;
}

// Accessories (disclosures).
#pragma mark Accessories

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//    if ([self.externalDelegate respondsToSelector:@selector(tableView:accessoryTypeForRowWithIndexPath:)]) {
//        return [self.externalDelegate tableView:tableView accessoryTypeForRowWithIndexPath:indexPath];
//    }
//    return UITableViewCellAccessoryNone;
//}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.externalDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.externalDelegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

// Selection
#pragma mark Selection

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:shouldHighlightRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didHighlightRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView didHighlightRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didUnhighlightRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
    }
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView willSelectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView willDeselectRowAtIndexPath:indexPath];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.internalDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

// Editing
#pragma mark Editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return @"Delete";
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)]) {
        [self.externalDelegate tableView:tableView didEndEditingRowAtIndexPath:indexPath];
    }
}

// Moving/reordering
#pragma mark Moving/Reordering

- (NSIndexPath *)tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if ([self.externalDelegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)]) {
        return [self.externalDelegate tableView:tableView targetIndexPathForMoveFromRowAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
    }
    return proposedDestinationIndexPath;
}

// Indentation
#pragma mark Indentation

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
    return 0;
}

// Copy/Paste
#pragma mark Copy/Paste

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:shouldShowMenuForRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:canPerformAction:forRowAtIndexPath:withSender:)]) {
        return [self.externalDelegate tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:performAction:forRowAtIndexPath:withSender:)]) {
        [self.externalDelegate tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

// Focus
#pragma mark Focus

- (BOOL)tableView:(UITableView *)tableView canFocusRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:canFocusRowAtIndexPath:)]) {
        return [self.externalDelegate tableView:tableView canFocusRowAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldUpdateFocusInContext:(UITableViewFocusUpdateContext *)context {
    if ([self.externalDelegate respondsToSelector:@selector(tableView:shouldUpdateFocusInContext:)]) {
        return [self.externalDelegate tableView:tableView shouldUpdateFocusInContext:context];
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView
didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context
withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    if ([self.externalDelegate respondsToSelector:@selector(tableView:didUpdateFocusInContext:withAnimationCoordinator:)]) {
        [self.externalDelegate tableView:tableView didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    }
}

- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInTableView:(UITableView *)tableView {
    if ([self.externalDelegate respondsToSelector:@selector(indexPathForPreferredFocusedViewInTableView:)]) {
        return [self.externalDelegate indexPathForPreferredFocusedViewInTableView:tableView];
    }
    return nil;
}

#pragma mark - UISearchbarDelegate Methods -

// Editing Text
#pragma mark Editing Text

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([self.externalDelegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.externalDelegate searchBarShouldBeginEditing:searchBar];
    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.internalDelegate searchBarTextDidBeginEditing:searchBar];
    if ([self.externalDelegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.externalDelegate searchBarTextDidBeginEditing:searchBar];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([self.externalDelegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.externalDelegate searchBarShouldEndEditing:searchBar];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.internalDelegate searchBarTextDidEndEditing:searchBar];
    if ([self.externalDelegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.externalDelegate searchBarTextDidEndEditing:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self.externalDelegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.externalDelegate searchBar:searchBar textDidChange:searchText];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([self.externalDelegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.externalDelegate searchBar:searchBar shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

// Clicking Buttons
#pragma mark Clicking Buttons

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([self.externalDelegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.externalDelegate searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    if ([self.externalDelegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [self.externalDelegate searchBarBookmarkButtonClicked:searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.externalDelegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.externalDelegate searchBarCancelButtonClicked:searchBar];
    }
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    if ([self.externalDelegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
        [self.externalDelegate searchBarResultsListButtonClicked:searchBar];
    }
}

// Scope Button
#pragma mark Scope Button

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    if ([self.externalDelegate respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)]) {
        [self.externalDelegate searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    }
}

#pragma mark - UISearchResultsUpdating Delegate Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.internalDelegate updateSearchResultsForSearchController:searchController];
    if ([self.externalDelegate respondsToSelector:@selector(updateSearchResultsForSearchController:)]) {
        [self.externalDelegate updateSearchResultsForSearchController:searchController];
    }
}

@end
