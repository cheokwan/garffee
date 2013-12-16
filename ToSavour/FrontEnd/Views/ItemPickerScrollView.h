//
//  ItemPickerScrollView.h
//  ToSavour
//
//  Created by Jason Wan on 7/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemPickerScrollViewDelegate <NSObject>
- (void)pickerAtIndexPath:(NSIndexPath *)indexPath didSelectItem:(UIView *)itemView atIndex:(NSInteger)index;
@end


@interface ItemPickerScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, readonly) CGFloat itemViewDimension;  // item view is square
@property (nonatomic, readonly) CGFloat sideMargin;
@property (nonatomic, strong)   NSIndexPath *occupiedIndexPath;
@property (nonatomic, weak)     id<ItemPickerScrollViewDelegate> pickerDelegate;

- (void)addItemViews:(NSArray *)itemViews;

@end
