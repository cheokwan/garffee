//
//  OrderCompositeImageView.m
//  ToSavour
//
//  Created by Jason Wan on 28/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "OrderCompositeImageView.h"
#import "MItemInfo.h"
#import "MProductInfo.h"

@implementation OrderCompositeImageView

- (void)initialize {
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame order:(MOrderInfo *)order {
    self = [self initWithFrame:frame];
    if (self) {
        MItemInfo *item = [order.items anyObject];
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

@end
