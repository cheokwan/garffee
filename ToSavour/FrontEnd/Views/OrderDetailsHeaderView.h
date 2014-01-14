//
//  OrderDetailsHeaderView.h
//  ToSavour
//
//  Created by Jason Wan on 14/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderProgressView.h"

@interface OrderDetailsHeaderView : UIView

@property (nonatomic, strong)   IBOutlet UILabel *orderNumberLabel;
@property (nonatomic, strong)   IBOutlet UILabel *totalLabel;
@property (nonatomic, strong)   IBOutlet UILabel *priceLabel;
@property (nonatomic, strong)   IBOutlet OrderProgressView *orderProgressView;

- (void)updateOrderNumber:(NSString *)newOrderNumber;
- (void)updatePrice:(CGFloat)newPrice;

@end
