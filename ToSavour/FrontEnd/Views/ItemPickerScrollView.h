//
//  ItemPickerScrollView.h
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemPickerScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, readonly) CGFloat itemViewDimension;  // item view is square
@property (nonatomic, readonly) CGFloat sideMargin;
@property (nonatomic, strong)   NSIndexPath *occupiedIndexPath;

- (void)addItemViews:(NSArray *)itemViews;

@end
