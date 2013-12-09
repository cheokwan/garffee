//
//  ItemPickerScrollView.m
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ItemPickerScrollView.h"

@implementation ItemPickerScrollView

- (void)initialize {
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.clipsToBounds = YES;
    self.pagingEnabled = NO;  // manual paging
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
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    double delayInSeconds = 1.0;
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

- (void)snapToColumn {
    // snsp to the nearest whole item
    CGFloat offsetX = self.contentOffset.x;
    CGFloat offsetXDecimalPart = offsetX - (int)offsetX;
    offsetX = (int)offsetX % (int)self.itemViewDimension;
    offsetX += offsetXDecimalPart;
    
    CGPoint newPoint = CGPointMake(self.contentOffset.x - offsetX, self.contentOffset.y);
    if (offsetX > (self.itemViewDimension / 2.0)) {
        newPoint.x = newPoint.x + self.itemViewDimension;
    }
    [self setContentOffset:newPoint animated:YES];
}

@end
