//
//  UITableViewController+ENFooterActivityIndicatorView.m
//  ENTableFooterActivityIndicator
//
//  Created by Evgeny on 21.12.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

#import "UITableView+ENFooterActivityIndicatorView.h"
#import "ENFooterActivityIndicatorView.h"
#import <objc/runtime.h>

static void * ENFooterActivityIndicatorViewBlockKey = &ENFooterActivityIndicatorViewBlockKey;

@implementation UITableView (ENFooterActivityIndicatorView)

#pragma mark - Public methods

- (void)addFooterActivityIndicatorWithHeight:(CGFloat)height {
    ENFooterActivityIndicatorView *footerActivityIndicatorView = [ENFooterActivityIndicatorView activityIndicatorWithHeight:height];
    [self setTableFooterView:footerActivityIndicatorView];
}

- (void)removeFooterActivityIndicator {
    [[self footerActivityIndicatorView] removeFromSuperview];
    [self setTableFooterView:nil];
}

- (void)tableViewDidScroll {
    UIScrollView *scrollView = self;
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    CGFloat distance = y - size.height;
    if (distance > 0.f) {
        [[self footerActivityIndicatorView] updateForTableBottomOffset:distance];
        if (self.tableScrolledDownBlock)
            self.tableScrolledDownBlock();
    }
}

#pragma mark - Getters & Setters

- (ENTableScrolledDownBlock)tableScrolledDownBlock {
    return objc_getAssociatedObject(self, ENFooterActivityIndicatorViewBlockKey);
}

- (void)setTableScrolledDownBlock:(ENTableScrolledDownBlock)tableScrolledDownBlock {
    objc_setAssociatedObject(self, ENFooterActivityIndicatorViewBlockKey, tableScrolledDownBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ENFooterActivityIndicatorView *)footerActivityIndicatorView {
    if ([self.tableFooterView isKindOfClass:[ENFooterActivityIndicatorView class]])
        return (ENFooterActivityIndicatorView *)self.tableFooterView;
    
    return nil;
}

@end
