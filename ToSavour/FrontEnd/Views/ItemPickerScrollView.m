//
//  ItemPickerScrollView.m
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ItemPickerScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ItemPickerScrollView

- (void)initialize {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.clipsToBounds = YES;
    self.pagingEnabled = NO;  // manual paging
    self.decelerationRate = UIScrollViewDecelerationRateNormal / 2.0;
    self.delegate = self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGFloat)itemViewDimension {
    return self.bounds.size.height;
}

- (CGFloat)sideMargin {
    return self.itemViewDimension * 1.5;
}

- (void)addItemViews:(NSArray *)itemViews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    CGFloat offsetX = self.sideMargin;
    for (UIView *view in itemViews) {
        view.frame = CGRectMake(offsetX, 0, self.itemViewDimension, self.itemViewDimension);
        [self addSubview:view];
        offsetX += self.itemViewDimension;
    }
    self.contentSize = CGSizeMake(offsetX + self.sideMargin, self.itemViewDimension);
    
    [self updateScaleForItems];
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    CGFloat offsetX = index * self.itemViewDimension;
    if (offsetX < self.contentSize.width) {
        [self setContentOffset:CGPointMake(offsetX, self.contentOffset.y) animated:animated];
        
        // don't call back the delegate for this method for now to simplify the control flow
//        if ([_pickerDelegate respondsToSelector:@selector(pickerAtIndexPath:didSelectItem:atIndex:)]) {
//            UIView *itemSubview = [self subviewAtOrigin:CGPointMake(offsetX + self.sideMargin, self.contentOffset.y)];
//            [_pickerDelegate pickerAtIndexPath:self.occupiedIndexPath didSelectItem:itemSubview atIndex:index];
//        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self snapToColumn];
    });
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self) {
        // snap to the nearest whole item
        if (!decelerate) {
            [self snapToColumn];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self) {
        [self updateScaleForItems];
    }
}

- (CGFloat)scaleForOffsetFromFocusPoint:(CGFloat)offset {
    CGFloat normalizedOffset = fabsf(offset / self.itemViewDimension);
    CGFloat scalar = 1.0;
    if (normalizedOffset <= 0.5) {
        CGFloat scalarMax = 1.4;
        scalar = ((-(scalarMax - 1.0) / 0.5) * normalizedOffset) + scalarMax;
    }
    return scalar;
}

- (void)updateScaleForItems {
    [UIView animateWithDuration:0.25 animations:^{
        [self.subviews enumerateObjectsUsingBlock:^(UIView *container, NSUInteger index, BOOL *stop) {
            CGFloat offset = index * self.itemViewDimension + self.itemViewDimension / 2.0;
            CGFloat center = self.contentOffset.x + self.itemViewDimension / 2.0;
            CGFloat distance = offset - center;
            CGFloat scale = [self scaleForOffsetFromFocusPoint:distance];
            container.transform = CGAffineTransformMakeScale(scale, scale);
        }];
    }];
}

- (NSInteger)getCurrentSelectedItemIndex {
    CGFloat index = self.contentOffset.x / self.itemViewDimension;
    return (NSInteger)index;
}

- (void)snapToColumn {
    // snsp to the nearest whole item
    CGFloat offsetX = self.contentOffset.x;
    CGFloat offsetXFraction = offsetX - floor(offsetX);
    offsetX = (int)floor(offsetX) % (int)floor(self.itemViewDimension);
    offsetX += offsetXFraction;
    
    CGPoint newPoint = CGPointMake(self.contentOffset.x - offsetX, self.contentOffset.y);
    if (offsetX > (self.itemViewDimension / 2.0)) {
        newPoint.x = newPoint.x + self.itemViewDimension;
    }
    [self setContentOffset:newPoint animated:YES];
    
    if ([_pickerDelegate respondsToSelector:@selector(pickerAtIndexPath:didSelectItem:atIndex:)]) {
        CGFloat itemIndex = newPoint.x / self.itemViewDimension;
        // newPoint is relative to contentOffset which disregards the side margin
        UIView *itemSubview = [self subviewAtOrigin:CGPointMake(newPoint.x + self.sideMargin, newPoint.y)];
        [_pickerDelegate pickerAtIndexPath:self.occupiedIndexPath didSelectItem:itemSubview atIndex:itemIndex];
    }
}

@end
