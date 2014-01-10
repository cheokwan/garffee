//
//  HomeViewController.h
//  ToSavour
//
//  Created by Jason Wan on 5/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeControlView.h"
#import "PromotionScrollView.h"
#import "TSBadgeView.h"

@interface HomeViewController : UIViewController<PromotionScrollViewDelegate>

@property (nonatomic, strong)   IBOutlet PromotionScrollView *promotionScrollView;
@property (nonatomic, strong)   IBOutlet HomeControlView *homeControlView;
@property (nonatomic, strong, readonly) UIButton *itemBagButton;
@property (nonatomic, strong, readonly) TSBadgeView *itemBadgeView;

- (void)updateItemBadgeCount;

@end
