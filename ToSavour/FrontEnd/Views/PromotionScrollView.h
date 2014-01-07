//
//  PromotionScrollView.h
//  ToSavour
//
//  Created by Jason Wan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PromotionScrollView;

@protocol PromotionScrollViewDelegate <NSObject>
- (void)promotionScrollView:(PromotionScrollView *)scrollView didSelectPromotionAtIndex:(NSInteger)index;
@end

@interface PromotionScrollView : UIView<UIScrollViewDelegate>

@property (nonatomic, strong)   UIScrollView *promotionScrollView;
@property (nonatomic, strong)   UIPageControl *promotionPageControl;

@property (nonatomic, weak)     id<PromotionScrollViewDelegate> delegate;

@end
