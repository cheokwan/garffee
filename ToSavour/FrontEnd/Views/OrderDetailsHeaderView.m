//
//  OrderDetailsHeaderView.m
//  ToSavour
//
//  Created by Jason Wan on 14/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "OrderDetailsHeaderView.h"
#import "TSFrontEndIncludes.h"

@implementation OrderDetailsHeaderView

- (void)initializeView {
    _orderNumberLabel.text = [NSString stringWithFormat:@"@% %@", LS_NUM_NO, @""];
    _totalLabel.text = LS_TOTAL;
    _orderNumberLabel.textColor = [TSTheming defaultThemeColor];
    _totalLabel.textColor = [TSTheming defaultThemeColor];
    _priceLabel.textColor = [TSTheming defaultThemeColor];
    
    _priceLabel.text = [NSString stringWithPrice:0.0];
    [_orderProgressView updateStatus:@""];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)updateOrderNumber:(NSString *)newOrderNumber {
    self.orderNumberLabel.text = [NSString stringWithFormat:@"%@ %@", LS_NUM_NO, newOrderNumber];
}

- (void)updatePrice:(CGFloat)newPrice {
    self.priceLabel.text = [NSString stringWithPrice:newPrice];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
